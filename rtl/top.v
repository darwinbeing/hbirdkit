`timescale 1ns/1ps

module top
    (
     CLK100MHZ,//GCLK-W19
     fpga_rst,//FPGA_RESET-T6
     mcu_rst,//MCU_RESET-P20
     led8,
     led9,
     led10,
     uart0_rxd,
     uart0_txd
     );

    input CLK100MHZ;
    input fpga_rst;
    input mcu_rst;
    output reg led8;
    output reg led9;
    output reg led10;
    input        uart0_rxd;
    output       uart0_txd;


    localparam CNT_MODULO = 100000000;
    localparam CNT_MODULO_BITS = $clog2(CNT_MODULO);
    reg [CNT_MODULO_BITS-1:0] cnt = 0;
    wire                      rstn;
    assign rstn = fpga_rst & mcu_rst;
    // assign led8 = (cnt > 50000000) ? 1'b1 : 1'b0;

    wire                      clk_50M;
    wire                      clk_33M;
    wire                      pll_locked;


    xlnx_clk_gen xlnx_clk_gen_inst
        (
         .clk_out1(clk_50M),
         .clk_out2(clk_33M),
         .resetn(rstn),
         .locked(pll_locked),
         .clk_in1(CLK100MHZ));

    reg [7:0]                 io_to_slave;
    wire                      s_baudout;
    reg [2:0]                s_uart_addr;
    reg                      s_uart_cs;
    wire [7:0]                s_uart_out;
    wire                      uart_int;
    reg                       s_wr_en;
    reg                       s_rd_en;
    reg [3:0]                 nxt_state;
    reg [3:0]                 cur_state;

    localparam  STATE_UART_CONF_IDLE              = 0;
    localparam  STATE_UART_CONF_1             = 1;
    localparam  STATE_UART_CONF_2            = 2;
    localparam  STATE_UART_CONF_3            = 3;
    localparam  STATE_UART_CONF_4            = 4;
    localparam  STATE_UART_CONF_5            = 5;
    localparam  STATE_UART_CONF_6            = 6;
    localparam  STATE_UART_CONF_DONE            = 7;

    localparam UART_RX  = 3'b000;
    localparam UART_TX  = 3'b000;
    localparam UART_IER = 3'b001;
    localparam UART_FCR = 3'b010;
    localparam UART_LCR = 3'b011;
    localparam UART_MCR = 3'b100;
    localparam UART_LSR = 3'b101;
    localparam UART_MSR = 3'b110;
    localparam UART_SCR = 3'b111;

    localparam UART_DLL = 3'b000;
    localparam UART_DLM = 3'b001;

    localparam UART_MCR_LOOP  = 8'h10;

    uart_16750 uart_inst
        (
         .clk(clk_33M),
         .rst(~rstn),
         .baudce(1'b1),
         .cs(s_uart_cs),
         .wr(s_wr_en),
         .rd(s_rd_en),
         .a(s_uart_addr),
         .din(io_to_slave),
         .dout(s_uart_out),
         .ddis(),
         .int(uart_int),
         .out1n(),
         .out2n(),
         .rclk(s_baudout),
         .baudoutn(s_baudout),
         .rtsn(),
         .dtrn(),
         .ctsn(),
         .dsrn(),
         .dcdn(),
         .rin(),
         .sin(uart0_rxd),
         .sout(uart0_txd));


    xlnx_ila xlnx_ila_inst
        (
         .clk(CLK100MHZ), // input wire clk


         .probe0(clk_33M), // input wire [0:0]  probe0
         .probe1(io_to_slave), // input wire [7:0]  probe1
         .probe2(s_uart_out), // input wire [7:0]  probe2
         .probe3(rstn), // input wire [0:0]  probe3
         .probe4(uart_int), // input wire [0:0]  probe4
         .probe5(s_baudout), // input wire [0:0]  probe5
         .probe6(uart0_rxd), // input wire [0:0]  probe6
         .probe7(uart0_txd) // input wire [0:0]  probe7
         );


//    vio_0 vio_0_inst (
//          .clk(clk_33M),                // input wire clk
//          .probe_in0(s_uart_out),    // input wire [7 : 0] probe_in0
//          .probe_in1(uart0_rxd),    // input wire [0 : 0] probe_in1
//          .probe_in2(uart0_txd),    // input wire [0 : 0] probe_in2
//          .probe_out0(io_to_slave),  // output wire [7 : 0] probe_out0
//          .probe_out1(s_wr_en),  // output wire [0 : 0] probe_out1
//          .probe_out2(s_rd_en)  // output wire [0 : 0] probe_out2
//        );

    // always @(posedge CLK100MHZ or negedge rstn)
    //     if(~rstn) begin
    //         cnt <= 1'b0;
    //     end else begin
    //         cnt <= cnt + 1;
    //     end


    always @ (posedge clk_33M or negedge rstn) begin
        if (~rstn) begin
            cur_state <= STATE_UART_CONF_IDLE;
            nxt_state <= STATE_UART_CONF_IDLE;
        end else begin
            cur_state <= nxt_state;
        end
    end

    always @(*) begin
        nxt_state = cur_state;

        case (cur_state)
            STATE_UART_CONF_IDLE: begin
                s_uart_addr = 3'b0;
                s_uart_cs = 1'b0;
                s_wr_en = 1'b0;
                s_rd_en =  1'b0;
                nxt_state = STATE_UART_CONF_1;
            end
            STATE_UART_CONF_1: begin
                s_uart_addr = UART_LCR;
                io_to_slave = 8'h83;
                s_wr_en = 1'b1;
                s_uart_cs = 1'b1;
                nxt_state = STATE_UART_CONF_2;
            end
            STATE_UART_CONF_2: begin
                s_uart_addr = UART_DLL;
                io_to_slave = 8'h11;
                s_wr_en = 1'b1;
                s_uart_cs = 1'b1;
                nxt_state = STATE_UART_CONF_3;
            end
            STATE_UART_CONF_3: begin
                s_uart_addr = UART_DLM;
                io_to_slave = 8'h00;
                s_wr_en = 1'b1;
                s_uart_cs = 1'b1;
                nxt_state = STATE_UART_CONF_4;
            end
            STATE_UART_CONF_4: begin
                s_uart_addr = UART_LCR;
                io_to_slave = 8'h00;
                s_wr_en = 1'b1;
                s_uart_cs = 1'b1;
                nxt_state = STATE_UART_CONF_5;
            end

            STATE_UART_CONF_5: begin
                s_uart_addr = UART_FCR;
                io_to_slave = 8'h81;
                s_wr_en = 1'b1;
                s_uart_cs = 1'b1;
                nxt_state = STATE_UART_CONF_6;
            end
            STATE_UART_CONF_6: begin
                s_uart_addr = UART_IER;
                io_to_slave = 8'h01;
                s_wr_en = 1'b1;
                s_uart_cs = 1'b1;
                nxt_state = STATE_UART_CONF_DONE;
            end
            default: begin
                s_uart_addr = 3'b0;
                s_uart_cs = 1'b0;
                s_wr_en = 1'b0;
                s_rd_en =  1'b0;
                nxt_state = STATE_UART_CONF_DONE;
            end

        endcase
    end

    always @(posedge CLK100MHZ or negedge rstn)
        if(~rstn) begin
            led8 <= 1'b0;
            led9 <= 1'b0;
            led10 <= 1'b0;
        end else if(s_uart_out == 8'h20) begin
            led8 <= 1'b1;
            led9 <= 1'b1;
            led10 <= 1'b1;
        end else begin
            led8 <= 1'b0;
            led9 <= 1'b0;
            led10 <= 1'b0;
        end


endmodule

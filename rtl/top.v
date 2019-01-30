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

    wire                      s_baudout;
    reg [7:0]                io_to_slave;
    wire [7:0]                s_uart_out;
    wire                      uart_int;
    reg uart_wr;
    reg uart_rd;

    uart_16750 uart_inst
        (
         .clk(clk_33M),
         .rst(~rstn),
         .baudce(1'b1),
         .cs(1'b1),
         .wr(uart_wr),
         .rd(uart_rd),
         .a(3'b0),
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
//          .probe_out1(uart_wr),  // output wire [0 : 0] probe_out1
//          .probe_out2(uart_rd)  // output wire [0 : 0] probe_out2
//        );

    // always @(posedge CLK100MHZ or negedge rstn)
    //     if(~rstn) begin
    //         cnt <= 1'b0;
    //     end else begin
    //         cnt <= cnt + 1;
    //     end

    always @(posedge s_baudout)
        begin
            if(s_uart_out == 8'h30) begin
                uart_wr <= 1'b1;
                io_to_slave <= 8'h31;
            end
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

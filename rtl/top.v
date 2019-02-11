`timescale 1ns/1ps

module top(CLK100MHZ, fpga_rst, mcu_rst, led8, led9, led10, uart0_rxd, uart0_txd);
   input CLK100MHZ;
   input fpga_rst;
   input mcu_rst;
   output reg led8;
   output reg led9;
   output reg led10;
   input      uart0_rxd;
   output     uart0_txd;
   wire       rstn;
   wire       clk_50M;
   wire       clk_33M;
   wire       pll_locked;
   reg        tx_data_avail;
   reg [7:0]  tx_data;
   reg [16*8-1:0] TxMsgBuf;
   reg [4:0]      TxMsgSize;
   reg [7:0]      s_uart_in;
   wire           s_baudout;
   reg [2:0]      s_uart_addr;
   reg            s_uart_cs;
   wire [7:0]     s_uart_out;
   reg [7:0]      rx_data;
   wire           uart_int;
   reg            s_wr_en;
   reg            s_rd_en;
   reg [3:0]      current_state;
   reg            dout_valid;
   reg [7:0]      uart_reg_lsr;

   localparam  STATE_UART_CONF_IDLE         = 0;
   localparam  STATE_UART_CONF_1            = 1;
   localparam  STATE_UART_CONF_2            = 2;
   localparam  STATE_UART_CONF_3            = 3;
   localparam  STATE_UART_CONF_4            = 4;
   localparam  STATE_UART_CONF_5            = 5;
   localparam  STATE_UART_CONF_6            = 6;
   localparam  STATE_UART_CONF_DONE         = 7;
   localparam  STATE_UART_READ_INIT         = 8;
   localparam  STATE_UART_READ_LSR          = 9;
   localparam  STATE_UART_READ_DATA         = 10;
   localparam  STATE_UART_DATA_WAIT         = 11;
   localparam  STATE_UART_WRITE_DATA        = 12;
   localparam  STATE_UART_LOOP              = 13;

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
   localparam UART_LSR_DR    = 8'h01;
   localparam UART_LSR_THRE  = 8'h20;


   assign rstn = fpga_rst & mcu_rst;

   IBUF CLK100MHZ_IBUF_inst
     (.I(CLK100MHZ),
      .O(CLK100MHZ_IBUF));


   xlnx_clk_gen xlnx_clk_gen_inst
     (
      .clk_out1(clk_50M),
      .clk_out2(clk_33M),
      .resetn(rstn),
      .locked(pll_locked),
      .clk_in1(CLK100MHZ_IBUF));


  xlnx_mig_7_ddr3 u_xlnx_mig_7_ddr3 (

    // Memory interface ports
    .ddr3_addr                      (ddr3_addr),  // output [13:0]      ddr3_addr
    .ddr3_ba                        (ddr3_ba),  // output [2:0]     ddr3_ba
    .ddr3_cas_n                     (ddr3_cas_n),  // output            ddr3_cas_n
    .ddr3_ck_n                      (ddr3_ck_n),  // output [0:0]       ddr3_ck_n
    .ddr3_ck_p                      (ddr3_ck_p),  // output [0:0]       ddr3_ck_p
    .ddr3_cke                       (ddr3_cke),  // output [0:0]        ddr3_cke
    .ddr3_ras_n                     (ddr3_ras_n),  // output            ddr3_ras_n
    .ddr3_reset_n                   (ddr3_reset_n),  // output          ddr3_reset_n
    .ddr3_we_n                      (ddr3_we_n),  // output         ddr3_we_n
    .ddr3_dq                        (ddr3_dq),  // inout [31:0]     ddr3_dq
    .ddr3_dqs_n                     (ddr3_dqs_n),  // inout [3:0]       ddr3_dqs_n
    .ddr3_dqs_p                     (ddr3_dqs_p),  // inout [3:0]       ddr3_dqs_p
    .init_calib_complete            (init_calib_complete),  // output           init_calib_complete

    .ddr3_cs_n                      (ddr3_cs_n),  // output [0:0]       ddr3_cs_n
    .ddr3_dm                        (ddr3_dm),  // output [3:0]     ddr3_dm
    .ddr3_odt                       (ddr3_odt),  // output [0:0]        ddr3_odt
    // Application interface ports
    .app_addr                       (app_addr),  // input [27:0]        app_addr
    .app_cmd                        (app_cmd),  // input [2:0]      app_cmd
    .app_en                         (app_en),  // input             app_en
    .app_wdf_data                   (app_wdf_data),  // input [255:0]       app_wdf_data
    .app_wdf_end                    (app_wdf_end),  // input                app_wdf_end
    .app_wdf_wren                   (app_wdf_wren),  // input               app_wdf_wren
    .app_rd_data                    (app_rd_data),  // output [255:0]       app_rd_data
    .app_rd_data_end                (app_rd_data_end),  // output           app_rd_data_end
    .app_rd_data_valid              (app_rd_data_valid),  // output         app_rd_data_valid
    .app_rdy                        (app_rdy),  // output           app_rdy
    .app_wdf_rdy                    (app_wdf_rdy),  // output           app_wdf_rdy
    .app_sr_req                     (app_sr_req),  // input         app_sr_req
    .app_ref_req                    (app_ref_req),  // input            app_ref_req
    .app_zq_req                     (app_zq_req),  // input         app_zq_req
    .app_sr_active                  (app_sr_active),  // output         app_sr_active
    .app_ref_ack                    (app_ref_ack),  // output           app_ref_ack
    .app_zq_ack                     (app_zq_ack),  // output            app_zq_ack
    .ui_clk                         (ui_clk),  // output            ui_clk
    .ui_clk_sync_rst                (ui_clk_sync_rst),  // output           ui_clk_sync_rst
    .app_wdf_mask                   (app_wdf_mask),  // input [31:0]        app_wdf_mask
    // System Clock Ports
    .sys_clk_p                       (sys_clk_p),  // input             sys_clk_p
    .sys_clk_n                       (sys_clk_n),  // input             sys_clk_n
    .sys_rst                        (sys_rst) // input sys_rst
    );


   uart_16750 uart_inst
     (
      .clk(clk_33M),
      .rst(~rstn),
      .baudce(1'b1),
      .cs(s_uart_cs),
      .wr(s_wr_en),
      .rd(s_rd_en),
      .a(s_uart_addr),
      .din(s_uart_in),
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

   // 115200 8N1 FIFO(8) INT
   always @ (posedge clk_33M or negedge rstn) begin
      if (~rstn) begin
         current_state <= STATE_UART_CONF_IDLE;
      end else begin
         case (current_state)
           STATE_UART_CONF_IDLE: begin

              TxMsgBuf      <= "Command Format\r\n";  // Align to 16 character format by appending space character
              TxMsgSize     <= 16;
              tx_data_avail <= 1;

              s_uart_in <= 8'h00;
              s_uart_cs <= 1'b0;
              s_wr_en <= 1'b0;
              s_rd_en <=  1'b0;
              dout_valid <= 1'b0;
              current_state <= STATE_UART_CONF_1;
           end
           STATE_UART_CONF_1: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_LCR;
                 s_uart_in <= 8'h83;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CONF_2;
              end
           end
           STATE_UART_CONF_2: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_DLL;
                 s_uart_in <= 8'h11;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CONF_3;
              end
           end
           STATE_UART_CONF_3: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_DLM;
                 s_uart_in <= 8'h00;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CONF_4;
              end
           end
           STATE_UART_CONF_4: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_LCR;
                 s_uart_in <= 8'h03;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CONF_5;
              end
           end
           STATE_UART_CONF_5: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_FCR;
                 s_uart_in <= 8'h00;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CONF_6;
              end
           end
           STATE_UART_CONF_6: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_IER;
                 s_uart_in <= 8'h03;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_READ_INIT;
              end
           end
           STATE_UART_READ_INIT: begin
              s_uart_cs <= 1'b0;
              s_rd_en <=  1'b0;
              current_state <= STATE_UART_READ_LSR;
           end
           STATE_UART_READ_LSR: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_LSR;
                 s_uart_cs <= 1'b1;
              end else if(~s_rd_en) begin
                 s_rd_en <= 1'b1;
                 dout_valid <= 1'b1;
              end else if(dout_valid) begin
                 uart_reg_lsr <= s_uart_out;
                 dout_valid <= 1'b0;
              end else begin
                 s_rd_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 if(uart_reg_lsr & UART_LSR_DR)
                   current_state <= STATE_UART_READ_DATA;
                 else if(uart_reg_lsr & UART_LSR_THRE) begin
                    tx_data_avail    <= 1;
                    tx_data          <= TxMsgBuf[16*8-1:15*8];
                    if(TxMsgSize == 0) begin
                       TxMsgBuf      <= "Command Format\r\n";
                       TxMsgSize     <= 16;
                    end else begin
                       TxMsgBuf      <= TxMsgBuf << 8;
                       TxMsgSize     <= TxMsgSize -1;
                    end
                    current_state <= STATE_UART_WRITE_DATA;
                 end

              end
           end
           STATE_UART_READ_DATA: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_RX;
                 s_uart_cs <= 1'b1;
              end else if(~s_rd_en) begin
                 s_rd_en <= 1'b1;
                 dout_valid <= 1'b1;
              end else if(dout_valid) begin
                 dout_valid <= 1'b0;
              end else begin
                 s_rd_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_DATA_WAIT;
              end
           end
           STATE_UART_DATA_WAIT: begin
              rx_data <= s_uart_out;
              current_state <= STATE_UART_READ_LSR;
           end
           STATE_UART_WRITE_DATA: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_TX;
                 s_uart_in <= tx_data;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_READ_LSR;
              end
           end
           STATE_UART_LOOP: begin
           end
           default: begin
              current_state <= STATE_UART_CONF_IDLE;
           end
         endcase
      end
   end

   always @(posedge clk_33M or negedge rstn)
     if(~rstn) begin
        led8 <= 1'b0;
        led9 <= 1'b0;
        led10 <= 1'b0;
     end else if(rx_data == 8'h20) begin
        led8 <= 1'b1;
        led9 <= 1'b1;
        led10 <= 1'b1;
     end else begin
        led8 <= 1'b0;
        led9 <= 1'b0;
        led10 <= 1'b0;
     end
endmodule

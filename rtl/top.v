`timescale 1ns/1ps

module top(CLK100MHZ, fpga_rst, mcu_rst, led_pass, led_fail, led_calib, uart_rx, uart_tx,
           ddr3_dq, ddr3_dqs_n, ddr3_dqs_p, ddr3_addr,
           ddr3_ba, ddr3_ras_n, ddr3_cas_n, ddr3_we_n, ddr3_reset_n, ddr3_ck_p, ddr3_ck_n, ddr3_cke,
           ddr3_cs_n, ddr3_dm, ddr3_odt
           );

   localparam DATA_WIDTH = 32;
   localparam ADDR_WIDTH = 28;
   localparam DDR_DQ_WIDTH = 32;
   localparam DDR_DQS_WIDTH = 4;
   localparam DDR_MASK_WIDTH = 32;

   localparam APP_ADDR_WIDTH = 28;
   localparam nCK_PER_CLK = 4;
   localparam APP_DATA_WIDTH        = 2 * nCK_PER_CLK * DATA_WIDTH;
   localparam APP_MASK_WIDTH        = APP_DATA_WIDTH / 8;

   localparam  STATE_UART_CFG_IDLE         = 0;
   localparam  STATE_UART_CFG_1            = 1;
   localparam  STATE_UART_CFG_2            = 2;
   localparam  STATE_UART_CFG_3            = 3;
   localparam  STATE_UART_CFG_4            = 4;
   localparam  STATE_UART_CFG_5            = 5;
   localparam  STATE_UART_CFG_6            = 6;
   localparam  STATE_UART_CFG_DONE         = 7;
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

   input CLK100MHZ;
   input fpga_rst;
   input mcu_rst;

   output led_pass;
   output led_fail;
   output led_calib;

   input  uart_rx;
   output uart_tx;

   inout [DDR_DQ_WIDTH-1:0] ddr3_dq;
   inout [DDR_DQS_WIDTH-1:0]  ddr3_dqs_n;
   inout [DDR_DQS_WIDTH-1:0]  ddr3_dqs_p;
   output [13:0] ddr3_addr;
   output [2:0]  ddr3_ba;
   output        ddr3_ras_n;
   output        ddr3_cas_n;
   output        ddr3_we_n;
   output        ddr3_reset_n;
   output        ddr3_ck_p;
   output        ddr3_ck_n;
   output        ddr3_cke;
   output        ddr3_cs_n;
   output [DDR_DQS_WIDTH-1:0] ddr3_dm;
   output        ddr3_odt;

   reg [APP_ADDR_WIDTH-1:0]    app_addr;
   reg [2:0]     app_cmd;
   (* keep = "true" *) reg app_en;
   (* keep = "true" *) reg [APP_DATA_WIDTH-1:0]app_wdf_data;
   wire          app_wdf_end = 1;
   wire [APP_MASK_WIDTH-1:0]   app_wdf_mask = 0;
   (* keep = "true" *) reg app_wdf_wren;
   (* keep = "true" *) wire [APP_DATA_WIDTH-1:0]app_rd_data;
   wire          app_rd_data_end;
   (* keep = "true" *) wire app_rd_data_valid;
   (* keep = "true" *) wire app_rdy;
   (* keep = "true" *) wire app_wdf_rdy;
   wire          app_sr_req = 0;
   wire          app_ref_req = 0;
   wire          app_zq_req = 0;
   wire          app_sr_active;
   wire          app_ref_ack;
   wire          app_zq_ack;
   (* keep = "true" *) wire ui_clk;
   wire          ui_clk_sync_rst;
   (* keep = "true" *) wire calib_done;
   reg [APP_DATA_WIDTH-1:0]   data_to_write = {32'hcafebabe, 32'h12345678, 32'hAA55AA55, 32'h55AA55AA, 32'hdeadbeef, 32'h87654321, 32'h55AA55AA, 32'hAA55AA55};
   reg [APP_DATA_WIDTH-1:0]   data_read_from_memory = 'h0;
   // reg [APP_DATA_WIDTH-1:0]   data_read_from_memory = {APP_DATA_WIDTH{1'b0}};

   reg           led_pass;
   reg           led_fail;
   wire          led_calib;

   wire          rstn;
   wire          clk_200m;
   wire          pll_locked;
   reg           tx_data_avail;
   reg [7:0]     tx_data;
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

   reg [31:0]     cnt = 0;

   assign resetn = fpga_rst & mcu_rst;

   IBUF CLK100MHZ_IBUF_inst
     (.I(CLK100MHZ),
      .O(CLK100MHZ_IBUF));

   xlnx_clk_gen u_clk
     (
      .clk_out1(clk_200m),
      .resetn(resetn),
      .locked(pll_locked),
      .clk_in1(CLK100MHZ_IBUF));

   xlnx_mig_7_ddr3 u_ddr3
     (
      .ddr3_addr                      (ddr3_addr),
      .ddr3_ba                        (ddr3_ba),
      .ddr3_cas_n                     (ddr3_cas_n),
      .ddr3_ck_n                      (ddr3_ck_n),
      .ddr3_ck_p                      (ddr3_ck_p),
      .ddr3_cke                       (ddr3_cke),
      .ddr3_ras_n                     (ddr3_ras_n),
      .ddr3_reset_n                   (ddr3_reset_n),
      .ddr3_we_n                      (ddr3_we_n),
      .ddr3_dq                        (ddr3_dq),
      .ddr3_dqs_n                     (ddr3_dqs_n),
      .ddr3_dqs_p                     (ddr3_dqs_p),
      .init_calib_complete            (calib_done),
      .ddr3_cs_n                      (ddr3_cs_n),
      .ddr3_dm                        (ddr3_dm),
      .ddr3_odt                       (ddr3_odt),
      .app_addr                       (app_addr),
      .app_cmd                        (app_cmd),
      .app_en                         (app_en),
      .app_wdf_data                   (app_wdf_data),
      .app_wdf_end                    (app_wdf_end),
      .app_wdf_wren                   (app_wdf_wren),
      .app_rd_data                    (app_rd_data),
      .app_rd_data_end                (app_rd_data_end),
      .app_rd_data_valid              (app_rd_data_valid),
      .app_rdy                        (app_rdy),
      .app_wdf_rdy                    (app_wdf_rdy),
      .app_sr_req                     (app_sr_req),
      .app_ref_req                    (app_ref_req),
      .app_zq_req                     (app_zq_req),
      .app_sr_active                  (app_sr_active),
      .app_ref_ack                    (app_ref_ack),
      .app_zq_ack                     (app_zq_ack),
      .ui_clk                         (ui_clk),
      .ui_clk_sync_rst                (ui_clk_sync_rst),
      .app_wdf_mask                   (app_wdf_mask),
      .sys_clk_i                      (clk_200m),
      .sys_rst                        (resetn));

   uart_16750 u_uart
     (
      .clk(ui_clk),
      .rst(~resetn),
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
      .sin(uart_rx),
      .sout(uart_tx));

   // 115200 8N1 FIFO(8) INT
   always @ (posedge ui_clk or negedge resetn) begin
      if (~resetn) begin
         current_state <= STATE_UART_CFG_IDLE;
      end else begin
         case (current_state)
           STATE_UART_CFG_IDLE: begin

              TxMsgBuf      <= "Command Format\r\n";
              TxMsgSize     <= 0;
              tx_data_avail <= 1;

              s_uart_in <= 8'h00;
              s_uart_cs <= 1'b0;
              s_wr_en <= 1'b0;
              s_rd_en <=  1'b0;
              dout_valid <= 1'b0;
              current_state <= STATE_UART_CFG_1;
           end
           STATE_UART_CFG_1: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_LCR;
                 s_uart_in <= 8'h83;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CFG_2;
              end
           end
           STATE_UART_CFG_2: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_DLL;
                 s_uart_in <= 8'h35;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CFG_3;
              end
           end
           STATE_UART_CFG_3: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_DLM;
                 s_uart_in <= 8'h00;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CFG_4;
              end
           end
           STATE_UART_CFG_4: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_LCR;
                 s_uart_in <= 8'h03;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CFG_5;
              end
           end
           STATE_UART_CFG_5: begin
              if(~s_uart_cs) begin
                 s_uart_addr <= UART_FCR;
                 s_uart_in <= 8'h00;
                 s_uart_cs <= 1'b1;
              end else if(~s_wr_en) begin
                 s_wr_en <= 1'b1;
              end else begin
                 s_wr_en <= 1'b0;
                 s_uart_cs <= 1'b0;
                 current_state <= STATE_UART_CFG_6;
              end
           end
           STATE_UART_CFG_6: begin
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
                    if(app_addr == 0) begin
                       TxMsgBuf[16*8-1:15*8] <= hex2char(cnt[31:28]);
                       TxMsgBuf[15*8-1:14*8] <= hex2char(cnt[27:24]);
                       TxMsgBuf[14*8-1:13*8] <= hex2char(cnt[23:20]);
                       TxMsgBuf[13*8-1:12*8] <= hex2char(cnt[19:16]);
                       TxMsgBuf[12*8-1:11*8] <= hex2char(cnt[15:12]);
                       TxMsgBuf[11*8-1:10*8] <= hex2char(cnt[11:8]);
                       TxMsgBuf[10*8-1:9*8]  <= hex2char(cnt[7:4]);
                       TxMsgBuf[9*8-1:8*8]   <= hex2char(cnt[3:0]);
                       TxMsgBuf[8*8-1:7*8]   <= "\r";
                       TxMsgBuf[7*8-1:6*8]   <= "\n";
                       TxMsgSize     <= 10;
                    end
                    if(TxMsgSize > 0) begin
                       tx_data_avail    <= 1;
                       tx_data          <= TxMsgBuf[16*8-1:15*8];

                       TxMsgBuf      <= TxMsgBuf << 8;
                       TxMsgSize     <= TxMsgSize - 1;
                       current_state <= STATE_UART_WRITE_DATA;
                    end else begin
                       tx_data_avail    <= 0;
                    end
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
              current_state <= STATE_UART_CFG_IDLE;
           end
         endcase
      end
   end

   localparam IDLE = 3'd0;
   localparam WRITE = 3'd1;
   localparam WRITE_DONE = 3'd2;
   localparam READ = 3'd3;
   localparam READ_DONE = 3'd4;
   localparam PARK = 3'd5;
   (* keep = "true" *) reg [2:0] state = IDLE;

   localparam CMD_WRITE = 3'b000;
   localparam CMD_READ = 3'b001;

   assign led_calib = calib_done;

   always @ (posedge ui_clk) begin
      if (ui_clk_sync_rst) begin
         state <= IDLE;
         app_en <= 0;
         app_wdf_wren <= 0;
         app_addr <= 0;
      end else begin
         case (state)
           IDLE: begin
              if (calib_done) begin
                 state <= WRITE;
              end
           end
           WRITE: begin
              if (app_rdy & app_wdf_rdy) begin
                 state <= WRITE_DONE;
                 app_en <= 1;
                 app_wdf_wren <= 1;
                 app_cmd <= CMD_WRITE;
                 app_wdf_data <= data_to_write;
              end
           end
           WRITE_DONE: begin
              if (app_rdy & app_en) begin
                 app_en <= 0;
              end
              if (app_wdf_rdy & app_wdf_wren) begin
                 app_wdf_wren <= 0;
              end
              if (~app_en & ~app_wdf_wren) begin
                 state <= READ;
              end
           end
           READ: begin
              if (app_rdy) begin
                 app_en <= 1;
                 app_cmd <= CMD_READ;
                 state <= READ_DONE;
              end
           end
           READ_DONE: begin
              if (app_rdy & app_en) begin
                 app_en <= 0;
              end
              if (app_rd_data_valid) begin
                 data_read_from_memory <= app_rd_data;
                 state <= PARK;
              end
           end
           PARK: begin
              if (data_to_write == data_read_from_memory) begin
                 app_addr <= app_addr + APP_DATA_WIDTH;
                 data_to_write[APP_DATA_WIDTH-1:0] <= {data_to_write[APP_DATA_WIDTH-9:0], data_to_write[APP_DATA_WIDTH-1:APP_DATA_WIDTH-8]};
                 state <= WRITE;
                 if(app_addr == 0) begin
                    cnt <= cnt + 1;
                    led_pass <= ~led_pass;
                 end
              end else if (data_to_write != data_read_from_memory) begin
                 led_fail <= 1;
              end
           end
           default: state <= IDLE;
         endcase
      end
   end

   // Hex to Asci Character
   function [7:0] hex2char;
      input [3:0] data_in;
      case (data_in)
        4'h0:  hex2char = 8'h30; // character '0'
        4'h1:  hex2char = 8'h31; // character '1'
        4'h2:  hex2char = 8'h32; // character '2'
        4'h3:  hex2char = 8'h33; // character '3'
        4'h4:  hex2char = 8'h34; // character '4'
        4'h5:  hex2char = 8'h35; // character '5'
        4'h6:  hex2char = 8'h36; // character '6'
        4'h7:  hex2char = 8'h37; // character '7'
        4'h8:  hex2char = 8'h38; // character '8'
        4'h9:  hex2char = 8'h39; // character '9'
        4'hA:  hex2char = 8'h41; // character 'A'
        4'hB:  hex2char = 8'h42; // character 'B'
        4'hC:  hex2char = 8'h43; // character 'C'
        4'hD:  hex2char = 8'h44; // character 'D'
        4'hE:  hex2char = 8'h45; // character 'E'
        4'hF:  hex2char = 8'h46; // character 'F'
      endcase
   endfunction
endmodule

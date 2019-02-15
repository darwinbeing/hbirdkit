
`timescale 1ns/10ps

// 100Mhz clock = 10ns period
`define CLOCK_PERIOD 10

module test_hbe200();
   localparam RESET_LEVEL = 1'b0;
   // Declare inputs as regs and outputs as wires
   reg CLK100MHZ;
   reg fpga_rst;
   reg mcu_rst;
   wire led_pass;
   wire led_fail;
   wire led_calib;
   reg  uart_rx;
   wire uart_tx;

   // Initialize all variables
   initial begin
      $monitor ("%g\t %b %b %b",
                $time, CLK100MHZ, uart_rx, uart_tx);
      CLK100MHZ = 1;
      uart_rx = 1;
      fpga_rst = ~RESET_LEVEL;
      mcu_rst = ~RESET_LEVEL;
      repeat (2) @ (negedge CLK100MHZ);
      fpga_rst = RESET_LEVEL;
      mcu_rst = RESET_LEVEL;
      repeat (32) @ (negedge CLK100MHZ);
      fpga_rst = ~RESET_LEVEL;
      mcu_rst = ~RESET_LEVEL;

      // #2000 $finish;      // Terminate simulation
   end

   // Clock generator
   always
     begin
        #((`CLOCK_PERIOD)/2) CLK100MHZ <= ~CLK100MHZ;
     end

   top mytop(.CLK100MHZ(CLK100MHZ),
             .fpga_rst(fpga_rst),
             .mcu_rst(mcu_rst),
             .led_pass(led_fail),
             .led_fail(led_fail),
             .led_calib(led_calib),
             .uart_rx(uart_rx),
             .uart_tx(uart_tx));

endmodule

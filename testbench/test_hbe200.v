
`timescale 1ns/10ps

// 100Mhz clock = 10ns period
`define CLOCK_PERIOD 10

module test_hbe200();
    localparam RESET_LEVEL = 1'b1;
    // Declare inputs as regs and outputs as wires
   reg CLK100MHZ;
   reg fpga_rst;
   reg mcu_rst;
   wire led8;
   wire led9;
   wire led10;
   wire uart0_rxd;
   wire uart0_txd;

    // Initialize all variables
    initial begin
        $monitor ("%g\t %b %b %b",
              $time, CLK100MHZ, uart0_rxd, uart0_txd);
        CLK100MHZ = 1;
        fpga_rst = ~RESET_LEVEL;
        mcu_rst = ~RESET_LEVEL;
       repeat (2) @ (negedge CLK100MHZ);
        fpga_rst = RESET_LEVEL;
        mcu_rst = RESET_LEVEL;
        repeat (32) @ (negedge CLK100MHZ);
        fpga_rst = ~RESET_LEVEL;
        mcu_rst = ~RESET_LEVEL;

        #2000 $finish;      // Terminate simulation
    end

    // Clock generator
    always
      begin
          #((`CLOCK_PERIOD)/2) CLK100MHZ <= ~CLK100MHZ;
      end

   top mytop(CLK100MHZ,
             fpga_rst,
             mcu_rst,
             led8,
             led9,
             led10,
             uart0_rxd,
             uart0_txd);

endmodule

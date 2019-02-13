open_checkpoint post_route.dcp

# Write a bitstream for the current design
write_bitstream -force hbe200.bit

write_debug_probes -file hbe200.ltx -force

# Save the timing delays for cells in the design in SDF format
write_sdf -force hbe200.sdf

# Export the current netlist in verilog format
write_verilog -mode timesim -force hbe200.v

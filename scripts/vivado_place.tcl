open_checkpoint post_opt.dcp

# Place the current design
place_design -directive Explore

# Optimize the current placed netlist
phys_opt_design -directive Explore

# Optimize dynamic power using intelligent clock gating
power_opt_design

# Checkpoint the current design
write_checkpoint -force post_place

open_checkpoint post_syn.dcp

# Optimize the netlist
opt_design -directive Explore

# Checkpoint the current design
write_checkpoint -force post_opt

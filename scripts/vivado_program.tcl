set HW_SERVER [lindex $argv 0]

set bitfile hbe200.bit

set SERVER   localhost
set PORT     3121

# set device $::env(XILINX_PART)
set device xc7a100t_0

open_hw
# connect_hw_server -url ${HW_SERVER}
connect_hw_server -url ${SERVER}:${PORT} -verbose

# current_hw_target  [get_hw_targets */xilinx_tcf/Digilent/210249854623]
# set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210249854623]
open_hw_target

current_hw_device [get_hw_devices ${device}]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices ${device}] 0]

set_property PROGRAM.FILE {hbe200.bit} [get_hw_devices ${device}]
refresh_hw_device [lindex [get_hw_devices ${device}] 0]

program_hw_devices [get_hw_devices ${device}]
refresh_hw_device [lindex [get_hw_devices ${device}] 0]

## close target
close_hw_target

## terminate the connection when done
disconnect_hw_server  [current_hw_server]

## close hardware
close_hw

set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_clk_gen

create_project -force $ipName . -part $partNumber
# set_property board_part $boardName [current_project]

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name $ipName
set_property -dict [list \
  CONFIG.PRIMITIVE {MMCM} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
  CONFIG.CLKOUT1_USED {true} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT3_USED {true} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {33.000} \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200.000} \
  ] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1

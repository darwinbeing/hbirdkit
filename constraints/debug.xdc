
# set_property SEVERITY {Warning} [get_drc_checks LUTLP-1]
# set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
# set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

# set_property MARK_DEBUG true [get_nets clk_33M]
# set_property MARK_DEBUG true [get_nets CLK100MHZ_IBUF]
# set_property MARK_DEBUG true [get_nets {uart_inst/A[1]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/A[2]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/A[0]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[0]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[1]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[2]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[3]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[4]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[5]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[6]}]
# set_property MARK_DEBUG true [get_nets {uart_inst/DOUT[7]}]
# set_property MARK_DEBUG true [get_nets uart_inst/iRXFIFORead]
# set_property MARK_DEBUG true [get_nets uart_inst/RD]
# set_property MARK_DEBUG true [get_nets uart_inst/SIN]

# create_debug_core u_ila_0 ila
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
# set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
# set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
# set_property C_DATA_DEPTH 16384 [get_debug_cores u_ila_0]
# set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
# set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
# set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
# set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
# set_property port_width 1 [get_debug_ports u_ila_0/clk]
# connect_debug_port u_ila_0/clk [get_nets [list CLK100MHZ_IBUF]]

# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
# set_property port_width 1 [get_debug_ports u_ila_0/probe0]
# connect_debug_port u_ila_0/probe0 [get_nets [list clk_33M]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
# set_property port_width 1 [get_debug_ports u_ila_0/probe1]
# connect_debug_port u_ila_0/probe1 [get_nets [list uart_inst/RD]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
# set_property port_width 1 [get_debug_ports u_ila_0/probe2]
# connect_debug_port u_ila_0/probe2 [get_nets [list uart_inst/iRXFIFORead]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
# set_property port_width 3 [get_debug_ports u_ila_0/probe3]
# connect_debug_port u_ila_0/probe3 [get_nets [list {uart_inst/A[0]} {uart_inst/A[1]} {uart_inst/A[2]}]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
# set_property port_width 8 [get_debug_ports u_ila_0/probe4]
# connect_debug_port u_ila_0/probe4 [get_nets [list {uart_inst/DOUT[0]} {uart_inst/DOUT[1]} {uart_inst/DOUT[2]} {uart_inst/DOUT[3]} {uart_inst/DOUT[4]} {uart_inst/DOUT[5]} {uart_inst/DOUT[6]} {uart_inst/DOUT[7]}]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
# set_property port_width 1 [get_debug_ports u_ila_0/probe5]
# connect_debug_port u_ila_0/probe5 [get_nets [list uart_inst/SIN]]

# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets CLK100MHZ_IBUF]


# set_property MARK_DEBUG true [get_nets ui_clk]
# set_property MARK_DEBUG true [get_nets app_en]
# set_property MARK_DEBUG true [get_nets calib_done]
# set_property MARK_DEBUG true [get_nets app_wdf_wren]
# set_property MARK_DEBUG true [get_nets app_rd_data_valid]
# set_property MARK_DEBUG true [get_nets app_rdy]
# set_property MARK_DEBUG true [get_nets app_wdf_rdy]
# set_property MARK_DEBUG true [get_nets {state[*]}]


# create_debug_core u_ila_0 ila
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
# set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
# set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
# set_property C_DATA_DEPTH 8192 [get_debug_cores u_ila_0]
# set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
# set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
# set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
# set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
# set_property port_width 1 [get_debug_ports u_ila_0/clk]
# connect_debug_port u_ila_0/clk [get_nets [list ui_clk]]

# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
# set_property port_width 1 [get_debug_ports u_ila_0/probe0]
# connect_debug_port u_ila_0/probe0 [get_nets [list app_en]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
# set_property port_width 1 [get_debug_ports u_ila_0/probe1]
# connect_debug_port u_ila_0/probe1 [get_nets [list calib_done]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
# set_property port_width 1 [get_debug_ports u_ila_0/probe2]
# connect_debug_port u_ila_0/probe2 [get_nets [list app_wdf_wren]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
# set_property port_width 1 [get_debug_ports u_ila_0/probe3]
# connect_debug_port u_ila_0/probe3 [get_nets [list app_rd_data_valid]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
# set_property port_width 1 [get_debug_ports u_ila_0/probe4]
# connect_debug_port u_ila_0/probe4 [get_nets [list app_rdy]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
# set_property port_width 1 [get_debug_ports u_ila_0/probe5]
# connect_debug_port u_ila_0/probe5 [get_nets [list app_wdf_rdy]]

# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
# set_property port_width 3 [get_debug_ports u_ila_0/probe6]
# connect_debug_port u_ila_0/probe6 [get_nets [list {state[0]} {state[1]} {state[2]}]]

# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets ui_clk]

proj = "hbe200"


rtl_dir := rtl
create_ip_dir := create_ip
tcl_dir := scripts
xdc_dir := constraints
cores_dir := cores

export XILINX_PART=xc7a100tfgg484-2
export XILINX_BOARD=hbe200

RTL_SRC := \
        rtl/top.v \
        rtl/uart/slib_clock_div.vhd \
        rtl/uart/slib_counter.vhd \
        rtl/uart/slib_edge_detect.vhd \
        rtl/uart/slib_fifo.vhd \
        rtl/uart/slib_input_filter.vhd \
        rtl/uart/slib_input_sync.vhd \
        rtl/uart/slib_mv_filter.vhd \
        rtl/uart/uart_16750.vhd \
        rtl/uart/uart_baudgen.vhd \
        rtl/uart/uart_interrupt.vhd \
        rtl/uart/uart_receiver.vhd \
        rtl/uart/uart_transmitter.vhd



XDC_SRC := \
        constraints/top.xdc

TCL_SRC := \
        scripts/vivado_createprj.tcl  \
        scripts/vivado_synth.tcl      \
        scripts/vivado_place.tcl      \
        scripts/vivado_route.tcl      \
        scripts/vivado_bitstream.tcl

IP_SRC := \
        ip_catalog/ila_0/ila_0.xci                           \
        ip_catalog/pcie_afifo/pcie_afifo.xci                 \
        ip_catalog/eth_afifo/eth_afifo.xci                   \
        ip_catalog/axi_10g_ethernet_0/axi_10g_ethernet_0.xci

IP_SRC_IPGEN := \
        create_ip/xlnx_ila/ip/xlnx_ila.xci \
        create_ip/xlnx_clk_gen/ip/xlnx_clk_gen.xci

CREATE_IP_SRC := \
        create_ip/xlnx_ila/Makefile         \
        create_ip/xlnx_ila/tcl/run.tcl

HW_SERVER := hw_server

all: bitstream

generate_ipsrcs:
	echo "xxx"
	# make -C $(create_ip_dir)/xlnx_ila
	# make -C $(create_ip_dir)/xlnx_clk_gen

build_setup: generate_ipsrcs $(rtl_dir) $(create_ip_dir) $(tcl_dir) $(xdc_dir)

prj: $(proj).xpr
$(proj).xpr: build_setup
	vivado -mode batch -source scripts/vivado_createprj.tcl -log createprj_log.txt -nojournal -tclargs "$(PKG_SRC) $(RTL_SRC_NOSIM) $(RTL_SRC_IPGEN) $(RTL_SRC)" "$(IP_SRC_IPGEN)" "$(XDC_SRC)"

synth: post_syn.dcp
post_syn.dcp: build_setup
	vivado -mode batch -source scripts/vivado_synth.tcl -log syn_log.txt -nojournal -tclargs "$(PKG_SRC) $(RTL_SRC_NOSIM) $(RTL_SRC_IPGEN) $(RTL_SRC)" "$(IP_SRC_IPGEN)" "$(XDC_SRC)"

place: post_place.dcp
post_place.dcp: post_syn.dcp
	vivado -mode batch -source scripts/vivado_place.tcl -log place_log.txt -nojournal

route: post_route.dcp
post_route.dcp: post_place.dcp
	vivado -mode batch -source scripts/vivado_route.tcl -log route_log.txt -nojournal

bitstream: $(proj).bit
$(proj).bit: post_route.dcp
	vivado -mode batch -source scripts/vivado_bitstream.tcl -log bitstream_log.txt -nojournal

program: $(proj).bit $(HW_SERVER)
	vivado -mode batch -source scripts/vivado_program.tcl -log program_log.txt -nojournal -tclargs "`cat $(HW_SERVER)`"

load: $(proj).bit
	./script/xprog.sh load $(proj).bit

ila:
	test -e csv || mkdir csv
	vivado -mode batch -source scripts/vivado_ila.tcl -tclargs "`cat $(HW_SERVER)`"

ila2:
	test -e csv || mkdir csv
	vivado -mode batch -source scripts/vivado_ila2.tcl -tclargs "`cat $(HW_SERVER)`"

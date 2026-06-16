# QuestaSim run script — FIFO UVM Verification
# Usage: vsim -do sim/run_sim.tcl
# To change test: edit +UVM_TESTNAME below
#   Options: fifo_write_test | fifo_wr_rd_test | fifo_rand_test

vlib work
vmap work work

# Compile RTL
vlog -sv ../rtl/fifo.sv

# Compile SVA
vlog -sv ../sva/fifo_assertions.sv

# Compile testbench (tb_top includes all UVM files via `include)
vlog -sv +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm_pkg.sv \
         +incdir+../tb ../tb/tb_top.sv

# Simulate — change +UVM_TESTNAME to run a different test
vsim -t 1ns -voptargs="+acc" \
     +UVM_TESTNAME=fifo_rand_test \
     +UVM_VERBOSITY=UVM_MEDIUM \
     work.tb_top

log -r /*

add wave -divider "Clock/Reset"
add wave /tb_top/clk
add wave /tb_top/fif/rst

add wave -divider "FIFO Interface"
add wave /tb_top/fif/wr
add wave /tb_top/fif/rd
add wave /tb_top/fif/din
add wave /tb_top/fif/dout
add wave /tb_top/fif/full
add wave /tb_top/fif/empty

add wave -divider "DUT Internals"
add wave /tb_top/dut/wptr
add wave /tb_top/dut/rptr
add wave /tb_top/dut/cnt

run -all
coverage report -assert
quit -sim

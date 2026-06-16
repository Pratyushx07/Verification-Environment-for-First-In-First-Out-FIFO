`timescale 1ns/1ps

// Top-level testbench — instantiates DUT and interface, starts UVM
// Author: Pratyush Jha

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "fifo_if.sv"
`include "fifo_tx.sv"
`include "fifo_seq.sv"
`include "fifo_driver.sv"
`include "fifo_monitor.sv"
`include "fifo_scoreboard.sv"
`include "fifo_agent.sv"
`include "fifo_env.sv"
`include "fifo_test.sv"

module tb_top;

    logic clk;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Interface instance
    fifo_if fif(.clk(clk));

    // DUT instance
    fifo dut (
        .clk   (fif.clk),
        .rst   (fif.rst),
        .wr    (fif.wr),
        .rd    (fif.rd),
        .din   (fif.din),
        .dout  (fif.dout),
        .full  (fif.full),
        .empty (fif.empty)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        // Set virtual interface in config_db so all components can get it
        uvm_config_db #(virtual fifo_if)::set(null, "uvm_test_top.*", "vif", fif);

        // Run the test specified via +UVM_TESTNAME
        run_test();
    end

endmodule

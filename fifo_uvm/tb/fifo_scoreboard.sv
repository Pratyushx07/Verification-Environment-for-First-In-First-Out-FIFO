`timescale 1ns/1ps

// FIFO UVM scoreboard — reference model + checker
// Author: Pratyush Jha

class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    // Analysis imp — receives transactions written by monitor
    uvm_analysis_imp #(fifo_tx, fifo_scoreboard) ap;

    // Reference model: queue mimics FIFO behavior
    bit [7:0] ref_queue [$];

    int pass_count = 0;
    int fail_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
    endfunction

    // Called by monitor via ap.write()
    function void write(fifo_tx tx);
        bit [7:0] expected;

        if (tx.wr && !tx.full) begin
            ref_queue.push_front(tx.din);
            `uvm_info("SCO", $sformatf("WRITE din=%0d  queue_size=%0d", tx.din, ref_queue.size()), UVM_MEDIUM)
        end

        if (tx.rd && !tx.empty) begin
            if (ref_queue.size() == 0) begin
                `uvm_error("SCO", "Read when reference queue is empty — possible scoreboard sync issue")
                return;
            end
            expected = ref_queue.pop_back();
            if (tx.dout === expected) begin
                `uvm_info("SCO", $sformatf("PASS  dout=%0d  expected=%0d", tx.dout, expected), UVM_MEDIUM)
                pass_count++;
            end else begin
                `uvm_error("SCO", $sformatf("FAIL  dout=%0d  expected=%0d", tx.dout, expected))
                fail_count++;
            end
        end

        if (tx.wr && tx.full)
            `uvm_info("SCO", "Write attempt on full FIFO — correctly blocked", UVM_MEDIUM)

        if (tx.rd && tx.empty)
            `uvm_info("SCO", "Read attempt on empty FIFO — correctly blocked", UVM_MEDIUM)

    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCO", $sformatf("PASS=%0d  FAIL=%0d", pass_count, fail_count), UVM_NONE)
        if (fail_count == 0)
            `uvm_info("SCO", "ALL CHECKS PASSED", UVM_NONE)
        else
            `uvm_error("SCO", $sformatf("%0d CHECK(S) FAILED", fail_count))
    endfunction

endclass

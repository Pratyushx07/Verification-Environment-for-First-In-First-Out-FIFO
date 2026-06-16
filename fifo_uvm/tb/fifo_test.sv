`timescale 1ns/1ps

// FIFO UVM tests
// Author: Pratyush Jha

// Base test — creates env, sets virtual interface
class fifo_base_test extends uvm_test;
    `uvm_component_utils(fifo_base_test)

    fifo_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction

    // All tests share this reset task
    task reset_dut(virtual fifo_if vif);
        vif.rst <= 1;
        vif.wr  <= 0;
        vif.rd  <= 0;
        vif.din <= 0;
        repeat(5) @(posedge vif.clk);
        vif.rst <= 0;
        repeat(2) @(posedge vif.clk);
    endtask

endclass

// Test 1: Write-only — fill FIFO completely
class fifo_write_test extends fifo_base_test;
    `uvm_component_utils(fifo_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_write_seq seq;
        virtual fifo_if vif;

        phase.raise_objection(this);

        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Cannot get vif");

        reset_dut(vif);

        seq = fifo_write_seq::type_id::create("seq");
        seq.num_items = 16;
        seq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass

// Test 2: Write then read — full fill followed by full drain
class fifo_wr_rd_test extends fifo_base_test;
    `uvm_component_utils(fifo_wr_rd_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_write_seq wseq;
        fifo_read_seq  rseq;
        virtual fifo_if vif;

        phase.raise_objection(this);

        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Cannot get vif");

        reset_dut(vif);

        wseq = fifo_write_seq::type_id::create("wseq");
        wseq.num_items = 16;
        wseq.start(env.agent.seqr);

        rseq = fifo_read_seq::type_id::create("rseq");
        rseq.num_items = 16;
        rseq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass

// Test 3: Constrained-random — 30 random write/read transactions
class fifo_rand_test extends fifo_base_test;
    `uvm_component_utils(fifo_rand_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_rand_seq seq;
        virtual fifo_if vif;

        phase.raise_objection(this);

        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Cannot get vif");

        reset_dut(vif);

        seq = fifo_rand_seq::type_id::create("seq");
        seq.num_items = 30;
        seq.start(env.agent.seqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass

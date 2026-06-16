`timescale 1ns/1ps

// FIFO UVM monitor — observes DUT interface and sends transactions to scoreboard
// Author: Pratyush Jha

class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;

    // Analysis port — sends observed transactions to scoreboard
    uvm_analysis_port #(fifo_tx) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Virtual interface not found in config_db");
    endfunction

    task run_phase(uvm_phase phase);
        fifo_tx tx;
        forever begin
            tx = fifo_tx::type_id::create("tx");
            // Sample after driver has applied stimulus and DUT has responded
            @(posedge vif.clk);
            @(posedge vif.clk);
            tx.wr    = vif.wr;
            tx.rd    = vif.rd;
            tx.din   = vif.din;
            tx.full  = vif.full;
            tx.empty = vif.empty;
            @(posedge vif.clk);
            tx.dout  = vif.dout;
            `uvm_info("MON", tx.convert2string(), UVM_HIGH)
            ap.write(tx);  // send to scoreboard
        end
    endtask

endclass

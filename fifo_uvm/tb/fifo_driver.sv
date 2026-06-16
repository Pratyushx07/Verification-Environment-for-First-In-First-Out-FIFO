`timescale 1ns/1ps

// FIFO UVM driver — drives DUT interface from sequence items
// Author: Pratyush Jha

class fifo_driver extends uvm_driver #(fifo_tx);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Virtual interface not found in config_db");
    endfunction

    task run_phase(uvm_phase phase);
        fifo_tx tx;
        // Drive idle state first
        vif.wr  <= 0; vif.rd <= 0; vif.din <= 0;
        forever begin
            seq_item_port.get_next_item(tx);  // blocking get from sequencer
            drive(tx);
            seq_item_port.item_done();        // signal sequencer: ready for next
        end
    endtask

    task drive(fifo_tx tx);
        @(posedge vif.clk);
        vif.wr  <= tx.wr;
        vif.rd  <= tx.rd;
        vif.din <= tx.din;
        @(posedge vif.clk);
        vif.wr  <= 0;
        vif.rd  <= 0;
    endtask

endclass

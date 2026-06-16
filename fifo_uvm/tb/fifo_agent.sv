`timescale 1ns/1ps

// FIFO UVM agent — bundles sequencer, driver, and monitor
// Author: Pratyush Jha

class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)

    fifo_driver                drv;
    fifo_monitor               mon;
    uvm_sequencer #(fifo_tx)   seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seqr = uvm_sequencer #(fifo_tx)::type_id::create("seqr", this);
        drv  = fifo_driver::type_id::create("drv",  this);
        mon  = fifo_monitor::type_id::create("mon",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
        // Connect driver's seq_item_port to sequencer's seq_item_export
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass

`timescale 1ns/1ps

// FIFO UVM environment — top-level container
// Author: Pratyush Jha

class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)

    fifo_agent      agent;
    fifo_scoreboard sco;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = fifo_agent::type_id::create("agent", this);
        sco   = fifo_scoreboard::type_id::create("sco", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        // Connect monitor's analysis port to scoreboard's analysis imp
        agent.mon.ap.connect(sco.ap);
    endfunction

endclass

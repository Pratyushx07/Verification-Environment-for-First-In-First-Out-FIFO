`timescale 1ns/1ps

// fifo_tx: UVM sequence item — one FIFO transaction
// Author: Pratyush Jha

class fifo_tx extends uvm_sequence_item;
    `uvm_object_utils(fifo_tx)

    // Randomizable stimulus fields
    rand bit       wr;
    rand bit       rd;
    rand bit [7:0] din;

    // Observed output fields (set by monitor)
    bit [7:0] dout;
    bit       full;
    bit       empty;

    // 50/50 write vs read by default
    constraint c_oper {
        wr dist {1 :/ 50, 0 :/ 50};
        rd == ~wr;  // never simultaneous read+write in basic test
    }

    // din non-zero to make data mismatches visible
    constraint c_din { din inside {[1:255]}; }

    function new(string name = "fifo_tx");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("wr=%0b rd=%0b din=%0d dout=%0d full=%0b empty=%0b",
                          wr, rd, din, dout, full, empty);
    endfunction

endclass

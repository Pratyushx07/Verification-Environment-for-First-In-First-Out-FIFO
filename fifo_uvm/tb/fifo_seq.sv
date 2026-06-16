`timescale 1ns/1ps

// FIFO sequences
// Author: Pratyush Jha

// Write-only sequence — fills the FIFO
class fifo_write_seq extends uvm_sequence #(fifo_tx);
    `uvm_object_utils(fifo_write_seq)

    int num_items = 16;

    function new(string name = "fifo_write_seq");
        super.new(name);
    endfunction

    task body();
        fifo_tx tx;
        repeat (num_items) begin
            tx = fifo_tx::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize() with { wr == 1; rd == 0; })
                else `uvm_error("SEQ", "Randomize failed");
            finish_item(tx);
        end
    endtask
endclass

// Read-only sequence — drains the FIFO
class fifo_read_seq extends uvm_sequence #(fifo_tx);
    `uvm_object_utils(fifo_read_seq)

    int num_items = 16;

    function new(string name = "fifo_read_seq");
        super.new(name);
    endfunction

    task body();
        fifo_tx tx;
        repeat (num_items) begin
            tx = fifo_tx::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize() with { wr == 0; rd == 1; })
                else `uvm_error("SEQ", "Randomize failed");
            finish_item(tx);
        end
    endtask
endclass

// Random sequence — 50/50 write/read, constrained random
class fifo_rand_seq extends uvm_sequence #(fifo_tx);
    `uvm_object_utils(fifo_rand_seq)

    int num_items = 30;

    function new(string name = "fifo_rand_seq");
        super.new(name);
    endfunction

    task body();
        fifo_tx tx;
        repeat (num_items) begin
            tx = fifo_tx::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize())
                else `uvm_error("SEQ", "Randomize failed");
            finish_item(tx);
        end
    endtask
endclass

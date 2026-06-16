`timescale 1ns/1ps

// SVA assertions for FIFO DUT
// Author: Pratyush Jha

module fifo_assertions (
    input logic       clk,
    input logic       rst,
    input logic       wr,
    input logic       rd,
    input logic [7:0] din,
    input logic [7:0] dout,
    input logic       full,
    input logic       empty
);

    // No write when full — data must not be accepted
    property p_no_write_when_full;
        @(posedge clk) disable iff (rst)
        (wr && full) |=> full;
    endproperty
    a_no_write_when_full: assert property (p_no_write_when_full)
        else $error("[SVA] Write to full FIFO changed full flag unexpectedly");

    // No read when empty — empty must stay asserted
    property p_no_read_when_empty;
        @(posedge clk) disable iff (rst)
        (rd && empty) |=> empty;
    endproperty
    a_no_read_when_empty: assert property (p_no_read_when_empty)
        else $error("[SVA] Read from empty FIFO changed empty flag unexpectedly");

    // After reset, FIFO must be empty
    property p_reset_empty;
        @(posedge clk)
        $rose(rst) |=> empty;
    endproperty
    a_reset_empty: assert property (p_reset_empty)
        else $error("[SVA] FIFO not empty after reset");

    // After reset, FIFO must not be full
    property p_reset_not_full;
        @(posedge clk)
        $rose(rst) |=> !full;
    endproperty
    a_reset_not_full: assert property (p_reset_not_full)
        else $error("[SVA] FIFO full after reset");

    // full and empty are mutually exclusive
    property p_full_empty_mutex;
        @(posedge clk) disable iff (rst)
        not (full && empty);
    endproperty
    a_full_empty_mutex: assert property (p_full_empty_mutex)
        else $error("[SVA] full and empty both asserted simultaneously");

    // A valid write must eventually cause empty to deassert
    property p_write_clears_empty;
        @(posedge clk) disable iff (rst)
        (wr && !full) |=> !empty;
    endproperty
    a_write_clears_empty: assert property (p_write_clears_empty)
        else $error("[SVA] empty not cleared after successful write");

    // Cover: FIFO reaches full
    cp_full:        cover property (@(posedge clk) disable iff (rst) full);
    // Cover: FIFO reaches empty after writes
    cp_empty:       cover property (@(posedge clk) disable iff (rst) $fell(empty));
    // Cover: simultaneous read and write (cnt stays same)
    cp_sim_rd_wr:   cover property (@(posedge clk) disable iff (rst) wr && rd && !full && !empty);

endmodule

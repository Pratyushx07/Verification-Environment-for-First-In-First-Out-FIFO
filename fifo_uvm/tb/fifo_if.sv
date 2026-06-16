`timescale 1ns/1ps

// Interface for FIFO DUT
// Author: Pratyush Jha

interface fifo_if (input logic clk);
    logic       rst;
    logic       wr;
    logic       rd;
    logic [7:0] din;
    logic [7:0] dout;
    logic       full;
    logic       empty;
endinterface

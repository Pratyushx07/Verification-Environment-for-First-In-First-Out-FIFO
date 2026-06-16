`timescale 1ns/1ps

// Synchronous FIFO — depth 16, width 8-bit
// Author: Pratyush Jha

module fifo (
    input  logic       clk,
    input  logic       rst,
    input  logic       wr,
    input  logic       rd,
    input  logic [7:0] din,
    output logic [7:0] dout,
    output logic       full,
    output logic       empty
);

    logic [7:0] mem [0:15];
    logic [3:0] wptr, rptr;
    logic [4:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            wptr <= 0; rptr <= 0; cnt <= 0; dout <= 0;
        end else begin
            if (wr && !full) begin
                mem[wptr] <= din;
                wptr      <= wptr + 1;
                cnt       <= cnt + 1;
            end
            if (rd && !empty) begin
                dout <= mem[rptr];
                rptr <= rptr + 1;
                cnt  <= cnt - 1;
            end
        end
    end

    assign full  = (cnt == 16);
    assign empty = (cnt == 0);

endmodule

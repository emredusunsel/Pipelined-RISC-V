// CURRENTLY ONLY LW SW
// LATER ADD LB, LH, SB, SH

`timescale 1ps/1ps

module data_memory #(
    parameter int DEPTH = 256
) (
    input   logic           clk,
    input   logic           we_i,
    input   logic   [31:0]  addr_i,
    input   logic   [31:0]  wr_data_i,
    output  logic   [31:0]  rd_data_o
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    logic [31:0] mem [DEPTH];

    always_ff @(posedge clk) begin : dm_write_block
        if (we_i)
            mem[addr_i[ADDR_WIDTH+1:2]] <= wr_data_i;
    end

    assign rd_data_o = mem[addr_i[ADDR_WIDTH+1:2]];

endmodule

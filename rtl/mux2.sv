`timescale 1ps/1ps

module mux2 #(
    parameter int WIDTH  = 32
) (
    input   logic   [WIDTH-1:0] data0_i,
    input   logic   [WIDTH-1:0] data1_i,
    input   logic               sel_i,
    output  logic   [WIDTH-1:0] data_o
);

    assign data_o = sel_i ? data1_i : data0_i;

endmodule

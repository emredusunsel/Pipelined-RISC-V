`timescale 1ps/1ps

module pc_plus4 (
    input   logic   [31:0]  pc_i,
    output  logic   [31:0]  pc_plus4_o
);

    assign pc_plus4_o = pc_i + 32'd4;

endmodule

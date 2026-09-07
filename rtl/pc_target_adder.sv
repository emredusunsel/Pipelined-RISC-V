`timescale 1ps/1ps

module pc_target_adder (
    input   logic   [31:0]  pc_i,
    input   logic   [31:0]  imm_i,
    output  logic   [31:0]  pc_target_o
);

    assign pc_target_o = pc_i + imm_i;

endmodule

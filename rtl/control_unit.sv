`timescale 1ps/1ps

module control_unit (
    input   logic   [6:0]   opcode_i,
    input   logic   [2:0]   funct3_i,
    input   logic           funct7_5_i,
    output  logic           reg_write_o,
    output  logic   [1:0]   result_src_o,
    output  logic           mem_write_o,
    output  logic           jump_o,
    output  logic           branch_o,
    output  logic           alu_src_o,
    output  logic   [2:0]   imm_src_o,
    output  logic   [3:0]   alu_control_o
);



endmodule

// PCSrcE should be top module logic
// dont use zero_i in here
// jump and branch should be outputted
// so that they cane be used in Exetuce stage
// to calculate PCSrcE

`timescale 1ps/1ps

module control_unit (
    input   logic   [6:0]   opcode_i,
    input   logic   [2:0]   funct3_i,
    input   logic           funct7_5_i,
    output  logic           reg_write_o,
    output  logic   [1:0]   result_src_o,
    output  logic           mem_write_o,
    output  logic           alu_src_o,
    output  logic   [1:0]   imm_src_o,
    output  logic   [2:0]   alu_control_o,
    output  logic           jump_o,
    output  logic           branch_o
);

    logic [1:0] alu_op_wire;

    main_decoder main_dec_inst (
        .opcode_i(opcode_i),
        .branch_o(branch_o),
        .jump_o(jump_o),
        .result_src_o(result_src_o),
        .mem_write_o(mem_write_o),
        .alu_src_o(alu_src_o),
        .imm_src_o(imm_src_o),
        .reg_write_o(reg_write_o),
        .alu_op_o(alu_op_wire)
    );

    alu_decoder alu_dec_inst (
        .opcode_5_i(opcode_i[5]),
        .funct3_i(funct3_i),
        .funct7_5_i(funct7_5_i),
        .alu_op_i(alu_op_wire),
        .alu_control_o(alu_control_o)
    );

endmodule

`timescale 1ps/1ps

module control_unit (
    input   logic   [6:0]   opcode_i,
    input   logic   [2:0]   funct3_i,
    input   logic           funct7_5_i,
    input   logic           zero_i,
    output  logic           pc_src_o,
    output  logic           reg_write_o,
    output  logic   [1:0]   result_src_o,
    output  logic           mem_write_o,
    output  logic           alu_src_o,
    output  logic   [1:0]   imm_src_o,
    output  logic   [2:0]   alu_control_o
);

    logic branch_wire, jump_wire;
    logic [1:0] alu_op_wire;

    main_decoder main_dec_inst (
        .opcode_i(opcode_i),
        .branch_o(branch_wire),
        .jump_o(jump_wire),
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

    assign pc_src_o = ((zero_i && branch_wire) || jump_wire);

endmodule

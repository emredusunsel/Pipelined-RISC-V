`timescale 1ps/1ps

module main_decoder (
    input   logic   [6:0]   opcode_i,
    output  logic           branch_o,
    output  logic           jump_o,
    output  logic   [1:0]   result_src_o,
    output  logic           mem_write_o,
    output  logic           alu_src_o,
    output  logic   [1:0]   imm_src_o,
    output  logic           reg_write_o,
    output  logic   [1:0]   alu_op_o
);
    
    localparam logic [6:0] LW_OP    = 7'b000_0011;
    localparam logic [6:0] SW_OP    = 7'b010_0011;
    localparam logic [6:0] R_OP     = 7'b011_0011;
    localparam logic [6:0] BEQ_OP   = 7'b110_0011;
    localparam logic [6:0] I_OP     = 7'b001_0011;
    localparam logic [6:0] JAL_OP   = 7'b110_1111;

    always_comb begin : main_decoder_block
        case (opcode_i)
            LW_OP: begin
                reg_write_o     = 1'b1;
                imm_src_o       = 2'b00;
                alu_src_o       = 1'b1;
                mem_write_o     = 1'b0;
                result_src_o    = 2'b01;
                branch_o        = 1'b0;
                alu_op_o        = 2'b00;
                jump_o          = 1'b0;
            end

            SW_OP: begin
                reg_write_o     = 1'b0;
                imm_src_o       = 2'b01;
                alu_src_o       = 1'b1;
                mem_write_o     = 1'b1;
                result_src_o    = 2'b00;
                branch_o        = 1'b0;
                alu_op_o        = 2'b00;
                jump_o          = 1'b0;
            end

            R_OP: begin
                reg_write_o     = 1'b1;
                imm_src_o       = 2'b00;
                alu_src_o       = 1'b0;
                mem_write_o     = 1'b0;
                result_src_o    = 2'b00;
                branch_o        = 1'b0;
                alu_op_o        = 2'b10;
                jump_o          = 1'b0;
            end

            BEQ_OP: begin
                reg_write_o     = 1'b0;
                imm_src_o       = 2'b10;
                alu_src_o       = 1'b0;
                mem_write_o     = 1'b0;
                result_src_o    = 2'b00;
                branch_o        = 1'b1;
                alu_op_o        = 2'b01;
                jump_o          = 1'b0;
            end

            I_OP: begin
                reg_write_o     = 1'b1;
                imm_src_o       = 2'b00;
                alu_src_o       = 1'b1;
                mem_write_o     = 1'b0;
                result_src_o    = 2'b00;
                branch_o        = 1'b0;
                alu_op_o        = 2'b10;
                jump_o          = 1'b0;
            end

            JAL_OP: begin
                reg_write_o     = 1'b1;
                imm_src_o       = 2'b11;
                alu_src_o       = 1'b0;
                mem_write_o     = 1'b0;
                result_src_o    = 2'b10;
                branch_o        = 1'b0;
                alu_op_o        = 2'b00;
                jump_o          = 1'b1;
            end

            default: begin
                reg_write_o     = 1'b0;
                imm_src_o       = 2'b00;
                alu_src_o       = 1'b0;
                mem_write_o     = 1'b0;
                result_src_o    = 2'b00;
                branch_o        = 1'b0;
                alu_op_o        = 2'b00;
                jump_o          = 1'b0;
            end
        endcase
    end

endmodule
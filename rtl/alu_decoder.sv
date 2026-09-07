`timescale 1ps/1ps

module alu_decoder (
    input   logic           opcode_5_i,
    input   logic   [2:0]   funct3_i,
    input   logic           funct7_5_i,
    input   logic   [1:0]   alu_op_i,
    output  logic   [2:0]   alu_control_o
);

    localparam logic [2:0] ADD_OP = 3'b000;
    localparam logic [2:0] SUB_OP = 3'b001;
    localparam logic [2:0] SLT_OP = 3'b101;
    localparam logic [2:0] OR_OP  = 3'b011;
    localparam logic [2:0] AND_OP = 3'b010;

    always_comb begin : alu_decoder_block
        case (alu_op_i)
            2'b00: alu_control_o = ADD_OP;
            2'b01: alu_control_o = SUB_OP;
            2'b10: begin
                if (funct3_i == 3'b000) begin
                    if ({opcode_5_i, funct7_5_i} == 2'b11)
                        alu_control_o = SUB_OP; 
                    else
                        alu_control_o = ADD_OP;
                end else if (funct3_i == 3'b010)
                    alu_control_o = SLT_OP;
                else if (funct3_i == 3'b110)
                    alu_control_o = OR_OP;
                else if (funct3_i == 3'b111)
                    alu_control_o = AND_OP;
                else
                    alu_control_o = 3'b000;
            end
            2'b11: alu_control_o = 3'b000;
            default: alu_control_o = 3'b000;
        endcase
    end

endmodule

`timescale 1ps/1ps

module alu (
    input   logic   [31:0]  a_i,
    input   logic   [31:0]  b_i,
    input   logic   [ 3:0]  alu_ctrl_i,
    output  logic   [31:0]  result_o,
    output  logic           zero_o
);
    
    localparam logic [3:0] ALU_ADD  = 4'b0000;
    localparam logic [3:0] ALU_SUB  = 4'b0001;
    localparam logic [3:0] ALU_AND  = 4'b0010;
    localparam logic [3:0] ALU_OR   = 4'b0011;
    localparam logic [3:0] ALU_XOR  = 4'b0100;
    localparam logic [3:0] ALU_SLL  = 4'b0101;
    localparam logic [3:0] ALU_SRL  = 4'b0110;
    localparam logic [3:0] ALU_SRA  = 4'b0111;
    localparam logic [3:0] ALU_SLT  = 4'b1000;
    localparam logic [3:0] ALU_SLTU = 4'b1001;

    always_comb begin : alu_block
        case (alu_ctrl_i)
            ALU_ADD:    result_o = a_i + b_i;
            ALU_SUB:    result_o = a_i - b_i;
            ALU_AND:    result_o = a_i & b_i;
            ALU_OR:     result_o = a_i | b_i;
            ALU_XOR:    result_o = a_i ^ b_i;
            ALU_SLL:    result_o = a_i << b_i[4:0];
            ALU_SRL:    result_o = a_i >> b_i[4:0];
            ALU_SRA:    result_o = $signed(a_i) >>> b_i[4:0];
            ALU_SLT:    result_o = {31'b0, ($signed(a_i) < $signed(b_i))};
            ALU_SLTU:   result_o = {31'b0, (a_i < b_i)};
            default:    result_o = 32'b0;
        endcase
    end

    assign zero_o = (result_o == 32'b0);

endmodule

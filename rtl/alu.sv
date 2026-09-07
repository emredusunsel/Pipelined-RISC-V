`timescale 1ps/1ps

module alu (
    input   logic   [31:0]  a_i,
    input   logic   [31:0]  b_i,
    input   logic   [ 2:0]  alu_ctrl_i,
    output  logic   [31:0]  result_o,
    output  logic           zero_o
);
    
    localparam logic [2:0] ALU_ADD  = 3'b000;
    localparam logic [2:0] ALU_SUB  = 3'b001;
    localparam logic [2:0] ALU_AND  = 3'b010;
    localparam logic [2:0] ALU_OR   = 3'b011;
    localparam logic [2:0] ALU_SLT  = 3'b101;

    always_comb begin : alu_block
        case (alu_ctrl_i)
            ALU_ADD:    result_o = a_i + b_i;
            ALU_SUB:    result_o = a_i - b_i;
            ALU_AND:    result_o = a_i & b_i;
            ALU_OR:     result_o = a_i | b_i;
            ALU_SLT:    result_o = ($signed(a_i) < $signed(b_i)) ? 32'd1 : 32'd0;
            default:    result_o = 32'b0;
        endcase
    end

    assign zero_o = (result_o == 32'b0);

endmodule

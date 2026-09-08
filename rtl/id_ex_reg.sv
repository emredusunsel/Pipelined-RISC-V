`timescale 1ps/1ps

module id_ex_reg (
    input   logic           clk,
    input   logic           rstn,
    input   logic           clear_i,

    input   logic   [31:0]  rd1_D_i,
    input   logic   [31:0]  rd2_D_i,
    input   logic   [31:0]  pc_D_i,
    input   logic   [ 4:0]  rs1_D_i,
    input   logic   [ 4:0]  rs2_D_i,
    input   logic   [ 4:0]  rd_D_i,
    input   logic   [31:0]  imm_ext_D_i,
    input   logic   [31:0]  pcp4_D_i,

    // CONTROL SIGNALS IN
    // ...
    input   logic           RegWriteD_i,
    input   logic   [1:0]   ResultSrcD_i,
    input   logic           MemWriteD_i,
    input   logic           JumpD_i,
    input   logic           BranchD_i,
    input   logic   [ 2:0]  ALUControlD_i,
    input   logic           ALUSrcD_i,

    output  logic   [31:0]  rd1_E_o,
    output  logic   [31:0]  rd2_E_o,
    output  logic   [31:0]  pc_E_o,
    output  logic   [ 4:0]  rs1_E_o,
    output  logic   [ 4:0]  rs2_E_o,
    output  logic   [ 4:0]  rd_E_o,
    output  logic   [31:0]  imm_ext_E_o,
    output  logic   [31:0]  pcp4_E_o,

    // CONTROL SIGNALS OUT
    // ...  
    output  logic           RegWriteE_o,
    output  logic   [ 1:0]  ResultSrcE_o,
    output  logic           MemWriteE_o,
    output  logic           JumpE_o,
    output  logic           BranchE_o,
    output  logic   [ 2:0]  ALUControlE_o,
    output  logic           ALUSrcE_o

);

    always_ff @(posedge clk or negedge rstn) begin : id_ex_block
        if (!rstn) begin
            rd1_E_o     <= 32'h0;
            rd2_E_o     <= 32'h0;
            pc_E_o      <= 32'h0;
            rs1_E_o     <= 5'b0;
            rs2_E_o     <= 5'b0;
            rd_E_o      <= 5'b0;
            imm_ext_E_o <= 32'h0;
            pcp4_E_o    <= 32'h0;
            RegWriteE_o <= 32'h0;
            ResultSrcE_o <= 32'h0;
            MemWriteE_o <= 32'h0;
            JumpE_o     <= 32'h0;
            BranchE_o   <= 32'h0;
            ALUControlE_o <= 32'h0;
            ALUSrcE_o   <= 32'h0;
        end else if (clear_i) begin
            rd1_E_o     <= 32'h0;
            rd2_E_o     <= 32'h0;
            pc_E_o      <= 32'h0;
            rs1_E_o     <= 5'b0;
            rs2_E_o     <= 5'b0;
            rd_E_o      <= 5'b0;
            imm_ext_E_o <= 32'h0;
            pcp4_E_o    <= 32'h0;
            RegWriteE_o <= 32'h0;
            ResultSrcE_o <= 32'h0;
            MemWriteE_o <= 32'h0;
            JumpE_o     <= 32'h0;
            BranchE_o   <= 32'h0;
            ALUControlE_o <= 32'h0;
            ALUSrcE_o   <= 32'h0;
        end else begin
            rd1_E_o     <= rd1_D_i;
            rd2_E_o     <= rd2_D_i;
            pc_E_o      <= pc_D_i;
            rs1_E_o     <= rs1_D_i;
            rs2_E_o     <= rs2_D_i;
            rd_E_o      <= rd_D_i;
            imm_ext_E_o <= imm_ext_D_i;
            pcp4_E_o    <= pcp4_D_i;
            RegWriteE_o <= RegWriteD_i;
            ResultSrcE_o <= ResultSrcD_i;
            MemWriteE_o <= MemWriteD_i;
            JumpE_o     <= JumpD_i;
            BranchE_o   <= BranchD_i;
            ALUControlE_o <= ALUControlD_i;
            ALUSrcE_o   <= ALUSrcD_i;
        end
    end

endmodule

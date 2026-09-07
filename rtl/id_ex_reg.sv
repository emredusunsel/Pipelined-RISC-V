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

    output  logic   [31:0]  rd1_E_o,
    output  logic   [31:0]  rd2_E_o,
    output  logic   [31:0]  pc_E_o,
    output  logic   [ 4:0]  rs1_E_o,
    output  logic   [ 4:0]  rs2_E_o,
    output  logic   [ 4:0]  rd_E_o,
    output  logic   [31:0]  imm_ext_E_o,
    output  logic   [31:0]  pcp4_E_o

    // CONTROL SIGNALS OUT
    // ...  

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
        end else if (clear_i) begin
            rd1_E_o     <= 32'h0;
            rd2_E_o     <= 32'h0;
            pc_E_o      <= 32'h0;
            rs1_E_o     <= 5'b0;
            rs2_E_o     <= 5'b0;
            rd_E_o      <= 5'b0;
            imm_ext_E_o <= 32'h0;
            pcp4_E_o    <= 32'h0;
        end else begin
            rd1_E_o     <= rd1_D_i;
            rd2_E_o     <= rd2_D_i;
            pc_E_o      <= pc_D_i;
            rs1_E_o     <= rs1_D_i;
            rs2_E_o     <= rs2_D_i;
            rd_E_o      <= rd_D_i;
            imm_ext_E_o <= imm_ext_D_i;
            pcp4_E_o    <= pcp4_D_i;
        end
    end

endmodule

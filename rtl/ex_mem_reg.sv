`timescale 1ps/1ps

module ex_mem_reg (
    input   logic           clk,
    input   logic           rstn,

    input   logic   [31:0]  alu_E_i,
    input   logic   [31:0]  wr_data_E_i,
    input   logic   [ 4:0]  rd_E_i,
    input   logic   [31:0]  pcp4_E_i,

    // CONTROL SIGNALS IN
    // ...
    input   logic           RegWriteE_i,
    input   logic   [ 1:0]  ResultSrcE_i,
    input   logic           MemWriteE_i,

    output  logic   [31:0]  alu_M_o,
    output  logic   [31:0]  wr_data_M_o,
    output  logic   [ 4:0]  rd_M_o,
    output  logic   [31:0]  pcp4_M_o,

    // CONTROL SIGNALS OUT
    output  logic           RegWriteM_o,
    output  logic   [ 1:0]  ResultSrcM_o,
    output  logic           MemWriteM_o
);

    always_ff @(posedge clk or negedge rstn) begin : ex_mem_block
        if (!rstn) begin
            alu_M_o     <= 32'h0;
            wr_data_M_o <= 32'h0;
            rd_M_o      <= 5'b0;
            pcp4_M_o    <= 32'h0;
            RegWriteM_o <= 32'h0;
            ResultSrcM_o <= 32'h0;
            MemWriteM_o <= 32'h0;
        end else begin
            alu_M_o     <= alu_E_i;
            wr_data_M_o <= wr_data_E_i;
            rd_M_o      <= rd_E_i;
            pcp4_M_o    <= pcp4_E_i;
            RegWriteM_o <= RegWriteE_i;
            ResultSrcM_o <= ResultSrcE_i;
            MemWriteM_o <= MemWriteE_i;
        end
    end

endmodule

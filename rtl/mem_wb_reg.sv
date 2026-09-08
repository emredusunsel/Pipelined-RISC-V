`timescale 1ps/1ps

module mem_wb_reg (
    input   logic   clk,
    input   logic   rstn,

    input   logic   [31:0]  alu_M_i,
    input   logic   [31:0]  rd_data_M_i,
    input   logic   [ 4:0]  rd_M_i,
    input   logic   [31:0]  pcp4_M_i,

    // CONTROL SIGNALS IN
    // ...
    input   logic           RegWriteM_i,
    input   logic   [ 1:0]  ResultSrcM_i,

    output  logic   [31:0]  alu_W_o,
    output  logic   [31:0]  rd_data_W_o,
    output  logic   [ 4:0]  rd_W_o,
    output  logic   [31:0]  pcp4_W_o,

    // CONTROL SIGNALS OUT
    // ...
    output  logic           RegWriteW_o,
    output  logic   [ 1:0]  ResultSrcW_o
);
    
    always_ff @(posedge clk or negedge rstn) begin : mem_wb_block
        if (!rstn) begin
            alu_W_o     <= 32'h0;
            rd_data_W_o <= 32'h0;
            rd_W_o      <= 5'b0;
            pcp4_W_o    <= 32'h0;
            RegWriteW_o <= 32'h0;
            ResultSrcW_o <= 32'h0;
        end else begin
            alu_W_o     <= alu_M_i;
            rd_data_W_o <= rd_data_M_i;
            rd_W_o      <= rd_M_i;
            pcp4_W_o    <= pcp4_M_i;
            RegWriteW_o <= RegWriteM_i;
            ResultSrcW_o <= ResultSrcM_i;
        end
    end

endmodule

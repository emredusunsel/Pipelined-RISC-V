// for flush (clear) consider instr_o = 32'h0000_0013;
// which is NOP ADDI x0, x0, 0

`timescale 1ps/1ps

module if_id_reg (
    input   logic           clk,
    input   logic           rstn,
    input   logic           enable_ni,
    input   logic           clear_i,

    input   logic   [31:0]  pc_F_i,
    input   logic   [31:0]  instr_F_i,
    input   logic   [31:0]  pcp4_F_i,

    output  logic   [31:0]  pc_D_o,
    output  logic   [31:0]  instr_D_o,
    output  logic   [31:0]  pcp4_D_o
);

    always_ff @(posedge clk or negedge rstn) begin : if_id_block
        if (!rstn) begin
            pc_D_o      <= 32'b0;
            instr_D_o   <= 32'b0;
            pcp4_D_o    <= 32'b0;
        end else if (clear_i) begin
            pc_D_o      <= 32'b0;
            instr_D_o   <= 32'b0;
            pcp4_D_o    <= 32'b0;
        end else if (!enable_ni) begin
            pc_D_o      <= pc_F_i;
            instr_D_o   <= instr_F_i;
            pcp4_D_o    <= pcp4_F_i;
        end
    end
    
endmodule

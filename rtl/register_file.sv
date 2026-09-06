`timescale 1ps/1ps

module register_file (
    input   logic           clk,
    input   logic           rstn,
    input   logic           we_i,
    input   logic   [ 4:0]  rs1_addr_i,
    input   logic   [ 4:0]  rs2_addr_i,
    input   logic   [ 4:0]  rd_addr_i,
    input   logic   [31:0]  rd_data_i,
    output  logic   [31:0]  rs1_data_o,
    output  logic   [31:0]  rs2_data_o
);
    
    logic [31:0] registers [32];

    integer i;

    always_ff @(posedge clk or negedge rstn) begin : register_block
        if (!rstn) begin
            for (i = 0; i < 32; i++)
                registers[i] <= 32'd0;
        end else
            if (we_i && (rd_addr_i != 5'd0))
                registers[rd_addr_i] <= rd_data_i;
    end

    assign rs1_data_o = (rs1_addr_i == 5'd0) ? 32'd0 : registers[rs1_addr_i];
    assign rs2_data_o = (rs2_addr_i == 5'd0) ? 32'd0 : registers[rs2_addr_i];

endmodule
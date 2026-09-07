`timescale 1ps/1ps

module program_counter #(
    parameter logic [31:0] RESET_PC = 32'h0000_0000 // or 8000_0000
) (
    input   logic           clk,
    input   logic           rstn,
    input   logic   [31:0]  pc_next_i,  // next PC
    input   logic           en_ni,       // update when 1, hold when 0
    output  logic   [31:0]  pc_o        // current PC
);

    always_ff @(posedge clk or negedge rstn) begin : pc_block
        if (!rstn)
            pc_o <= RESET_PC;
        else if (!en_ni)
            pc_o <= pc_next_i;
    end

endmodule

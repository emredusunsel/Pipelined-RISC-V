`timescale 1ps/1ps

module instruction_memory #(
    parameter int DEPTH = 256,
    parameter string MEM_FILE = "test/program.hex"
) (
    input   logic   [31:0]  addr_i,
    output  logic   [31:0]  instr_o
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);

    logic [31:0] mem [DEPTH];

    // initial begin
    //     $readmemh(MEM_FILE, mem);
    // end


    // CHANGED BEGIN
    // initialize unused instruction memory to NOP
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i++)
            mem[i] = 32'h00000013; // ADDI x0, x0, 0 = NOP

        $readmemh("test/program.hex", mem);
    end
    // CHANGED END

    assign instr_o = mem[addr_i[ADDR_WIDTH+1:2]];

endmodule

`timescale 1ps/1ps

module instruction_memory_tb;

    localparam int DEPTH = 256;

    logic [31:0] addr_t, instr_t;

    instruction_memory # (
        .DEPTH(DEPTH),
        .MEM_FILE("test/program.hex")
    ) dut (
        .addr_i(addr_t),
        .instr_o(instr_t)
    );

    initial begin
        addr_t = '0; #10;
        addr_t = 32'd4; #10;
        addr_t = 32'd8; #10;
        addr_t = 32'd12; #10;
        $finish;
    end

    initial begin
        $monitor("%h | %h", addr_t, instr_t);
    end

endmodule

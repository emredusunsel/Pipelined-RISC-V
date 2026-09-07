`timescale 1ps/1ps

module alu_decoder_tb;

    logic         opcode_5_i;
    logic [2:0]   funct3_i;
    logic         funct7_5_i;
    logic [1:0]   alu_op_i;
    logic [2:0]   alu_control_o;

    localparam logic [2:0] ADD_OP = 3'b000;
    localparam logic [2:0] SUB_OP = 3'b001;
    localparam logic [2:0] SLT_OP = 3'b101;
    localparam logic [2:0] OR_OP  = 3'b011;
    localparam logic [2:0] AND_OP = 3'b010;

    alu_decoder dut (
        .opcode_5_i   (opcode_5_i),
        .funct3_i     (funct3_i),
        .funct7_5_i   (funct7_5_i),
        .alu_op_i     (alu_op_i),
        .alu_control_o(alu_control_o)
    );

    task automatic check(
        input logic       opcode_5,
        input logic [2:0] funct3,
        input logic       funct7_5,
        input logic [1:0] alu_op,
        input logic [2:0] expected
    );
        begin
            opcode_5_i = opcode_5;
            funct3_i   = funct3;
            funct7_5_i = funct7_5;
            alu_op_i   = alu_op;

            #1;

            if (alu_control_o !== expected)
                $fatal(1,
                    "FAIL: alu_op=%b opcode5=%b funct3=%b funct7_5=%b | expected=%b got=%b",
                    alu_op_i, opcode_5_i, funct3_i, funct7_5_i,
                    expected, alu_control_o
                );
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, alu_decoder_tb);

        // alu_op = 00 -> ADD
        check(0, 3'b000, 0, 2'b00, ADD_OP);

        // alu_op = 01 -> SUB (branch comparison)
        check(0, 3'b000, 0, 2'b01, SUB_OP);

        // R-type ADD
        check(1, 3'b000, 0, 2'b10, ADD_OP);

        // R-type SUB
        check(1, 3'b000, 1, 2'b10, SUB_OP);

        // I-type ADDI
        check(0, 3'b000, 0, 2'b10, ADD_OP);
        check(0, 3'b000, 1, 2'b10, ADD_OP);

        // SLT
        check(1, 3'b010, 0, 2'b10, SLT_OP);

        // OR
        check(1, 3'b110, 0, 2'b10, OR_OP);

        // AND
        check(1, 3'b111, 0, 2'b10, AND_OP);

        // Unsupported funct3 -> default ADD
        check(1, 3'b001, 0, 2'b10, ADD_OP);

        // Unsupported alu_op -> default ADD
        check(0, 3'b000, 0, 2'b11, ADD_OP);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
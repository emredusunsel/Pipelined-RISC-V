`timescale 1ps/1ps

module main_decoder_tb;

    logic [6:0] opcode_i;
    logic       branch_o;
    logic       jump_o;
    logic [1:0] result_src_o;
    logic       mem_write_o;
    logic       alu_src_o;
    logic [1:0] imm_src_o;
    logic       reg_write_o;
    logic [1:0] alu_op_o;

    main_decoder dut (
        .opcode_i      (opcode_i),
        .branch_o      (branch_o),
        .jump_o        (jump_o),
        .result_src_o  (result_src_o),
        .mem_write_o   (mem_write_o),
        .alu_src_o     (alu_src_o),
        .imm_src_o     (imm_src_o),
        .reg_write_o   (reg_write_o),
        .alu_op_o      (alu_op_o)
    );

    initial begin
        // LW
        opcode_i = 7'b000_0011; #10;
        if (reg_write_o !== 1'b1 ||
            imm_src_o   !== 2'b00 ||
            alu_src_o   !== 1'b1 ||
            mem_write_o !== 1'b0 ||
            result_src_o!== 2'b01 ||
            branch_o    !== 1'b0 ||
            alu_op_o    !== 2'b00 ||
            jump_o      !== 1'b0)
            $fatal(1, "LW test failed");

        // SW
        opcode_i = 7'b010_0011; #10;
        if (reg_write_o !== 1'b0 ||
            imm_src_o   !== 2'b01 ||
            alu_src_o   !== 1'b1 ||
            mem_write_o !== 1'b1 ||
            branch_o    !== 1'b0 ||
            alu_op_o    !== 2'b00 ||
            jump_o      !== 1'b0)
            $fatal(1, "SW test failed");

        // R-type
        opcode_i = 7'b011_0011; #10;
        if (reg_write_o !== 1'b1 ||
            alu_src_o   !== 1'b0 ||
            mem_write_o !== 1'b0 ||
            result_src_o!== 2'b00 ||
            branch_o    !== 1'b0 ||
            alu_op_o    !== 2'b10 ||
            jump_o      !== 1'b0)
            $fatal(1, "R-type test failed");

        // BEQ / branch
        opcode_i = 7'b110_0011; #10;
        if (reg_write_o !== 1'b0 ||
            imm_src_o   !== 2'b10 ||
            alu_src_o   !== 1'b0 ||
            mem_write_o !== 1'b0 ||
            branch_o    !== 1'b1 ||
            alu_op_o    !== 2'b01 ||
            jump_o      !== 1'b0)
            $fatal(1, "Branch test failed");

        // I-type ALU
        opcode_i = 7'b001_0011; #10;
        if (reg_write_o !== 1'b1 ||
            imm_src_o   !== 2'b00 ||
            alu_src_o   !== 1'b1 ||
            mem_write_o !== 1'b0 ||
            result_src_o!== 2'b00 ||
            branch_o    !== 1'b0 ||
            alu_op_o    !== 2'b10 ||
            jump_o      !== 1'b0)
            $fatal(1, "I-type test failed");

        // JAL
        opcode_i = 7'b110_1111; #10;
        if (reg_write_o !== 1'b1 ||
            imm_src_o   !== 2'b11 ||
            mem_write_o !== 1'b0 ||
            result_src_o!== 2'b10 ||
            branch_o    !== 1'b0 ||
            jump_o      !== 1'b1)
            $fatal(1, "JAL test failed");

        // Invalid opcode / default
        opcode_i = 7'b111_1111; #10;
        if (reg_write_o !== 1'b0 ||
            imm_src_o   !== 2'b00 ||
            alu_src_o   !== 1'b0 ||
            mem_write_o !== 1'b0 ||
            result_src_o!== 2'b00 ||
            branch_o    !== 1'b0 ||
            alu_op_o    !== 2'b00 ||
            jump_o      !== 1'b0)
            $fatal(1, "Default test failed");

        $display("ALL TESTS PASSED");
        $finish;
    end

    initial begin
        $monitor(
            "%0t | opcode=%b | RegWrite=%b ImmSrc=%b ALUSrc=%b MemWrite=%b ResultSrc=%b Branch=%b ALUOp=%b Jump=%b",
            $time,
            opcode_i,
            reg_write_o,
            imm_src_o,
            alu_src_o,
            mem_write_o,
            result_src_o,
            branch_o,
            alu_op_o,
            jump_o
        );
    end

endmodule
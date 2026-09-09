`timescale 1ps/1ps

module riscv_pipelined_top_tb;

    logic clk;
    logic rstn;

    integer cycle;
    integer errors;

    // ------------------------------------------------------------
    // DUT
    //
    // Assumption:
    //   top module name = riscv_pipelined_top
    //   ports           = clk, rstn
    //
    // If your top module name is different, change only this block.
    // ------------------------------------------------------------
    riscv_top dut (
        .clk  (clk),
        .rstn (rstn)
    );

    // ------------------------------------------------------------
    // HIERARCHICAL PATHS
    //
    // Change these two lines only if your instance names differ.
    //
    // Example expected hierarchy:
    //   dut.register_file_inst.registers[...]
    //   dut.data_memory_inst.memory[...]
    // ------------------------------------------------------------
    `define REGFILE dut.datapath.register_file.registers
    `define DMEM    dut.datapath.data_memory.mem

    // ------------------------------------------------------------
    // CLOCK
    // ------------------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // REGISTER CHECK TASK
    // ------------------------------------------------------------
    task automatic check_reg(
        input integer reg_num,
        input logic [31:0] expected
    );
        begin
            if (`REGFILE[reg_num] !== expected) begin
                $display(
                    "FAIL: x%0d = 0x%08h, expected 0x%08h",
                    reg_num,
                    `REGFILE[reg_num],
                    expected
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: x%0d = 0x%08h",
                    reg_num,
                    `REGFILE[reg_num]
                );
            end
        end
    endtask

    // ------------------------------------------------------------
    // MEMORY CHECK TASK
    //
    // Assumes data memory is word-addressed internally:
    //   memory[0] -> byte address 0
    //   memory[1] -> byte address 4
    //   memory[2] -> byte address 8
    //   memory[3] -> byte address 12
    // ------------------------------------------------------------
    task automatic check_mem(
        input integer word_index,
        input logic [31:0] expected
    );
        begin
            if (`DMEM[word_index] !== expected) begin
                $display(
                    "FAIL: MEM[%0d] = 0x%08h, expected 0x%08h",
                    word_index,
                    `DMEM[word_index],
                    expected
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: MEM[%0d] = 0x%08h",
                    word_index,
                    `DMEM[word_index]
                );
            end
        end
    endtask

    // ------------------------------------------------------------
    // OPTIONAL CYCLE COUNTER
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!rstn)
            cycle <= 0;
        else
            cycle <= cycle + 1;
    end

    // ------------------------------------------------------------
    // TEST
    // ------------------------------------------------------------
    initial begin
        errors = 0;
        cycle  = 0;

        $dumpfile("wave.vcd");
        $dumpvars(0, riscv_pipelined_top_tb);

        // Reset
        rstn = 1'b0;
        repeat (2) @(posedge clk);

        @(negedge clk);
        rstn = 1'b1;

        // Let the entire program execute.
        // Includes stalls, branch flushes, JAL flush, and pipeline drain.
        repeat (60) @(posedge clk);

        $display("");
        $display("========================================");
        $display("        REGISTER FILE CHECKS");
        $display("========================================");

        check_reg( 0, 32'd0);
        check_reg( 1, 32'd5);
        check_reg( 2, 32'd7);
        check_reg( 3, 32'd12);
        check_reg( 4, 32'd7);
        check_reg( 5, 32'd4);
        check_reg( 6, 32'd7);
        check_reg( 7, 32'd1);
        check_reg( 8, 32'd12);
        check_reg( 9, 32'd17);
        check_reg(10, 32'd17);

        // x11=99 instruction must be flushed by taken BEQ.
        check_reg(11, 32'd11);

        check_reg(12, 32'd12);

        // JAL at PC=0x44 writes PC+4 = 0x48.
        check_reg(13, 32'h0000_0048);

        // x14=99 instruction must be flushed by JAL.
        check_reg(14, 32'd23);

        check_reg(15, 32'd23);
        check_reg(16, 32'd24);
        check_reg(17, 32'd17);

        // x18=99 instruction must be flushed by taken BEQ.
        check_reg(18, 32'd18);

        check_reg(19, 32'd42);

        $display("");
        $display("========================================");
        $display("           DATA MEMORY CHECKS");
        $display("========================================");

        check_mem(0, 32'd12);  // address 0
        check_mem(1, 32'd17);  // address 4
        check_mem(2, 32'd23);  // address 8
        check_mem(3, 32'd42);  // address 12, final signature

        $display("");
        $display("========================================");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("TEST FAILED: %0d error(s)", errors);
        end

        $display("========================================");
        $finish;
    end

endmodule

`timescale 1ps/1ps

module riscv_pipeline_stress_tb;

    logic clk;
    logic rstn;

    integer errors;
    integer cycle;
    integer i;

    riscv_top dut (
        .clk  (clk),
        .rstn (rstn)
    );

    // Exact hierarchy supplied by you.
    `define REGFILE dut.datapath.register_file.registers
    `define DMEM    dut.datapath.data_memory.mem

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (!rstn)
            cycle <= 0;
        else
            cycle <= cycle + 1;
    end

    task automatic check_reg(
        input integer reg_num,
        input logic [31:0] expected
    );
        begin
            if (`REGFILE[reg_num] !== expected) begin
                $display(
                    "FAIL: x%0d = 0x%08h, expected 0x%08h",
                    reg_num, `REGFILE[reg_num], expected
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: x%0d = 0x%08h",
                    reg_num, `REGFILE[reg_num]
                );
            end
        end
    endtask

    task automatic check_mem(
        input integer word_index,
        input logic [31:0] expected
    );
        begin
            if (`DMEM[word_index] !== expected) begin
                $display(
                    "FAIL: MEM[%0d] = 0x%08h, expected 0x%08h",
                    word_index, `DMEM[word_index], expected
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: MEM[%0d] = 0x%08h",
                    word_index, `DMEM[word_index]
                );
            end
        end
    endtask

    initial begin
        errors = 0;
        cycle  = 0;

        $dumpfile("wave_stress.vcd");
        $dumpvars(0, riscv_pipeline_stress_tb);

        // Hold reset.
        rstn = 1'b0;

        // Clear the data-memory locations used by this test.
        // MEM[6..9] are especially important: they are targets of
        // wrong-path stores and must remain zero if flushing works.
        for (i = 0; i < 10; i = i + 1)
            `DMEM[i] = 32'd0;

        repeat (2) @(posedge clk);

        @(negedge clk);
        rstn = 1'b1;

        // Plenty of time for all stalls, redirects, flushes,
        // writebacks, and final pipeline drain.
        repeat (100) @(posedge clk);

        $display("");
        $display("========================================");
        $display("        REGISTER FILE CHECKS");
        $display("========================================");

        check_reg( 0, 32'd0);
        check_reg( 1, 32'd3);
        check_reg( 2, 32'd4);
        check_reg( 3, 32'd7);
        check_reg( 4, 32'd10);
        check_reg( 5, 32'd17);
        check_reg( 6, 32'd13);
        check_reg( 7, 32'd5);
        check_reg( 8, 32'd5);
        check_reg( 9, 32'd1);
        check_reg(10, 32'd17);
        check_reg(11, 32'd20);
        check_reg(12, 32'd37);
        check_reg(13, 32'd37);

        // Taken branch at PC=0x3c must prevent x14=99.
        check_reg(14, 32'd14);

        check_reg(15, 32'd17);

        // Taken branch at PC=0x50 must prevent x16=99.
        check_reg(16, 32'd16);

        check_reg(17, 32'd19);
        check_reg(18, 32'd18);
        check_reg(19, 32'd18);
        check_reg(20, 32'd21);

        // JAL at PC=0x7c writes PC+4.
        check_reg(21, 32'h0000_0080);

        // JAL must prevent x22=99.
        check_reg(22, 32'd22);

        check_reg(23, 32'd150);
        check_reg(24, 32'd150);

        // Taken branch at PC=0x98 must prevent x25=99.
        check_reg(25, 32'd25);

        check_reg(26, 32'd175);

        $display("");
        $display("========================================");
        $display("           DATA MEMORY CHECKS");
        $display("========================================");

        check_mem(0, 32'd17);   // byte address 0
        check_mem(1, 32'd37);   // byte address 4
        check_mem(2, 32'd18);   // byte address 8
        check_mem(3, 32'd21);   // byte address 12
        check_mem(4, 32'd150);  // byte address 16
        check_mem(5, 32'd175);  // byte address 20

        $display("");
        $display("========================================");
        $display("          WRONG-PATH CHECKS");
        $display("========================================");

        // These stores sit behind taken branches/JAL.
        // If flushing is wrong, one or more will become non-zero.
        check_mem(6, 32'd0);    // address 24
        check_mem(7, 32'd0);    // address 28
        check_mem(8, 32'd0);    // address 32
        check_mem(9, 32'd0);    // address 36

        $display("");
        $display("========================================");

        if (errors == 0)
            $display("ALL STRESS TESTS PASSED");
        else
            $display("STRESS TEST FAILED: %0d error(s)", errors);

        $display("========================================");
        $finish;
    end

endmodule

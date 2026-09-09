`timescale 1ps/1ps

module riscv_pipeline_flow_tb;

    logic clk;
    logic rstn;

    integer cycle;
    integer errors;
    integer stall_count;
    integer branch_flush_count;
    integer flushE_count;

    logic [31:0] pc_before_stall;
    logic        stall_pending;
    logic        redirect_pending;

    // ============================================================
    // DUT
    // ============================================================
    riscv_top dut (
        .clk  (clk),
        .rstn (rstn)
    );

    // ============================================================
    // HIERARCHY ALIASES
    //
    // Register file / data memory are the exact paths you supplied.
    //
    // The remaining signal aliases assume your datapath/top uses the
    // same stage naming convention as your modules. If Icarus reports
    // one of these names as unbound, only this block needs changing.
    // ============================================================
    `define REGFILE   dut.datapath.register_file.registers
    `define DMEM      dut.datapath.data_memory.mem

    `define PC_F      dut.datapath.PCF_w
    `define PC_D      dut.datapath.PCD_w
    `define PC_E      dut.datapath.PCE_w
    `define PCP4_M    dut.datapath.PCPlus4M_w
    `define PCP4_W    dut.datapath.PCPlus4W_w

    `define STALL_F   dut.StallF_w
    `define STALL_D   dut.StallD_w
    `define FLUSH_D   dut.FlushD_w
    `define FLUSH_E   dut.FlushE_w
    `define FWD_A     dut.ForwardAE_w
    `define FWD_B     dut.ForwardBE_w

    // ============================================================
    // CLOCK
    // ============================================================
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ============================================================
    // DISPLAY HELPERS
    // ============================================================
    function automatic string instruction_at_pc(input logic [31:0] pc);
        begin
            case (pc)
                32'h0000_0000: instruction_at_pc = "addi x1,x0,5";
                32'h0000_0004: instruction_at_pc = "addi x2,x0,7";
                32'h0000_0008: instruction_at_pc = "add x3,x1,x2";
                32'h0000_000c: instruction_at_pc = "sw x3,0(x0)";
                32'h0000_0010: instruction_at_pc = "lw x4,0(x0)";
                32'h0000_0014: instruction_at_pc = "add x5,x4,x1";
                32'h0000_0018: instruction_at_pc = "beq x5,x5,8";
                32'h0000_001c: instruction_at_pc = "addi x6,x0,99";
                32'h0000_0020: instruction_at_pc = "addi x6,x0,42";
                default:       instruction_at_pc = "nop / bubble";
            endcase
        end
    endfunction

    function automatic logic [31:0] stage_pc_from_pcp4(
        input logic [31:0] pcp4
    );
        begin
            if (pcp4 == 32'd0)
                stage_pc_from_pcp4 = 32'hffff_ffff;
            else
                stage_pc_from_pcp4 = pcp4 - 32'd4;
        end
    endfunction

    task automatic print_flow;
        logic [31:0] pc_M;
        logic [31:0] pc_W;
        begin
            pc_M = stage_pc_from_pcp4(`PCP4_M);
            pc_W = stage_pc_from_pcp4(`PCP4_W);

            $display(
                "%2d | F:%08h | D:%08h | E:%08h | M:%08h | W:%08h | SF:%b SD:%b FD:%b FE:%b | FA:%02b FB:%02b",
                cycle,
                `PC_F,
                `PC_D,
                `PC_E,
                pc_M,
                pc_W,
                `STALL_F,
                `STALL_D,
                `FLUSH_D,
                `FLUSH_E,
                `FWD_A,
                `FWD_B
            );

            $display(
                "   | F:%-16s | D:%-16s | E:%-16s",
                instruction_at_pc(`PC_F),
                instruction_at_pc(`PC_D),
                instruction_at_pc(`PC_E)
            );
        end
    endtask

    // ============================================================
    // FLOW CHECKER
    //
    // Sampling is done at negedge because all posedge pipeline
    // registers have settled by then.
    // ============================================================
    always @(negedge clk) begin
        if (!rstn) begin
            cycle              = 0;
            stall_pending      = 1'b0;
            redirect_pending   = 1'b0;
        end
        else begin
            cycle = cycle + 1;

            print_flow();

            // ----------------------------------------------------
            // Basic hazard-unit consistency
            // ----------------------------------------------------
            if (`STALL_F !== `STALL_D) begin
                $display("ERROR cycle %0d: stall_F != stall_D", cycle);
                errors = errors + 1;
            end

            // A load-use stall should also inject a bubble into E.
            if (`STALL_F && !`FLUSH_E) begin
                $display("ERROR cycle %0d: stall without flush_E", cycle);
                errors = errors + 1;
            end

            // A taken branch/jump flushes both younger stages.
            if (`FLUSH_D && !`FLUSH_E) begin
                $display("ERROR cycle %0d: flush_D without flush_E", cycle);
                errors = errors + 1;
            end

            // ----------------------------------------------------
            // Count the important events
            // ----------------------------------------------------
            if (`STALL_F && `STALL_D) begin
                stall_count     = stall_count + 1;
                pc_before_stall = `PC_F;
                stall_pending   = 1'b1;

                $display("   >>> LOAD-USE STALL detected");
            end

            if (`FLUSH_D) begin
                branch_flush_count = branch_flush_count + 1;
                redirect_pending   = 1'b1;

                $display("   >>> TAKEN BRANCH FLUSH detected");
            end

            if (`FLUSH_E)
                flushE_count = flushE_count + 1;
        end
    end

    // ============================================================
    // EDGE-EFFECT CHECKS
    //
    // Check what the stall/redirect actually did at the next
    // rising edge.
    // ============================================================
    always @(posedge clk) begin
        if (rstn) begin
            #1;

            if (stall_pending) begin
                if (`PC_F !== pc_before_stall) begin
                    $display(
                        "ERROR: PC_F changed during stall: old=%08h new=%08h",
                        pc_before_stall, `PC_F
                    );
                    errors = errors + 1;
                end
                else begin
                    $display(
                        "   >>> PASS: PC_F held at %08h during stall",
                        `PC_F
                    );
                end

                stall_pending = 1'b0;
            end

            if (redirect_pending) begin
                if (`PC_F !== 32'h0000_0020) begin
                    $display(
                        "ERROR: branch redirect PC_F=%08h, expected 00000020",
                        `PC_F
                    );
                    errors = errors + 1;
                end
                else begin
                    $display(
                        "   >>> PASS: branch redirected fetch to 0x00000020"
                    );
                end

                redirect_pending = 1'b0;
            end
        end
    end

    // ============================================================
    // TEST
    // ============================================================
    initial begin
        errors             = 0;
        cycle              = 0;
        stall_count        = 0;
        branch_flush_count = 0;
        flushE_count       = 0;
        stall_pending      = 1'b0;
        redirect_pending   = 1'b0;
        pc_before_stall    = 32'd0;

        $dumpfile("wave_flow.vcd");
        $dumpvars(0, riscv_pipeline_flow_tb);

        // Known memory state.
        `DMEM[0] = 32'd0;

        // Reset.
        rstn = 1'b0;
        repeat (2) @(posedge clk);

        @(negedge clk);
        rstn = 1'b1;

        $display("");
        $display("==============================================================================================");
        $display("                              PIPELINE FLOW");
        $display("==============================================================================================");
        $display(" C |     PC_F   |     PC_D   |     PC_E   |     PC_M   |     PC_W   | HAZARDS / FORWARDING");
        $display("----------------------------------------------------------------------------------------------");

        // Enough cycles to execute the program and drain the useful
        // instructions through WB.
        repeat (18) @(negedge clk);

        $display("");
        $display("==============================================================================================");
        $display("                            FLOW CHECK SUMMARY");
        $display("==============================================================================================");

        // Exact load-use timing expectation.
        if (stall_count !== 1) begin
            $display("FAIL: load-use stall count = %0d, expected 1", stall_count);
            errors = errors + 1;
        end
        else
            $display("PASS: exactly one load-use stall");

        // Exact taken-branch flush expectation.
        if (branch_flush_count !== 1) begin
            $display("FAIL: branch flush count = %0d, expected 1", branch_flush_count);
            errors = errors + 1;
        end
        else
            $display("PASS: exactly one taken-branch flush");

        // flush_E happens once for the load-use bubble and once for
        // the taken branch.
        if (flushE_count !== 2) begin
            $display("FAIL: flush_E count = %0d, expected 2", flushE_count);
            errors = errors + 1;
        end
        else
            $display("PASS: flush_E asserted exactly twice");

        // Architectural checks remain as a safety net.
        if (`REGFILE[1] !== 32'd5) begin
            $display("FAIL: x1");
            errors = errors + 1;
        end

        if (`REGFILE[2] !== 32'd7) begin
            $display("FAIL: x2");
            errors = errors + 1;
        end

        if (`REGFILE[3] !== 32'd12) begin
            $display("FAIL: x3");
            errors = errors + 1;
        end

        if (`REGFILE[4] !== 32'd12) begin
            $display("FAIL: x4");
            errors = errors + 1;
        end

        if (`REGFILE[5] !== 32'd17) begin
            $display("FAIL: x5");
            errors = errors + 1;
        end

        // If branch flushing fails, this can become 99 instead of 42.
        if (`REGFILE[6] !== 32'd42) begin
            $display(
                "FAIL: x6 = %0d, expected 42",
                `REGFILE[6]
            );
            errors = errors + 1;
        end

        if (`DMEM[0] !== 32'd12) begin
            $display("FAIL: MEM[0]");
            errors = errors + 1;
        end

        $display("----------------------------------------------------------------------------------------------");

        if (errors == 0)
            $display("ALL PIPELINE FLOW TESTS PASSED");
        else
            $display("PIPELINE FLOW TEST FAILED: %0d error(s)", errors);

        $display("==============================================================================================");
        $finish;
    end

endmodule

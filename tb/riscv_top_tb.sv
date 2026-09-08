`timescale 1ps/1ps

module riscv_top_tb;

    logic clk;
    logic rstn;

    integer trace_file;
    integer cycle;

    riscv_top dut (
        .clk  (clk),
        .rstn (rstn)
    );

    // 10 ps clock period
    always #5 clk = ~clk;


    // ---------------------------------------------------------
    // TRACE FILE
    // ---------------------------------------------------------

    initial begin
        trace_file = $fopen("pipeline_trace.txt", "w");

        if (trace_file == 0)
            $fatal(1, "Could not open pipeline_trace.txt");

        $fdisplay(trace_file,
            "============================================================");
        $fdisplay(trace_file,
            "              PIPELINED RISC-V SIMULATION TRACE");
        $fdisplay(trace_file,
            "============================================================");
        $fdisplay(trace_file, "");

        cycle = 0;
    end


    // ---------------------------------------------------------
    // PRINT PIPELINE STATE EVERY POSITIVE CLOCK EDGE
    // ---------------------------------------------------------

    always @(posedge clk) begin

        if (rstn) begin
            cycle = cycle + 1;

            // Small delay so sequential logic has updated
            #1;

            $fdisplay(trace_file,
                "============================================================");

            $fdisplay(trace_file,
                "CYCLE %0d    TIME = %0t",
                cycle, $time);

            $fdisplay(trace_file,
                "============================================================");


            // -------------------------------------------------
            // FETCH / DECODE
            // -------------------------------------------------

            $fdisplay(trace_file, "");
            $fdisplay(trace_file, "[DECODE]");

            $fdisplay(trace_file,
                "Instruction D : 0x%08h",
                dut.datapath.InstrD_w);

            $fdisplay(trace_file,
                "rs1           : x%0d",
                dut.datapath.InstrD_w[19:15]);

            $fdisplay(trace_file,
                "rs2           : x%0d",
                dut.datapath.InstrD_w[24:20]);

            $fdisplay(trace_file,
                "rd            : x%0d",
                dut.datapath.InstrD_w[11:7]);

            $fdisplay(trace_file,
                "RD1           : 0x%08h (%0d)",
                dut.datapath.RD1D_w,
                dut.datapath.RD1D_w);

            $fdisplay(trace_file,
                "RD2           : 0x%08h (%0d)",
                dut.datapath.RD2D_w,
                dut.datapath.RD2D_w);


            // -------------------------------------------------
            // CONTROL UNIT
            // -------------------------------------------------

            $fdisplay(trace_file, "");
            $fdisplay(trace_file, "[CONTROL]");

            $fdisplay(trace_file,
                "RegWriteD     : %b",
                dut.RegWriteD_w);

            $fdisplay(trace_file,
                "MemWriteD     : %b",
                dut.MemWriteD_w);

            $fdisplay(trace_file,
                "JumpD         : %b",
                dut.JumpD_w);

            $fdisplay(trace_file,
                "BranchD       : %b",
                dut.BranchD_w);

            $fdisplay(trace_file,
                "ALUSrcD       : %b",
                dut.ALUSrcD_w);

            $fdisplay(trace_file,
                "ResultSrcD    : %b",
                dut.ResultSrcD_w);

            $fdisplay(trace_file,
                "ALUControlD   : %03b",
                dut.ALUControlD_w);

            $fdisplay(trace_file,
                "ImmSrcD       : %02b",
                dut.ImmSrcD_w);


            // -------------------------------------------------
            // HAZARD UNIT
            // -------------------------------------------------

            $fdisplay(trace_file, "");
            $fdisplay(trace_file, "[HAZARD]");

            $fdisplay(trace_file,
                "StallF        : %b",
                dut.StallF_w);

            $fdisplay(trace_file,
                "StallD        : %b",
                dut.StallD_w);

            $fdisplay(trace_file,
                "FlushD        : %b",
                dut.FlushD_w);

            $fdisplay(trace_file,
                "FlushE        : %b",
                dut.FlushE_w);

            $fdisplay(trace_file,
                "ForwardAE     : %02b",
                dut.ForwardAE_w);

            $fdisplay(trace_file,
                "ForwardBE     : %02b",
                dut.ForwardBE_w);


            // -------------------------------------------------
            // MEMORY STAGE
            // -------------------------------------------------

            $fdisplay(trace_file, "");
            $fdisplay(trace_file, "[MEMORY]");

            $fdisplay(trace_file,
                "ALUResultM    : 0x%08h (%0d)",
                dut.datapath.ALUResultM_w,
                dut.datapath.ALUResultM_w);

            $fdisplay(trace_file,
                "WriteDataM    : 0x%08h (%0d)",
                dut.datapath.WriteDataM_w,
                dut.datapath.WriteDataM_w);

            $fdisplay(trace_file,
                "ReadDataM     : 0x%08h (%0d)",
                dut.datapath.ReadDataM_w,
                dut.datapath.ReadDataM_w);


            // -------------------------------------------------
            // WRITEBACK
            // -------------------------------------------------

            $fdisplay(trace_file, "");
            $fdisplay(trace_file, "[WRITEBACK]");

            $fdisplay(trace_file,
                "RegWriteW     : %b",
                dut.datapath.RegWriteW_w);

            $fdisplay(trace_file,
                "RdW           : x%0d",
                dut.datapath.RdW_w);

            $fdisplay(trace_file,
                "ResultW       : 0x%08h (%0d)",
                dut.datapath.ResultW_w,
                dut.datapath.ResultW_w);


            // -------------------------------------------------
            // REGISTER FILE
            // -------------------------------------------------

            $fdisplay(trace_file, "");
            $fdisplay(trace_file, "[REGISTERS]");

            $fdisplay(trace_file,
                "x0=%0d x1=%0d x2=%0d x3=%0d",
                dut.datapath.register_file.registers[0],
                dut.datapath.register_file.registers[1],
                dut.datapath.register_file.registers[2],
                dut.datapath.register_file.registers[3]);

            $fdisplay(trace_file,
                "x4=%0d x5=%0d x6=%0d x7=%0d",
                dut.datapath.register_file.registers[4],
                dut.datapath.register_file.registers[5],
                dut.datapath.register_file.registers[6],
                dut.datapath.register_file.registers[7]);

            $fdisplay(trace_file, "");

        end
    end


    // ---------------------------------------------------------
    // MAIN TEST
    // ---------------------------------------------------------

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, riscv_top_tb);

        clk  = 1'b0;
        rstn = 1'b0;

        #20;
        rstn = 1'b1;

        repeat (20) @(posedge clk);

        @(negedge clk);
        #1;


        // -------------------------------------------------
        // FINAL CHECKS
        // -------------------------------------------------

        if (dut.datapath.register_file.registers[1] !== 32'd5)
            $fatal(1, "FAIL: x1");

        if (dut.datapath.register_file.registers[2] !== 32'd7)
            $fatal(1, "FAIL: x2");

        if (dut.datapath.register_file.registers[3] !== 32'd12)
            $fatal(1, "FAIL: x3");

        if (dut.datapath.register_file.registers[4] !== 32'd12)
            $fatal(1, "FAIL: x4");

        if (dut.datapath.register_file.registers[5] !== 32'd17)
            $fatal(1, "FAIL: x5");

        if (dut.datapath.register_file.registers[6] !== 32'd42)
            $fatal(1, "FAIL: x6");

        if (dut.datapath.data_memory.mem[0] !== 32'd12)
            $fatal(1, "FAIL: mem[0]");

        if (dut.datapath.data_memory.mem[1] !== 32'd17)
            $fatal(1, "FAIL: mem[1]");


        $fdisplay(trace_file, "");
        $fdisplay(trace_file,
            "============================================================");
        $fdisplay(trace_file,
            "             ALL TESTS PASSED");
        $fdisplay(trace_file,
            "============================================================");

        $display("ALL PIPELINED RISC-V TESTS PASSED");
        $display("Trace written to pipeline_trace.txt");

        $fclose(trace_file);

        $finish;
    end

endmodule
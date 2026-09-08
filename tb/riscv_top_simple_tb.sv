`timescale 1ps/1ps

module riscv_top_simple_tb;

    logic clk;
    logic rstn;

    integer trace_file;
    integer cycle;

    riscv_top dut (
        .clk  (clk),
        .rstn (rstn)
    );

    always #5 clk = ~clk;


    // ---------------------------------------------------------
    // TRACE FILE
    // ---------------------------------------------------------

    initial begin
        trace_file = $fopen("simple_trace.txt", "w");

        if (trace_file == 0)
            $fatal(1, "Could not open simple_trace.txt");

        $fdisplay(trace_file,
            "CYCLE | PC         | INSTRUCTION | REGISTER WRITE              | DATA MEMORY");

        $fdisplay(trace_file,
            "-----------------------------------------------------------------------------------------");

        cycle = 0;
    end


    // ---------------------------------------------------------
    // TRACE EACH CLOCK
    // ---------------------------------------------------------

    always @(posedge clk) begin
        if (rstn) begin
            cycle = cycle + 1;

            // Allow pipeline registers to update
            #1;

            // Decode-stage PC + instruction
            $fwrite(trace_file,
                "%-5d | 0x%08h | 0x%08h  | ",
                cycle,
                dut.datapath.PCD_w,
                dut.datapath.InstrD_w
            );


            // -------------------------------------------------
            // REGISTER WRITEBACK
            // -------------------------------------------------

            if (dut.datapath.RegWriteW_w &&
                (dut.datapath.RdW_w != 5'd0)) begin

                $fwrite(trace_file,
                    "x%-2d <- 0x%08h (%0d)",
                    dut.datapath.RdW_w,
                    dut.datapath.ResultW_w,
                    dut.datapath.ResultW_w
                );

            end else begin

                $fwrite(trace_file,
                    "--                         "
                );

            end


            $fwrite(trace_file, " | ");


            // -------------------------------------------------
            // DATA MEMORY WRITE
            // -------------------------------------------------

            if (dut.datapath.MemWriteM_w) begin

                $fwrite(trace_file,
                    "WRITE [0x%08h] <- 0x%08h (%0d)",
                    dut.datapath.ALUResultM_w,
                    dut.datapath.WriteDataM_w,
                    dut.datapath.WriteDataM_w
                );

            end else begin

                $fwrite(trace_file, "--");

            end


            $fdisplay(trace_file, "");
        end
    end


    // ---------------------------------------------------------
    // SIMULATION
    // ---------------------------------------------------------

    initial begin
        clk  = 1'b0;
        rstn = 1'b0;

        #20;
        rstn = 1'b1;

        repeat (20) @(posedge clk);

        @(negedge clk);

        $fclose(trace_file);

        $display("Simulation finished.");
        $display("Trace written to simple_trace.txt");

        $finish;
    end

endmodule
`timescale 1ps/1ps

module if_id_reg_tb;

    logic           clk;
    logic           rstn;
    logic           enable_ni;
    logic           clear_i;

    logic   [31:0]  pc_F_i;
    logic   [31:0]  instr_F_i;
    logic   [31:0]  pcp4_F_i;

    logic   [31:0]  pc_D_o;
    logic   [31:0]  instr_D_o;
    logic   [31:0]  pcp4_D_o;

    if_id_reg dut (
        .clk        (clk),
        .rstn       (rstn),
        .enable_ni  (enable_ni),
        .clear_i    (clear_i),

        .pc_F_i     (pc_F_i),
        .instr_F_i  (instr_F_i),
        .pcp4_F_i   (pcp4_F_i),

        .pc_D_o     (pc_D_o),
        .instr_D_o  (instr_D_o),
        .pcp4_D_o   (pcp4_D_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn       = 0;
        enable_ni  = 1;
        clear_i    = 0;

        pc_F_i     = 32'b0;
        instr_F_i  = 32'b0;
        pcp4_F_i   = 32'b0;

        // -----------------------------
        // TEST 1: Reset
        // -----------------------------
        #2;

        if (pc_D_o !== 32'b0 ||
            instr_D_o !== 32'b0 ||
            pcp4_D_o !== 32'b0)
            $fatal(1, "RESET FAILED");

        @(negedge clk);
        rstn = 1;

        // -----------------------------
        // TEST 2: Normal load
        // -----------------------------
        enable_ni = 0;

        pc_F_i     = 32'h0000_0100;
        instr_F_i  = 32'h1234_5678;
        pcp4_F_i   = 32'h0000_0104;

        @(posedge clk);
        #1;

        if (pc_D_o !== 32'h0000_0100 ||
            instr_D_o !== 32'h1234_5678 ||
            pcp4_D_o !== 32'h0000_0104)
            $fatal(1, "LOAD FAILED");

        // -----------------------------
        // TEST 3: Second normal load
        // -----------------------------
        @(negedge clk);

        pc_F_i     = 32'h0000_0104;
        instr_F_i  = 32'hAAAA_BBBB;
        pcp4_F_i   = 32'h0000_0108;

        @(posedge clk);
        #1;

        if (pc_D_o !== 32'h0000_0104 ||
            instr_D_o !== 32'hAAAA_BBBB ||
            pcp4_D_o !== 32'h0000_0108)
            $fatal(1, "SECOND LOAD FAILED");

        // -----------------------------
        // TEST 4: Stall / hold
        // -----------------------------
        @(negedge clk);

        enable_ni = 1;

        pc_F_i     = 32'h0000_0200;
        instr_F_i  = 32'hDEAD_BEEF;
        pcp4_F_i   = 32'h0000_0204;

        @(posedge clk);
        #1;

        if (pc_D_o !== 32'h0000_0104 ||
            instr_D_o !== 32'hAAAA_BBBB ||
            pcp4_D_o !== 32'h0000_0108)
            $fatal(1, "HOLD FAILED");

        // -----------------------------
        // TEST 5: Clear / flush
        // -----------------------------
        @(negedge clk);

        clear_i = 1;

        @(posedge clk);
        #1;

        if (pc_D_o !== 32'b0 ||
            instr_D_o !== 32'b0 ||
            pcp4_D_o !== 32'b0)
            $fatal(1, "CLEAR FAILED");

        // -----------------------------
        // TEST 6: Load after clear
        // -----------------------------
        @(negedge clk);

        clear_i   = 0;
        enable_ni = 0;

        pc_F_i     = 32'h0000_0300;
        instr_F_i  = 32'hCAFE_BABE;
        pcp4_F_i   = 32'h0000_0304;

        @(posedge clk);
        #1;

        if (pc_D_o !== 32'h0000_0300 ||
            instr_D_o !== 32'hCAFE_BABE ||
            pcp4_D_o !== 32'h0000_0304)
            $fatal(1, "LOAD AFTER CLEAR FAILED");

        // -----------------------------
        // TEST 7: Clear priority over enable
        // -----------------------------
        @(negedge clk);

        clear_i   = 1;
        enable_ni = 0;

        pc_F_i     = 32'hFFFF_FFFF;
        instr_F_i  = 32'hFFFF_FFFF;
        pcp4_F_i   = 32'hFFFF_FFFF;

        @(posedge clk);
        #1;

        if (pc_D_o !== 32'b0 ||
            instr_D_o !== 32'b0 ||
            pcp4_D_o !== 32'b0)
            $fatal(1, "CLEAR PRIORITY FAILED");

        $display("ALL TESTS PASSED");
        $finish;
    end

    initial begin
        $monitor(
            "%0t | rstn=%b clear=%b enable_ni=%b | F: pc=%h instr=%h pcp4=%h | D: pc=%h instr=%h pcp4=%h",
            $time,
            rstn,
            clear_i,
            enable_ni,
            pc_F_i,
            instr_F_i,
            pcp4_F_i,
            pc_D_o,
            instr_D_o,
            pcp4_D_o
        );
    end

endmodule
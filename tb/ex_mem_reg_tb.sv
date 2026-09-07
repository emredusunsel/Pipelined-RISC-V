`timescale 1ps/1ps

module ex_mem_reg_tb;

    logic           clk;
    logic           rstn;

    logic   [31:0]  alu_E_i;
    logic   [31:0]  wr_data_E_i;
    logic   [ 4:0]  rd_E_i;
    logic   [31:0]  pcp4_E_i;

    logic   [31:0]  alu_M_o;
    logic   [31:0]  wr_data_M_o;
    logic   [ 4:0]  rd_M_o;
    logic   [31:0]  pcp4_M_o;

    ex_mem_reg dut (
        .clk        (clk),
        .rstn       (rstn),

        .alu_E_i    (alu_E_i),
        .wr_data_E_i(wr_data_E_i),
        .rd_E_i     (rd_E_i),
        .pcp4_E_i   (pcp4_E_i),

        .alu_M_o    (alu_M_o),
        .wr_data_M_o(wr_data_M_o),
        .rd_M_o     (rd_M_o),
        .pcp4_M_o   (pcp4_M_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn        = 0;
        alu_E_i     = '0;
        wr_data_E_i = '0;
        rd_E_i      = '0;
        pcp4_E_i    = '0;

        // Reset
        #10;
        rstn = 1;

        // Test 1
        alu_E_i     = 32'h1234_5678;
        wr_data_E_i = 32'hAAAA_BBBB;
        rd_E_i      = 5'd5;
        pcp4_E_i    = 32'h0000_0014;

        @(posedge clk);
        #1;

        if (alu_M_o     !== 32'h1234_5678 ||
            wr_data_M_o !== 32'hAAAA_BBBB ||
            rd_M_o      !== 5'd5          ||
            pcp4_M_o    !== 32'h0000_0014)
            $fatal(1, "TEST 1 FAILED");

        // Test 2
        @(negedge clk);

        alu_E_i     = 32'hDEAD_BEEF;
        wr_data_E_i = 32'hCAFE_BABE;
        rd_E_i      = 5'd20;
        pcp4_E_i    = 32'h0000_0028;

        @(posedge clk);
        #1;

        if (alu_M_o     !== 32'hDEAD_BEEF ||
            wr_data_M_o !== 32'hCAFE_BABE ||
            rd_M_o      !== 5'd20         ||
            pcp4_M_o    !== 32'h0000_0028)
            $fatal(1, "TEST 2 FAILED");

        // Asynchronous reset test
        #2;
        rstn = 0;
        #1;

        if (alu_M_o     !== 32'h0 ||
            wr_data_M_o !== 32'h0 ||
            rd_M_o      !== 5'b0  ||
            pcp4_M_o    !== 32'h0)
            $fatal(1, "RESET TEST FAILED");

        $display("ALL TESTS PASSED");
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, ex_mem_reg_tb);
    end

endmodule

`timescale 1ps/1ps

module mem_wb_reg_tb;

    logic           clk;
    logic           rstn;

    logic   [31:0]  alu_M_i;
    logic   [31:0]  rd_data_M_i;
    logic   [ 4:0]  rd_M_i;
    logic   [31:0]  pcp4_M_i;

    logic   [31:0]  alu_W_o;
    logic   [31:0]  rd_data_W_o;
    logic   [ 4:0]  rd_W_o;
    logic   [31:0]  pcp4_W_o;


    mem_wb_reg dut (
        .clk        (clk),
        .rstn       (rstn),

        .alu_M_i    (alu_M_i),
        .rd_data_M_i(rd_data_M_i),
        .rd_M_i     (rd_M_i),
        .pcp4_M_i   (pcp4_M_i),

        .alu_W_o    (alu_W_o),
        .rd_data_W_o(rd_data_W_o),
        .rd_W_o     (rd_W_o),
        .pcp4_W_o   (pcp4_W_o)
    );


    initial clk = 0;
    always #5 clk = ~clk;


    initial begin
        rstn        = 0;
        alu_M_i     = '0;
        rd_data_M_i = '0;
        rd_M_i      = '0;
        pcp4_M_i    = '0;

        #10;
        rstn = 1;


        // Test 1
        alu_M_i     = 32'h1234_5678;
        rd_data_M_i = 32'hABCD_EF01;
        rd_M_i      = 5'd10;
        pcp4_M_i    = 32'h0000_0104;

        @(posedge clk);
        #1;

        if (alu_W_o     !== 32'h1234_5678 ||
            rd_data_W_o !== 32'hABCD_EF01 ||
            rd_W_o      !== 5'd10 ||
            pcp4_W_o    !== 32'h0000_0104)
            $fatal(1, "Test 1 failed");


        // Test 2
        alu_M_i     = 32'hDEAD_BEEF;
        rd_data_M_i = 32'hCAFE_BABE;
        rd_M_i      = 5'd31;
        pcp4_M_i    = 32'h0000_0204;

        @(posedge clk);
        #1;

        if (alu_W_o     !== 32'hDEAD_BEEF ||
            rd_data_W_o !== 32'hCAFE_BABE ||
            rd_W_o      !== 5'd31 ||
            pcp4_W_o    !== 32'h0000_0204)
            $fatal(1, "Test 2 failed");


        // Reset test
        rstn = 0;
        #1;

        if (alu_W_o     !== 32'h0 ||
            rd_data_W_o !== 32'h0 ||
            rd_W_o      !== 5'b0 ||
            pcp4_W_o    !== 32'h0)
            $fatal(1, "Reset test failed");


        $display("ALL TESTS PASSED");
        $finish;
    end


    initial begin
        $monitor(
            "%0t | rstn=%b | alu_M=%h rd_data_M=%h rd_M=%d pcp4_M=%h | alu_W=%h rd_data_W=%h rd_W=%d pcp4_W=%h",
            $time,
            rstn,
            alu_M_i,
            rd_data_M_i,
            rd_M_i,
            pcp4_M_i,
            alu_W_o,
            rd_data_W_o,
            rd_W_o,
            pcp4_W_o
        );
    end

endmodule

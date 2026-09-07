`timescale 1ps/1ps

module register_file_tb;

    logic clk, rstn, we_i;
    logic [4:0] rs1_addr_i, rs2_addr_i, rd_addr_i;
    logic [31:0] rd_data_i;
    logic [31:0] rs1_data_o, rs2_data_o;

    register_file dut (
        .clk(clk),
        .rstn(rstn),
        .we_i(we_i),
        .rs1_addr_i(rs1_addr_i),
        .rs2_addr_i(rs2_addr_i),
        .rd_addr_i(rd_addr_i),
        .rd_data_i(rd_data_i),
        .rs1_data_o(rs1_data_o),
        .rs2_data_o(rs2_data_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn       = 0;
        we_i       = 0;
        rs1_addr_i = 0;
        rs2_addr_i = 0;
        rd_addr_i  = 0;
        rd_data_i  = 0;

        // Reset
        #10;
        rstn = 1;

        // Check x0
        #1;
        if (rs1_data_o !== 32'd0)
            $fatal(1, "x0 should be zero");

        // Write 0x11111111 to x1
        @(posedge clk);
        we_i      = 1;
        rd_addr_i = 5'd1;
        rd_data_i = 32'h1111_1111;

        @(negedge clk);
        #1;

        rs1_addr_i = 5'd1;
        #1;

        if (rs1_data_o !== 32'h1111_1111)
            $fatal(1, "x1 write/read failed");

        // Write 0xAAAAAAAA to x10
        @(posedge clk);
        rd_addr_i = 5'd10;
        rd_data_i = 32'hAAAA_AAAA;

        @(negedge clk);
        #1;

        // Write 0x55555555 to x20
        @(posedge clk);
        rd_addr_i = 5'd20;
        rd_data_i = 32'h5555_5555;

        @(negedge clk);
        #1;

        // Read x10 and x20 simultaneously
        rs1_addr_i = 5'd10;
        rs2_addr_i = 5'd20;
        #1;

        if (rs1_data_o !== 32'hAAAA_AAAA)
            $fatal(1, "rs1 read failed");

        if (rs2_data_o !== 32'h5555_5555)
            $fatal(1, "rs2 read failed");

        // Try writing to x0
        @(posedge clk);
        rd_addr_i = 5'd0;
        rd_data_i = 32'hFFFF_FFFF;

        @(negedge clk);
        #1;

        rs1_addr_i = 5'd0;
        #1;

        if (rs1_data_o !== 32'd0)
            $fatal(1, "x0 was modified");

        // Disable write
        @(posedge clk);
        we_i = 0;

        #10;

        $display("REGISTER FILE TEST PASSED");
        $finish;
    end

    initial begin
        $monitor(
            "%0t | WE=%b RD=%0d DATA=%h | RS1=%0d:%h RS2=%0d:%h",
            $time,
            we_i,
            rd_addr_i,
            rd_data_i,
            rs1_addr_i,
            rs1_data_o,
            rs2_addr_i,
            rs2_data_o
        );
    end

endmodule

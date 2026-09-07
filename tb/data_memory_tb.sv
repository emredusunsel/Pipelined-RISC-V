`timescale 1ps/1ps

module data_memory_tb;

    localparam int DEPTH = 256;

    logic        clk;
    logic        we_i;
    logic [31:0] addr_i;
    logic [31:0] wr_data_i;
    logic [31:0] rd_data_o;

    data_memory #(
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .we_i(we_i),
        .addr_i(addr_i),
        .wr_data_i(wr_data_i),
        .rd_data_o(rd_data_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task write_mem(
        input logic [31:0] addr,
        input logic [31:0] data
    );
        begin
            @(negedge clk);
            we_i      = 1;
            addr_i    = addr;
            wr_data_i = data;

            @(posedge clk);
            #1;

            we_i = 0;
        end
    endtask

    task check_mem(
        input logic [31:0] addr,
        input logic [31:0] expected
    );
        begin
            addr_i = addr;
            #1;

            if (rd_data_o !== expected) begin
                $display(
                    "FAIL | addr=%h expected=%h got=%h",
                    addr,
                    expected,
                    rd_data_o
                );
                $fatal;
            end
            else begin
                $display(
                    "PASS | addr=%h data=%h",
                    addr,
                    rd_data_o
                );
            end
        end
    endtask

    initial begin
        we_i      = 0;
        addr_i    = 0;
        wr_data_i = 0;

        #10;

        // Write different memory locations
        write_mem(32'h0000_0000, 32'h1234_5678);
        write_mem(32'h0000_0004, 32'hDEAD_BEEF);
        write_mem(32'h0000_0008, 32'hCAFE_BABE);
        write_mem(32'h0000_000C, 32'hABCD_EF01);

        // Read them back
        check_mem(32'h0000_0000, 32'h1234_5678);
        check_mem(32'h0000_0004, 32'hDEAD_BEEF);
        check_mem(32'h0000_0008, 32'hCAFE_BABE);
        check_mem(32'h0000_000C, 32'hABCD_EF01);

        // Overwrite an existing location
        write_mem(32'h0000_0004, 32'h1111_2222);
        check_mem(32'h0000_0004, 32'h1111_2222);

        // Make sure another location was not affected
        check_mem(32'h0000_0008, 32'hCAFE_BABE);

        $display("\nALL DATA MEMORY TESTS PASSED");
        $finish;
    end

endmodule
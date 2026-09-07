`timescale 1ps/1ps

module mux3_tb;

    localparam int WIDTH = 32;

    logic [WIDTH-1:0] data0_i;
    logic [WIDTH-1:0] data1_i;
    logic [WIDTH-1:0] data2_i;
    logic [1:0]       sel_i;
    logic [WIDTH-1:0] data_o;

    mux3 #(
        .WIDTH(WIDTH)
    ) dut (
        .data0_i(data0_i),
        .data1_i(data1_i),
        .data2_i(data2_i),
        .sel_i(sel_i),
        .data_o(data_o)
    );

    initial begin

        data0_i = 32'h1111_1111;
        data1_i = 32'h2222_2222;
        data2_i = 32'h3333_3333;

        sel_i = 2'b00;
        #10;

        if (data_o !== data0_i)
            $fatal(1, "MUX3 failed for sel=00");

        sel_i = 2'b01;
        #10;

        if (data_o !== data1_i)
            $fatal(1, "MUX3 failed for sel=01");

        sel_i = 2'b10;
        #10;

        if (data_o !== data2_i)
            $fatal(1, "MUX3 failed for sel=10");

        // Invalid select
        sel_i = 2'b11;
        #10;

        if (data_o !== 32'h0000_0000)
            $fatal(1, "MUX3 failed for invalid sel=11");


        // Change inputs and test again
        data0_i = 32'hAAAA_AAAA;
        data1_i = 32'hBBBB_BBBB;
        data2_i = 32'hCCCC_CCCC;

        sel_i = 2'b10;
        #10;

        if (data_o !== data2_i)
            $fatal(1, "MUX3 failed second test for sel=10");


        $display("MUX3 TB PASSED");
        $finish;

    end

endmodule

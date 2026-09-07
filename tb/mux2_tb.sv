`timescale 1ps/1ps

module mux2_tb;

    localparam int WIDTH = 32;

    logic [WIDTH-1:0] data0_i;
    logic [WIDTH-1:0] data1_i;
    logic             sel_i;
    logic [WIDTH-1:0] data_o;

    mux2 #(
        .WIDTH(WIDTH)
    ) dut (
        .data0_i(data0_i),
        .data1_i(data1_i),
        .sel_i(sel_i),
        .data_o(data_o)
    );

    initial begin

        data0_i = 32'hAAAA_AAAA;
        data1_i = 32'hBBBB_BBBB;

        sel_i = 1'b0;
        #10;

        if (data_o !== data0_i)
            $fatal(1, "MUX2 failed for sel=0");

        sel_i = 1'b1;
        #10;

        if (data_o !== data1_i)
            $fatal(1, "MUX2 failed for sel=1");


        // Change inputs and test again
        data0_i = 32'h1234_5678;
        data1_i = 32'h8765_4321;

        sel_i = 1'b0;
        #10;

        if (data_o !== data0_i)
            $fatal(1, "MUX2 failed second test for sel=0");

        sel_i = 1'b1;
        #10;

        if (data_o !== data1_i)
            $fatal(1, "MUX2 failed second test for sel=1");


        $display("MUX2 TB PASSED");
        $finish;

    end

endmodule
`timescale 1ps/1ps

module pc_target_adder_tb;

    logic [31:0] pc_i;
    logic [31:0] imm_i;
    logic [31:0] pc_target_o;

    pc_target_adder dut (
        .pc_i(pc_i),
        .imm_i(imm_i),
        .pc_target_o(pc_target_o)
    );

    initial begin

        pc_i  = 32'h0000_1000;
        imm_i = 32'h0000_0010;
        #10;

        if (pc_target_o !== 32'h0000_1010)
            $fatal(1, "Test 1 failed");


        pc_i  = 32'h0000_2000;
        imm_i = 32'hFFFF_FFF0;   // -16
        #10;

        if (pc_target_o !== 32'h0000_1FF0)
            $fatal(1, "Test 2 failed");


        pc_i  = 32'h0000_0000;
        imm_i = 32'h0000_0004;
        #10;

        if (pc_target_o !== 32'h0000_0004)
            $fatal(1, "Test 3 failed");


        pc_i  = 32'hFFFF_FFFC;
        imm_i = 32'h0000_0004;
        #10;

        if (pc_target_o !== 32'h0000_0000)
            $fatal(1, "Test 4 failed");


        $display("PC TARGET ADDER TB PASSED");
        $finish;

    end

endmodule
`timescale 1ps/1ps

module alu_tb;

    logic   [31:0]  a_i;
    logic   [31:0]  b_i;
    logic   [ 2:0]  alu_ctrl_i;
    logic   [31:0]  result_o;
    logic           zero_o;

    localparam logic [2:0] ALU_ADD  = 3'b000;
    localparam logic [2:0] ALU_SUB  = 3'b001;
    localparam logic [2:0] ALU_AND  = 3'b010;
    localparam logic [2:0] ALU_OR   = 3'b011;
    localparam logic [2:0] ALU_SLT  = 3'b101;

    alu dut (
        .a_i        (a_i),
        .b_i        (b_i),
        .alu_ctrl_i (alu_ctrl_i),
        .result_o   (result_o),
        .zero_o     (zero_o)
    );

    task automatic check_result (
        input logic [31:0] a,
        input logic [31:0] b,
        input logic [2:0]  ctrl,
        input logic [31:0] expected_result,
        input logic        expected_zero
    );
        begin
            a_i        = a;
            b_i        = b;
            alu_ctrl_i = ctrl;

            #1;

            if (result_o !== expected_result)
                $fatal(1,
                    "FAIL: a=%h b=%h ctrl=%b result=%h expected=%h",
                    a, b, ctrl, result_o, expected_result
                );

            if (zero_o !== expected_zero)
                $fatal(1,
                    "FAIL ZERO: a=%h b=%h ctrl=%b zero=%b expected=%b",
                    a, b, ctrl, zero_o, expected_zero
                );
        end
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // ADD
        check_result(32'd10, 32'd20, ALU_ADD, 32'd30, 1'b0);
        check_result(32'd0,  32'd0,  ALU_ADD, 32'd0,  1'b1);

        // SUB
        check_result(32'd20, 32'd10, ALU_SUB, 32'd10, 1'b0);
        check_result(32'd10, 32'd10, ALU_SUB, 32'd0,  1'b1);

        // AND
        check_result(
            32'hF0F0_F0F0,
            32'h0FF0_0FF0,
            ALU_AND,
            32'h00F0_00F0,
            1'b0
        );

        // OR
        check_result(
            32'hF000_000F,
            32'h0F00_00F0,
            ALU_OR,
            32'hFF00_00FF,
            1'b0
        );

        // SLT signed
        check_result(32'd5,  32'd10, ALU_SLT, 32'd1, 1'b0);
        check_result(32'd10, 32'd5,  ALU_SLT, 32'd0, 1'b1);

        // Negative signed comparison: -1 < 1
        check_result(
            32'hFFFF_FFFF,
            32'd1,
            ALU_SLT,
            32'd1,
            1'b0
        );

        // 1 < -1 should be false
        check_result(
            32'd1,
            32'hFFFF_FFFF,
            ALU_SLT,
            32'd0,
            1'b1
        );

        // Default / unsupported control
        check_result(32'd123, 32'd456, 3'b111, 32'd0, 1'b1);

        $display("ALL ALU TESTS PASSED");
        $finish;
    end

endmodule

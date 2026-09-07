`timescale 1ps/1ps

module alu_tb;

    logic [31:0] a_i;
    logic [31:0] b_i;
    logic [3:0]  alu_ctrl_i;
    logic [31:0] result_o;
    logic        zero_o;

    localparam logic [3:0] ALU_ADD  = 4'b0000;
    localparam logic [3:0] ALU_SUB  = 4'b0001;
    localparam logic [3:0] ALU_AND  = 4'b0010;
    localparam logic [3:0] ALU_OR   = 4'b0011;
    localparam logic [3:0] ALU_XOR  = 4'b0100;
    localparam logic [3:0] ALU_SLL  = 4'b0101;
    localparam logic [3:0] ALU_SRL  = 4'b0110;
    localparam logic [3:0] ALU_SRA  = 4'b0111;
    localparam logic [3:0] ALU_SLT  = 4'b1000;
    localparam logic [3:0] ALU_SLTU = 4'b1001;

    alu dut (
        .a_i(a_i),
        .b_i(b_i),
        .alu_ctrl_i(alu_ctrl_i),
        .result_o(result_o),
        .zero_o(zero_o)
    );

    task automatic check_result(
        input logic [31:0] a,
        input logic [31:0] b,
        input logic [3:0]  ctrl,
        input logic [31:0] expected
    );
        begin
            a_i        = a;
            b_i        = b;
            alu_ctrl_i = ctrl;

            #1;

            if (result_o !== expected) begin
                $display(
                    "FAIL: ctrl=%b a=%h b=%h result=%h expected=%h",
                    ctrl, a, b, result_o, expected
                );
                $fatal;
            end
            else begin
                $display(
                    "PASS: ctrl=%b a=%h b=%h result=%h",
                    ctrl, a, b, result_o
                );
            end
        end
    endtask

    initial begin

        a_i        = '0;
        b_i        = '0;
        alu_ctrl_i = '0;

        #1;

        // ADD
        check_result(32'd10, 32'd5, ALU_ADD, 32'd15);

        // SUB
        check_result(32'd10, 32'd5, ALU_SUB, 32'd5);
        check_result(32'd5,  32'd10, ALU_SUB, 32'hFFFF_FFFB);

        // AND
        check_result(
            32'hF0F0_F0F0,
            32'h0FF0_0FF0,
            ALU_AND,
            32'h00F0_00F0
        );

        // OR
        check_result(
            32'hF000_F000,
            32'h0F00_0F00,
            ALU_OR,
            32'hFF00_FF00
        );

        // XOR
        check_result(
            32'hAAAA_AAAA,
            32'hFFFF_0000,
            ALU_XOR,
            32'h5555_AAAA
        );

        // SLL
        check_result(32'h0000_0001, 32'd4, ALU_SLL, 32'h0000_0010);

        // SRL
        check_result(32'h8000_0000, 32'd4, ALU_SRL, 32'h0800_0000);

        // SRA
        check_result(32'h8000_0000, 32'd4, ALU_SRA, 32'hF800_0000);

        // SLT signed: -1 < 1
        check_result(
            32'hFFFF_FFFF,
            32'h0000_0001,
            ALU_SLT,
            32'h0000_0001
        );

        // SLT signed: 5 < -1 => false
        check_result(
            32'h0000_0005,
            32'hFFFF_FFFF,
            ALU_SLT,
            32'h0000_0000
        );

        // SLTU: 0xFFFFFFFF < 1 => false
        check_result(
            32'hFFFF_FFFF,
            32'h0000_0001,
            ALU_SLTU,
            32'h0000_0000
        );

        // SLTU: 1 < 0xFFFFFFFF => true
        check_result(
            32'h0000_0001,
            32'hFFFF_FFFF,
            ALU_SLTU,
            32'h0000_0001
        );

        // zero_o check
        a_i        = 32'd5;
        b_i        = 32'd5;
        alu_ctrl_i = ALU_SUB;

        #1;

        if (zero_o !== 1'b1) begin
            $display("FAIL: zero_o should be 1");
            $fatal;
        end

        $display("PASS: zero_o");

        // non-zero check
        a_i        = 32'd5;
        b_i        = 32'd3;
        alu_ctrl_i = ALU_SUB;

        #1;

        if (zero_o !== 1'b0) begin
            $display("FAIL: zero_o should be 0");
            $fatal;
        end

        $display("PASS: zero_o non-zero case");

        $display("\nALL ALU TESTS PASSED");
        $finish;

    end

endmodule

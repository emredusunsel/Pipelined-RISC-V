`timescale 1ps/1ps

module id_ex_reg_tb;

    logic clk;
    logic rstn;
    logic clear_i;

    logic [31:0] rd1_D_i;
    logic [31:0] rd2_D_i;
    logic [31:0] pc_D_i;
    logic [ 4:0] rs1_D_i;
    logic [ 4:0] rs2_D_i;
    logic [ 4:0] rd_D_i;
    logic [31:0] imm_ext_D_i;
    logic [31:0] pcp4_D_i;

    logic [31:0] rd1_E_o;
    logic [31:0] rd2_E_o;
    logic [31:0] pc_E_o;
    logic [ 4:0] rs1_E_o;
    logic [ 4:0] rs2_E_o;
    logic [ 4:0] rd_E_o;
    logic [31:0] imm_ext_E_o;
    logic [31:0] pcp4_E_o;

    id_ex_reg dut (
        .clk        (clk),
        .rstn       (rstn),
        .clear_i    (clear_i),

        .rd1_D_i    (rd1_D_i),
        .rd2_D_i    (rd2_D_i),
        .pc_D_i     (pc_D_i),
        .rs1_D_i    (rs1_D_i),
        .rs2_D_i    (rs2_D_i),
        .rd_D_i     (rd_D_i),
        .imm_ext_D_i(imm_ext_D_i),
        .pcp4_D_i   (pcp4_D_i),

        .rd1_E_o    (rd1_E_o),
        .rd2_E_o    (rd2_E_o),
        .pc_E_o     (pc_E_o),
        .rs1_E_o    (rs1_E_o),
        .rs2_E_o    (rs2_E_o),
        .rd_E_o     (rd_E_o),
        .imm_ext_E_o(imm_ext_E_o),
        .pcp4_E_o   (pcp4_E_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn        = 0;
        clear_i     = 0;

        rd1_D_i     = '0;
        rd2_D_i     = '0;
        pc_D_i      = '0;
        rs1_D_i     = '0;
        rs2_D_i     = '0;
        rd_D_i      = '0;
        imm_ext_D_i = '0;
        pcp4_D_i    = '0;

        // Reset
        #10;
        rstn = 1;

        // Load first values
        rd1_D_i     = 32'h1111_1111;
        rd2_D_i     = 32'h2222_2222;
        pc_D_i      = 32'h0000_0100;
        rs1_D_i     = 5'd1;
        rs2_D_i     = 5'd2;
        rd_D_i      = 5'd3;
        imm_ext_D_i = 32'hFFFF_FFFC;
        pcp4_D_i    = 32'h0000_0104;

        #10;

        // Load second values
        rd1_D_i     = 32'hAAAA_AAAA;
        rd2_D_i     = 32'hBBBB_BBBB;
        pc_D_i      = 32'h0000_0200;
        rs1_D_i     = 5'd10;
        rs2_D_i     = 5'd11;
        rd_D_i      = 5'd12;
        imm_ext_D_i = 32'h0000_1234;
        pcp4_D_i    = 32'h0000_0204;

        #10;

        // Clear / insert bubble
        clear_i = 1;

        #10;

        clear_i = 0;

        // New values after clear
        rd1_D_i     = 32'h1234_5678;
        rd2_D_i     = 32'h8765_4321;
        pc_D_i      = 32'h0000_0300;
        rs1_D_i     = 5'd20;
        rs2_D_i     = 5'd21;
        rd_D_i      = 5'd22;
        imm_ext_D_i = 32'h0000_0040;
        pcp4_D_i    = 32'h0000_0304;

        #10;

        // Asynchronous reset test
        rstn = 0;

        #5;

        $finish;
    end

    initial begin
        $monitor(
            "%0t rstn=%b clear=%b | pc_D=%h -> pc_E=%h | rs1=%0d rs2=%0d rd=%0d",
            $time,
            rstn,
            clear_i,
            pc_D_i,
            pc_E_o,
            rs1_E_o,
            rs2_E_o,
            rd_E_o
        );
    end

endmodule

`timescale 1ps/1ps

module hazard_unit_tb;

    logic [4:0] rs1_addr_i;
    logic [4:0] rs2_addr_i;
    logic [4:0] rd_E_i;
    logic [4:0] rs1_E_i;
    logic [4:0] rs2_E_i;
    logic       pc_src_i;
    logic       result_src_E_i;
    logic [4:0] rd_M_i;
    logic       reg_write_M_i;
    logic [4:0] rd_W_i;
    logic       reg_write_W_i;

    logic       stall_F_o;
    logic       stall_D_o;
    logic       flush_D_o;
    logic       flush_E_o;
    logic [1:0] forwardA_E_o;
    logic [1:0] forwardB_E_o;

    hazard_unit dut (
        .rs1_addr_i       (rs1_addr_i),
        .rs2_addr_i       (rs2_addr_i),
        .rd_E_i           (rd_E_i),
        .rs1_E_i          (rs1_E_i),
        .rs2_E_i          (rs2_E_i),
        .pc_src_i         (pc_src_i),
        .result_src_E_i   (result_src_E_i),
        .rd_M_i           (rd_M_i),
        .reg_write_M_i    (reg_write_M_i),
        .rd_W_i           (rd_W_i),
        .reg_write_W_i    (reg_write_W_i),

        .stall_F_o        (stall_F_o),
        .stall_D_o        (stall_D_o),
        .flush_D_o        (flush_D_o),
        .flush_E_o        (flush_E_o),
        .forwardA_E_o     (forwardA_E_o),
        .forwardB_E_o     (forwardB_E_o)
    );

    initial begin

        // Default values
        rs1_addr_i     = 5'd0;
        rs2_addr_i     = 5'd0;
        rd_E_i         = 5'd0;
        rs1_E_i        = 5'd0;
        rs2_E_i        = 5'd0;
        pc_src_i       = 1'b0;
        result_src_E_i = 1'b0;
        rd_M_i         = 5'd0;
        reg_write_M_i  = 1'b0;
        rd_W_i         = 5'd0;
        reg_write_W_i  = 1'b0;

        #10;

        // TEST 1: No forwarding
        rs1_E_i = 5'd1;
        rs2_E_i = 5'd2;
        rd_M_i  = 5'd3;
        rd_W_i  = 5'd4;

        #10;

        if ((forwardA_E_o !== 2'b00) ||
            (forwardB_E_o !== 2'b00))
            $fatal(1, "TEST 1 FAILED");

        $display("TEST 1 PASSED: No forwarding");


        // TEST 2: Forward A from MEM
        rs1_E_i       = 5'd5;
        rd_M_i        = 5'd5;
        reg_write_M_i = 1'b1;

        #10;

        if (forwardA_E_o !== 2'b10)
            $fatal(1, "TEST 2 FAILED");

        $display("TEST 2 PASSED: Forward A from MEM");


        // TEST 3: Forward B from MEM
        rs1_E_i = 5'd1;
        rs2_E_i = 5'd6;
        rd_M_i  = 5'd6;

        #10;

        if (forwardB_E_o !== 2'b10)
            $fatal(1, "TEST 3 FAILED");

        $display("TEST 3 PASSED: Forward B from MEM");


        // TEST 4: Forward A from WB
        reg_write_M_i = 1'b0;

        rs1_E_i       = 5'd7;
        rd_W_i        = 5'd7;
        reg_write_W_i = 1'b1;

        #10;

        if (forwardA_E_o !== 2'b01)
            $fatal(1, "TEST 4 FAILED");

        $display("TEST 4 PASSED: Forward A from WB");


        // TEST 5: Forward B from WB
        rs1_E_i = 5'd1;
        rs2_E_i = 5'd8;
        rd_W_i  = 5'd8;

        #10;

        if (forwardB_E_o !== 2'b01)
            $fatal(1, "TEST 5 FAILED");

        $display("TEST 5 PASSED: Forward B from WB");


        // TEST 6: MEM forwarding has priority over WB
        rs1_E_i = 5'd9;

        rd_M_i        = 5'd9;
        reg_write_M_i = 1'b1;

        rd_W_i        = 5'd9;
        reg_write_W_i = 1'b1;

        #10;

        if (forwardA_E_o !== 2'b10)
            $fatal(1, "TEST 6 FAILED");

        $display("TEST 6 PASSED: MEM forwarding priority");


        // TEST 7: x0 must not be forwarded
        rs1_E_i = 5'd0;
        rs2_E_i = 5'd0;
        rd_M_i  = 5'd0;
        rd_W_i  = 5'd0;

        #10;

        if ((forwardA_E_o !== 2'b00) ||
            (forwardB_E_o !== 2'b00))
            $fatal(1, "TEST 7 FAILED");

        $display("TEST 7 PASSED: x0 not forwarded");


        reg_write_M_i = 1'b0;
        reg_write_W_i = 1'b0;


        // TEST 8: Load-use hazard through rs1
        result_src_E_i = 1'b1;
        rd_E_i         = 5'd10;
        rs1_addr_i     = 5'd10;
        rs2_addr_i     = 5'd3;

        #10;

        if ((stall_F_o !== 1'b1) ||
            (stall_D_o !== 1'b1) ||
            (flush_E_o !== 1'b1))
            $fatal(1, "TEST 8 FAILED");

        $display("TEST 8 PASSED: Load-use hazard through rs1");


        // TEST 9: Load-use hazard through rs2
        rs1_addr_i = 5'd2;
        rs2_addr_i = 5'd10;

        #10;

        if ((stall_F_o !== 1'b1) ||
            (stall_D_o !== 1'b1) ||
            (flush_E_o !== 1'b1))
            $fatal(1, "TEST 9 FAILED");

        $display("TEST 9 PASSED: Load-use hazard through rs2");


        // TEST 10: Matching register, but instruction is not a load
        result_src_E_i = 1'b0;

        #10;

        if ((stall_F_o !== 1'b0) ||
            (stall_D_o !== 1'b0) ||
            (flush_E_o !== 1'b0))
            $fatal(1, "TEST 10 FAILED");

        $display("TEST 10 PASSED: No stall for non-load");


        // TEST 11: Branch/jump taken
        pc_src_i = 1'b1;

        #10;

        if ((flush_D_o !== 1'b1) ||
            (flush_E_o !== 1'b1))
            $fatal(1, "TEST 11 FAILED");

        $display("TEST 11 PASSED: PC redirect flush");


        // TEST 12: Load-use hazard and PC redirect together
        result_src_E_i = 1'b1;
        rd_E_i         = 5'd12;
        rs1_addr_i     = 5'd12;

        #10;

        if ((stall_F_o !== 1'b1) ||
            (stall_D_o !== 1'b1) ||
            (flush_D_o !== 1'b1) ||
            (flush_E_o !== 1'b1))
            $fatal(1, "TEST 12 FAILED");

        $display("TEST 12 PASSED: Stall and flush together");


        // TEST 13: Normal operation
        pc_src_i       = 1'b0;
        result_src_E_i = 1'b0;
        rd_E_i         = 5'd3;
        rs1_addr_i     = 5'd1;
        rs2_addr_i     = 5'd2;

        #10;

        if ((stall_F_o !== 1'b0) ||
            (stall_D_o !== 1'b0) ||
            (flush_D_o !== 1'b0) ||
            (flush_E_o !== 1'b0))
            $fatal(1, "TEST 13 FAILED");

        $display("TEST 13 PASSED: Normal operation");


        $display("\nALL HAZARD UNIT TESTS PASSED\n");

        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, hazard_unit_tb);
    end

endmodule
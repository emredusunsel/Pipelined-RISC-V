`timescale 1ps/1ps

module immediate_extender_tb;

    localparam logic [2:0] IMM_I = 3'b000;
    localparam logic [2:0] IMM_S = 3'b001;
    localparam logic [2:0] IMM_B = 3'b010;
    localparam logic [2:0] IMM_U = 3'b011;
    localparam logic [2:0] IMM_J = 3'b100;

    logic [31:7] instr_i;
    logic [2:0]  imm_sel_i;
    logic [31:0] imm_o;

    immediate_extender dut (
        .instr_i   (instr_i),
        .imm_sel_i (imm_sel_i),
        .imm_o     (imm_o)
    );

    initial begin

        // I-type: immediate = +5
        instr_i   = '0;
        instr_i[31:20] = 12'd5;
        imm_sel_i = IMM_I;
        #10;

        if (imm_o !== 32'd5)
            $fatal(1, "I-type failed: expected 5, got %h", imm_o);


        // I-type: immediate = -1
        instr_i   = '0;
        instr_i[31:20] = 12'hFFF;
        imm_sel_i = IMM_I;
        #10;

        if (imm_o !== 32'hFFFFFFFF)
            $fatal(1, "I-type negative failed: expected FFFFFFFF, got %h", imm_o);


        // S-type: immediate = 12
        instr_i   = '0;
        instr_i[31:25] = 7'b0000000;
        instr_i[11:7]  = 5'b01100;
        imm_sel_i = IMM_S;
        #10;

        if (imm_o !== 32'd12)
            $fatal(1, "S-type failed: expected 12, got %h", imm_o);


        // B-type: immediate = 8
        instr_i   = '0;
        instr_i[31]    = 1'b0;
        instr_i[7]     = 1'b0;
        instr_i[30:25] = 6'b000000;
        instr_i[11:8]  = 4'b0100;
        imm_sel_i = IMM_B;
        #10;

        if (imm_o !== 32'd8)
            $fatal(1, "B-type failed: expected 8, got %h", imm_o);


        // U-type: immediate = 0x12345000
        instr_i   = '0;
        instr_i[31:12] = 20'h12345;
        imm_sel_i = IMM_U;
        #10;

        if (imm_o !== 32'h12345000)
            $fatal(1, "U-type failed: expected 12345000, got %h", imm_o);


        // J-type: immediate = 16
        instr_i   = '0;
        instr_i[31]    = 1'b0;
        instr_i[19:12] = 8'b00000000;
        instr_i[20]    = 1'b0;
        instr_i[30:21] = 10'b0000001000;
        imm_sel_i = IMM_J;
        #10;

        if (imm_o !== 32'd16)
            $fatal(1, "J-type failed: expected 16, got %h", imm_o);


        $display("All immediate extender tests passed.");
        $finish;

    end

    initial begin
        $monitor(
            "%0t | imm_sel=%b | instr=%h | imm=%h",
            $time,
            imm_sel_i,
            instr_i,
            imm_o
        );
    end

endmodule

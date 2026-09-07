`timescale 1ps/1ps

module control_unit_tb;

    logic [6:0] opcode_i;
    logic [2:0] funct3_i;
    logic       funct7_5_i;
    logic       zero_i;

    logic       pc_src_o;
    logic       reg_write_o;
    logic [1:0] result_src_o;
    logic       mem_write_o;
    logic       alu_src_o;
    logic [1:0] imm_src_o;
    logic [2:0] alu_control_o;

    control_unit dut (
        .opcode_i(opcode_i),
        .funct3_i(funct3_i),
        .funct7_5_i(funct7_5_i),
        .zero_i(zero_i),
        .pc_src_o(pc_src_o),
        .reg_write_o(reg_write_o),
        .result_src_o(result_src_o),
        .mem_write_o(mem_write_o),
        .alu_src_o(alu_src_o),
        .imm_src_o(imm_src_o),
        .alu_control_o(alu_control_o)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, control_unit_tb);

        // LW
        opcode_i   = 7'b0000011;
        funct3_i   = 3'b010;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(reg_write_o   == 1'b1)   else $fatal(1, "LW: reg_write failed");
        assert(result_src_o  == 2'b01)  else $fatal(1, "LW: result_src failed");
        assert(mem_write_o   == 1'b0)   else $fatal(1, "LW: mem_write failed");
        assert(alu_src_o     == 1'b1)   else $fatal(1, "LW: alu_src failed");
        assert(imm_src_o     == 2'b00)  else $fatal(1, "LW: imm_src failed");
        assert(alu_control_o == 3'b000) else $fatal(1, "LW: alu_control failed");
        assert(pc_src_o      == 1'b0)   else $fatal(1, "LW: pc_src failed");

        // SW
        opcode_i   = 7'b0100011;
        funct3_i   = 3'b010;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(reg_write_o   == 1'b0)   else $fatal(1, "SW: reg_write failed");
        assert(mem_write_o   == 1'b1)   else $fatal(1, "SW: mem_write failed");
        assert(alu_src_o     == 1'b1)   else $fatal(1, "SW: alu_src failed");
        assert(imm_src_o     == 2'b01)  else $fatal(1, "SW: imm_src failed");
        assert(alu_control_o == 3'b000) else $fatal(1, "SW: alu_control failed");
        assert(pc_src_o      == 1'b0)   else $fatal(1, "SW: pc_src failed");

        // ADD
        opcode_i   = 7'b0110011;
        funct3_i   = 3'b000;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(reg_write_o   == 1'b1)   else $fatal(1, "ADD: reg_write failed");
        assert(result_src_o  == 2'b00)  else $fatal(1, "ADD: result_src failed");
        assert(mem_write_o   == 1'b0)   else $fatal(1, "ADD: mem_write failed");
        assert(alu_src_o     == 1'b0)   else $fatal(1, "ADD: alu_src failed");
        assert(alu_control_o == 3'b000) else $fatal(1, "ADD: alu_control failed");

        // SUB
        opcode_i   = 7'b0110011;
        funct3_i   = 3'b000;
        funct7_5_i = 1'b1;
        zero_i     = 1'b0;
        #10;

        assert(alu_control_o == 3'b001)
            else $fatal(1, "SUB: alu_control failed");

        // AND
        opcode_i   = 7'b0110011;
        funct3_i   = 3'b111;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(alu_control_o == 3'b010)
            else $fatal(1, "AND: alu_control failed");

        // OR
        opcode_i   = 7'b0110011;
        funct3_i   = 3'b110;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(alu_control_o == 3'b011)
            else $fatal(1, "OR: alu_control failed");

        // SLT
        opcode_i   = 7'b0110011;
        funct3_i   = 3'b010;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(alu_control_o == 3'b101)
            else $fatal(1, "SLT: alu_control failed");

        // ADDI
        opcode_i   = 7'b0010011;
        funct3_i   = 3'b000;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(reg_write_o   == 1'b1)   else $fatal(1, "ADDI: reg_write failed");
        assert(result_src_o  == 2'b00)  else $fatal(1, "ADDI: result_src failed");
        assert(mem_write_o   == 1'b0)   else $fatal(1, "ADDI: mem_write failed");
        assert(alu_src_o     == 1'b1)   else $fatal(1, "ADDI: alu_src failed");
        assert(imm_src_o     == 2'b00)  else $fatal(1, "ADDI: imm_src failed");
        assert(alu_control_o == 3'b000) else $fatal(1, "ADDI: alu_control failed");

        // BEQ - not taken
        opcode_i   = 7'b1100011;
        funct3_i   = 3'b000;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(reg_write_o   == 1'b0)   else $fatal(1, "BEQ: reg_write failed");
        assert(mem_write_o   == 1'b0)   else $fatal(1, "BEQ: mem_write failed");
        assert(alu_src_o     == 1'b0)   else $fatal(1, "BEQ: alu_src failed");
        assert(imm_src_o     == 2'b10)  else $fatal(1, "BEQ: imm_src failed");
        assert(alu_control_o == 3'b001) else $fatal(1, "BEQ: alu_control failed");
        assert(pc_src_o      == 1'b0)   else $fatal(1, "BEQ not taken: pc_src failed");

        // BEQ - taken
        zero_i = 1'b1;
        #10;

        assert(pc_src_o == 1'b1)
            else $fatal(1, "BEQ taken: pc_src failed");

        // JAL
        opcode_i   = 7'b1101111;
        funct3_i   = 3'b000;
        funct7_5_i = 1'b0;
        zero_i     = 1'b0;
        #10;

        assert(reg_write_o  == 1'b1)  else $fatal(1, "JAL: reg_write failed");
        assert(result_src_o == 2'b10) else $fatal(1, "JAL: result_src failed");
        assert(mem_write_o  == 1'b0)  else $fatal(1, "JAL: mem_write failed");
        assert(imm_src_o    == 2'b11) else $fatal(1, "JAL: imm_src failed");
        assert(pc_src_o     == 1'b1)  else $fatal(1, "JAL: pc_src failed");

        $display("ALL CONTROL UNIT TESTS PASSED");
        $finish;
    end

endmodule
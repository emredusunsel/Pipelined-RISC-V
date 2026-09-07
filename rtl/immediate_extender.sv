`timescale 1ps/1ps

module immediate_extender (
    input   logic   [31:7]  instr_i,
    input   logic   [ 1:0]  imm_sel_i,
    output  logic   [31:0]  imm_o
);

    localparam logic [2:0] IMM_I = 2'b00;
    localparam logic [2:0] IMM_S = 2'b01;
    localparam logic [2:0] IMM_B = 2'b10;
    localparam logic [2:0] IMM_J = 2'b11;

    always_comb begin : extend_block
        case (imm_sel_i)
            IMM_I: imm_o = {{20{instr_i[31]}}, instr_i[31:20]};

            IMM_S: imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};

            IMM_B: imm_o = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};

            IMM_J: imm_o = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};

            default: imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
        endcase
    end

endmodule

`timescale 1ps/1ps

module immediate_extender (
    input   logic   [31:7]  instr_i,
    input   logic   [ 2:0]  imm_sel_i,
    output  logic   [31:0]  imm_o
);

    localparam logic [2:0] IMM_I = 3'b000;
    localparam logic [2:0] IMM_S = 3'b001;
    localparam logic [2:0] IMM_B = 3'b010;
    localparam logic [2:0] IMM_U = 3'b011;
    localparam logic [2:0] IMM_J = 3'b100;

    always_comb begin : extend_block
        case (imm_sel_i)
            IMM_I: imm_o = {{20{instr_i[31]}}, instr_i[31:20]};

            IMM_S: imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};

            IMM_B: imm_o = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};

            IMM_U: imm_o = {instr_i[31:12], 12'b0};

            IMM_J: imm_o = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};

            default: imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
        endcase
    end

endmodule

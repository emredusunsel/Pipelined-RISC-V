`timescale 1ps/1ps

module riscv_top (
    input   clk,
    input   rstn
);

    logic           RegWriteD_w;
    logic   [ 1:0]  ResultSrcD_w;
    logic           MemWriteD_w;
    logic           JumpD_w;
    logic           BranchD_w;
    logic   [ 2:0]  ALUControlD_w;
    logic           ALUSrcD_w;
    logic   [ 1:0]  ImmSrcD_w;
    logic           StallF_w;
    logic           StallD_w;
    logic           FlushD_w;
    logic           FlushE_w;
    logic   [ 1:0]  ForwardAE_w;
    logic   [ 1:0]  ForwardBE_w;
    logic   [ 6:0]  CUopcode_w;
    logic   [ 2:0]  CUfunct3_w;
    logic           CUfunct7_5_w;
    logic   [ 4:0]  HURs1D_w;
    logic   [ 4:0]  HURs2D_w;
    logic   [ 4:0]  HURdE_w;
    logic   [ 4:0]  HURs1E_w;
    logic   [ 4:0]  HURs2E_w;
    logic           HUPCSrcE_w;
    logic           HUResultSrcE0;
    logic   [ 4:0]  HURdM_w;
    logic           HURegWriteM_w;
    logic   [ 4:0]  HURdW_w;
    logic           HURegWriteW_w;

    datapath datapath (
        .clk(clk),
        .rstn(rstn),
        .RegWriteD(RegWriteD_w),
        .ResultSrcD(ResultSrcD_w),
        .MemWriteD(MemWriteD_w),
        .JumpD(JumpD_w),
        .BranchD(BranchD_w),
        .ALUControlD(ALUControlD_w),
        .ALUSrcD(ALUSrcD_w),
        .ImmSrcD(ImmSrcD_w),

        .StallF(StallF_w),
        .StallD(StallD_w),
        .FlushD(FlushD_w),
        .FlushE(FlushE_w),
        .ForwardAE(ForwardAE_w),
        .ForwardBE(ForwardBE_w),

        .CUopcode(CUopcode_w),
        .CUfunct3(CUfunct3_w),
        .CUfunct7_5(CUfunct7_5_w),

        .HURs1D(HURs1D_w),
        .HURs2D(HURs2D_w),
        .HURdE(HURdE_w),
        .HURs1E(HURs1E_w),
        .HURs2E(HURs2E_w),
        .HUPCSrcE(HUPCSrcE_w),
        .HUResultSrcE0(HUResultSrcE0),
        .HURdM(HURdM_w),
        .HURegWriteM(HURegWriteM_w),
        .HURdW(HURdW_w),
        .HURegWriteW(HURegWriteW_w)
    );

    control_unit control_unit (
        .opcode_i(CUopcode_w),
        .funct3_i(CUfunct3_w),
        .funct7_5_i(CUfunct7_5_w),
        .reg_write_o(RegWriteD_w),
        .result_src_o(ResultSrcD_w),
        .mem_write_o(MemWriteD_w),
        .alu_src_o(ALUSrcD_w),
        .imm_src_o(ImmSrcD_w),
        .alu_control_o(ALUControlD_w),
        .jump_o(JumpD_w),
        .branch_o(BranchD_w)
    );

    hazard_unit hazard_unit (
        .rs1_addr_i(HURs1D_w),
        .rs2_addr_i(HURs2D_w),
        .rd_E_i(HURdE_w),
        .rs1_E_i(HURs1E_w),
        .rs2_E_i(HURs2E_w),
        .pc_src_i(HUPCSrcE_w),
        .result_src_E_i(HUResultSrcE0),
        .rd_M_i(HURdM_w),
        .reg_write_M_i(HURegWriteM_w),
        .rd_W_i(HURdW_w),
        .reg_write_W_i(HURegWriteW_w),

        .stall_F_o(StallF_w),
        .stall_D_o(StallD_w),
        .flush_D_o(FlushD_w),
        .flush_E_o(FlushE_w),
        .forwardA_E_o(ForwardAE_w),
        .forwardB_E_o(ForwardBE_w)
    );

endmodule

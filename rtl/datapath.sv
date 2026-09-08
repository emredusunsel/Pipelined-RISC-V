`timescale 1ps/1ps

module datapath (
    input   logic   clk,
    input   logic   rstn,
    
    // CONTROL SIGNALS
    input   logic           RegWriteD,  //
    input   logic   [1:0]   ResultSrcD, //
    input   logic           MemWriteD,  //
    input   logic           JumpD,  //
    input   logic           BranchD,    //
    input   logic   [2:0]   ALUControlD,    //
    input   logic           ALUSrcD,    //
    input   logic   [1:0]   ImmSrcD,    //

    // HAZARD SIGNALS
    input   logic           StallF, //
    input   logic           StallD, //
    input   logic           FlushD, //
    input   logic           FlushE, //
    input   logic   [ 1:0]  ForwardAE,  //
    input   logic   [ 1:0]  ForwardBE,  //

    output  logic   [6:0]   CUopcode,   //
    output  logic   [2:0]   CUfunct3,   //
    output  logic           CUfunct7_5, //

    output  logic   [4:0]   HURs1D, //
    output  logic   [4:0]   HURs2D, //
    output  logic   [4:0]   HURdE,  //
    output  logic   [4:0]   HURs1E, //
    output  logic   [4:0]   HURs2E, //
    output  logic           HUPCSrcE,   //
    output  logic           HUResultSrcE0,  //
    output  logic   [4:0]   HURdM,  //
    output  logic           HURegWriteM, //
    output  logic   [4:0]   HURdW,  //
    output  logic           HURegWriteW //
);
    
    logic   [31:0]  PCPlus4F_w;
    logic   [31:0]  PCTargetE_w;
    logic   [31:0]  PCFprev_w;
    logic   [31:0]  PCF_w;
    logic   [31:0]  RDF_w;
    //===================//
    logic   [31:0]  PCD_w;
    logic   [31:0]  InstrD_w;
    logic   [31:0]  RD1D_w;
    logic   [31:0]  RD2D_w;
    logic   [31:0]  PCPlus4D_w;
    logic   [31:0]  ImmExtD_w;
    //===================//
    logic   [31:0]  RD1E_w;
    logic   [31:0]  RD2E_w;
    logic   [31:0]  SrcAE_w;
    logic   [31:0]  WriteDataE_w;
    logic   [31:0]  SrcBE_w;
    logic   [31:0]  ImmExtE_w;
    logic           ALUSrcE_w;
    logic   [31:0]  PCE_w;
    logic   [ 2:0]  ALUControlE_w;
    logic   [31:0]  ALUResultE_w;
    logic           ZeroE_w;
    logic   [31:0]  PCPlus4E_w;
    logic   [ 4:0]  RdE_w;
    logic           RegWriteE_w;
    logic   [ 1:0]  ResultSrcE_w;
    logic           MemWriteE_w;
    logic           JumpE_w;
    logic           BranchE_w;
    logic           PCSrcE_w;
    //===================//
    logic   [31:0]  ALUResultM_w;
    logic   [31:0]  WriteDataM_w;
    logic   [31:0]  ReadDataM_w;
    logic   [ 4:0]  RdM_w;
    logic   [31:0]  PCPlus4M_w;
    logic           RegWriteM_w;
    logic   [ 1:0]  ResultSrcM_w;
    logic           MemWriteM_w;
    //===================//
    logic   [31:0]  ReadDataW_w;
    logic   [31:0]  ALUResultW_w;
    logic   [31:0]  PCPlus4W_w;
    logic   [ 1:0]  ResultSrcW_w;
    logic   [31:0]  ResultW_w;
    logic   [ 4:0]  RdW_w;
    logic           RegWriteW_w;


    mux2 # (
        .WIDTH(32)
    ) pcmux (
        .data0_i(PCPlus4F_w),
        .data1_i(PCTargetE_w),
        .sel_i(PCSrcE_w),
        .data_o(PCFprev_w)
    );

    program_counter #(
        .RESET_PC(32'h0000_0000)
    ) program_counter (
        .clk(clk),
        .rstn(rstn),
        .pc_next_i(PCFprev_w),
        .en_ni(StallF),
        .pc_o(PCF_w)
    );

    instruction_memory # (
        .DEPTH(256),
        .MEM_FILE("test/program.hex")
    ) instruction_memory (
        .addr_i(PCF_w),
        .instr_o(RDF_w)
    );

    pc_plus4 pc_plus4 (
        .pc_i(PCF_w),
        .pc_plus4_o(PCPlus4F_w)
    );

//===========================================
// DECODE STAGE
//===========================================

    if_id_reg if_id_reg (
        .clk(clk),
        .rstn(rstn),
        .enable_ni(StallD),
        .clear_i(FlushD),
        .pc_F_i(PCF_w),
        .instr_F_i(RDF_w),
        .pcp4_F_i(PCPlus4F_w),
        .pc_D_o(PCD_w),
        .instr_D_o(InstrD_w),
        .pcp4_D_o(PCPlus4D_w)
    );

    register_file register_file (
        .clk(clk),
        .rstn(rstn),
        .we_i(RegWriteW_w),
        .rs1_addr_i(InstrD_w[19:15]),
        .rs2_addr_i(InstrD_w[24:20]),
        .rd_addr_i(RdW_w),
        .rd_data_i(ResultW_w),
        .rs1_data_o(RD1D_w),
        .rs2_data_o(RD2D_w)
    );

    immediate_extender extend (
        .instr_i(InstrD_w[31:7]),
        .imm_sel_i(ImmSrcD),
        .imm_o(ImmExtD_w)
    );

//===========================================
// EXECUTE STAGE
//===========================================

    id_ex_reg id_ex_reg(
        .clk(clk),
        .rstn(rstn),
        .clear_i(FlushE),
        .rd1_D_i(RD1D_w),
        .rd2_D_i(RD2D_w),
        .pc_D_i(PCD_w),
        .rs1_D_i(InstrD_w[19:15]),
        .rs2_D_i(InstrD_w[24:20]),
        .rd_D_i(InstrD_w[11:7]),
        .imm_ext_D_i(ImmExtD_w),
        .pcp4_D_i(PCPlus4D_w),

        .RegWriteD_i(RegWriteD),
        .ResultSrcD_i(ResultSrcD),
        .MemWriteD_i(MemWriteD),
        .JumpD_i(JumpD),
        .BranchD_i(BranchD),
        .ALUControlD_i(ALUControlD),
        .ALUSrcD_i(ALUSrcD),

        .rd1_E_o(RD1E_w),
        .rd2_E_o(RD2E_w),
        .pc_E_o(PCE_w),
        .rs1_E_o(HURs1E),
        .rs2_E_o(HURs2E),
        .rd_E_o(RdE_w),
        .imm_ext_E_o(ImmExtE_w),
        .pcp4_E_o(PCPlus4E_w),

        .RegWriteE_o(RegWriteE_w),
        .ResultSrcE_o(ResultSrcE_w),
        .MemWriteE_o(MemWriteE_w),
        .JumpE_o(JumpE_w),
        .BranchE_o(BranchE_w),
        .ALUControlE_o(ALUControlE_w),
        .ALUSrcE_o(ALUSrcE_w)
    );

    mux3 # (
        .WIDTH(32)
    ) muxA (
        .data0_i(RD1E_w),
        .data1_i(ResultW_w),
        .data2_i(ALUResultM_w),
        .sel_i(ForwardAE),
        .data_o(SrcAE_w)
    );

    mux3 # (
        .WIDTH(32)
    ) muxB (
        .data0_i(RD2E_w),
        .data1_i(ResultW_w),
        .data2_i(ALUResultM_w),
        .sel_i(ForwardBE),
        .data_o(WriteDataE_w)
    );

    mux2 # (
        .WIDTH(32)
    ) muxBin (
        .data0_i(WriteDataE_w),
        .data1_i(ImmExtE_w),
        .sel_i(ALUSrcE_w),
        .data_o(SrcBE_w)
    );

    pc_target_adder pctarget (
        .pc_i(PCE_w),
        .imm_i(ImmExtE_w),
        .pc_target_o(PCTargetE_w)
    );

    alu alu (
        .a_i(SrcAE_w),
        .b_i(SrcBE_w),
        .alu_ctrl_i(ALUControlE_w),
        .result_o(ALUResultE_w),
        .zero_o(ZeroE_w)
    );

//===========================================
// MEM STAGE
//===========================================

    ex_mem_reg ex_mem_reg (
        .clk(clk),
        .rstn(rstn),

        .alu_E_i(ALUResultE_w),
        .wr_data_E_i(WriteDataE_w),
        .rd_E_i(RdE_w),
        .pcp4_E_i(PCPlus4E_w),

        .RegWriteE_i(RegWriteE_w),
        .ResultSrcE_i(ResultSrcE_w),
        .MemWriteE_i(MemWriteE_w),

        .alu_M_o(ALUResultM_w),
        .wr_data_M_o(WriteDataM_w),
        .rd_M_o(RdM_w),
        .pcp4_M_o(PCPlus4M_w),

        .RegWriteM_o(RegWriteM_w),
        .ResultSrcM_o(ResultSrcM_w),
        .MemWriteM_o(MemWriteM_w)
    );

    data_memory # (
        .DEPTH(256)
    ) data_memory (
        .clk(clk),
        .we_i(MemWriteM_w),
        .addr_i(ALUResultM_w),
        .wr_data_i(WriteDataM_w),
        .rd_data_o(ReadDataM_w)
    );

//===========================================
// WRITEBACK STAGE
//===========================================

    mem_wb_reg mem_wb_reg (
        .clk(clk),
        .rstn(rstn),
        .alu_M_i(ALUResultM_w),
        .rd_data_M_i(ReadDataM_w),
        .rd_M_i(RdM_w),
        .pcp4_M_i(PCPlus4M_w),
        .RegWriteM_i(RegWriteM_w),
        .ResultSrcM_i(ResultSrcM_w),

        .alu_W_o(ALUResultW_w),
        .rd_data_W_o(ReadDataW_w),
        .rd_W_o(RdW_w),
        .pcp4_W_o(PCPlus4W_w),
        .RegWriteW_o(RegWriteW_w),
        .ResultSrcW_o(ResultSrcW_w)
    );

    mux3 # (
        .WIDTH(32)
    ) muxResult (
        .data0_i(ALUResultW_w),
        .data1_i(ReadDataW_w),
        .data2_i(PCPlus4W_w),
        .sel_i(ResultSrcW_w),
        .data_o(ResultW_w)
    );


    assign HURdE = RdE_w;
    assign HUResultSrcE0 = ResultSrcE_w[0];
    assign PCSrcE_w = ((ZeroE_w && BranchE_w) || JumpE_w);
    assign HUPCSrcE = PCSrcE_w;
    assign HURdM = RdM_w;
    assign HURegWriteM = RegWriteM_w;
    assign HURdW = RdW_w;
    assign HURegWriteW = RegWriteW_w;
    assign HURs1D = InstrD_w[19:15];
    assign HURs2D = InstrD_w[24:20];

    assign CUopcode = InstrD_w[6:0];
    assign CUfunct3 = InstrD_w[14:12];
    assign CUfunct7_5 = InstrD_w[30];

endmodule
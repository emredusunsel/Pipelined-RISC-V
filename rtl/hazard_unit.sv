`timescale 1ps/1ps

module hazard_unit (
    input   logic   [4:0]   rs1_addr_i,
    input   logic   [4:0]   rs2_addr_i,
    input   logic   [4:0]   rd_E_i,
    input   logic   [4:0]   rs1_E_i,
    input   logic   [4:0]   rs2_E_i,
    input   logic           pc_src_i,
    input   logic           result_src_E_i,
    input   logic   [4:0]   rd_M_i,
    input   logic           reg_write_M_i,
    input   logic   [4:0]   rd_W_i,
    input   logic           reg_write_W_i,

    output  logic           stall_F_o,
    output  logic           stall_D_o,
    output  logic           flush_D_o,
    output  logic           flush_E_o,
    output  logic   [1:0]   forwardA_E_o,
    output  logic   [1:0]   forwardB_E_o  
);

    logic lwStall;

    always_comb begin : forwardA_block
        if (((rs1_E_i == rd_M_i) && reg_write_M_i) && (rs1_E_i != 0))
            forwardA_E_o = 2'b10;
        else if (((rs1_E_i == rd_W_i) && reg_write_W_i) && (rs1_E_i != 0))
            forwardA_E_o = 2'b01;
        else
            forwardA_E_o = 2'b00;
    end

    always_comb begin : forwardB_block
        if (((rs2_E_i == rd_M_i) && reg_write_M_i) && (rs2_E_i != 0))
            forwardB_E_o = 2'b10;
        else if (((rs2_E_i == rd_W_i) && reg_write_W_i) && (rs2_E_i != 0))
            forwardB_E_o = 2'b01;
        else
            forwardB_E_o = 2'b00;
    end

    assign lwStall = (result_src_E_i && ((rs1_addr_i == rd_E_i) || (rs2_addr_i == rd_E_i)));
    assign stall_F_o = lwStall;
    assign stall_D_o = lwStall;
    assign flush_D_o = pc_src_i;
    assign flush_E_o = lwStall | pc_src_i;

endmodule

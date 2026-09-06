`timescale 1ps/1ps

module register_file_tb;

    logic clk, rstn, we_i;
    logic [4:0] rs1_addr_i, rs2_addr_i, rd_addr_i;
    logic [31:0] rd_data_i, rs1_data_o, rs2_data_o;

    register_file dut (
        .clk(clk),
        .rstn(rstn),
        .we_i(we_i),
        .rs1_addr_i(rs1_addr_i),
        .rs2_addr_i(rs2_addr_i),
        .rd_addr_i(rd_addr_i),
        .rd_data_i(rd_data_i),
        .rs1_data_o(rs1_data_o),
        .rs2_data_o(rs2_data_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn       = 0;
        we_i       = 0;
        rs1_addr_i = '0;
        rs2_addr_i = '0;
        rd_addr_i  = '0;
        rd_data_i  = '0;
    end

    initial begin
        #10;
        rstn = 1;

        // Read all registers after reset
        repeat (32) begin
            @(negedge clk);
            rs1_addr_i = rs1_addr_i + 1;
            rs2_addr_i = rs2_addr_i + 1;
        end

        // Write 1,2,3,... into x1,x2,x3,...
        @(negedge clk);
        rd_addr_i = '0;
        rd_data_i = '0;
        we_i = 1;

        repeat (32) begin
            @(negedge clk);
            rd_addr_i = rd_addr_i + 1;
            rd_data_i = rd_data_i + 1;
        end

        // Read back
        @(negedge clk);
        we_i       = 0;
        rs1_addr_i = '0;
        rs2_addr_i = '0;

        repeat (32) begin
            @(negedge clk);
            rs1_addr_i = rs1_addr_i + 1;
            rs2_addr_i = rs2_addr_i + 1;
        end

        #20;
        $finish;
    end

    initial begin
        $monitor("%0d | %0d | %0d | %h | %h | %h",
                 rs1_addr_i,
                 rs2_addr_i,
                 rd_addr_i,
                 rd_data_i,
                 rs1_data_o,
                 rs2_data_o);
    end

endmodule
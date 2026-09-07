`timescale 1ps/1ps

module program_counter_tb;

    logic clk, rstn;
    logic [31:0] pc_next_i;
    logic en_ni;
    logic [31:0] pc_o;

    program_counter # (
        .RESET_PC(32'h0000_0000)
    ) dut (
        .clk        (clk),
        .rstn       (rstn),
        .pc_next_i  (pc_next_i),
        .en_ni      (en_ni),
        .pc_o       (pc_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn = 0;
        pc_next_i = '0;
        en_ni = 1;
    end

    initial begin
        #10;
        rstn = 1;
        #20;
        en_ni = 0;
    end

    initial begin
        repeat (20) begin
            pc_next_i = pc_next_i + 4;
            @(negedge clk);
        end
        en_ni = 1;
        repeat (10) begin
            pc_next_i = pc_next_i + 4;
            @(negedge clk);
        end
        #10;
        $finish;
    end

    initial begin
        $monitor("%0t %b | %b | %h | %h", $time, rstn, en_ni, pc_next_i, pc_o);
    end

endmodule

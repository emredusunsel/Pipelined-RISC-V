`timescale 1ps/1ps

module pc_plus4_tb;

    logic [31:0] pc_i, pc_plus4_o;

    pc_plus4 dut (
        .pc_i       (pc_i),
        .pc_plus4_o (pc_plus4_o)
    );

    initial begin
        repeat (10) begin
            #1;
            pc_i = $urandom;
        end
    end

    initial begin
        $monitor("%h | %h", pc_i, pc_plus4_o);
    end

endmodule

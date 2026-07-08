`timescale 1ns/1ps

module pc_tb;

logic clk;
logic reset;
logic [31:0] pc_out;

pc uut(
    .clk(clk),
    .reset(reset),
    .pc_out(pc_out)
);

// Clock generation
always #5 clk = ~clk;

initial begin

    $dumpfile("pc.vcd");
    $dumpvars(0, pc_tb);

    clk = 0;
    reset = 1;

    #10;

    reset = 0;

    #80;

    $finish;

end

endmodule
`timescale 1ns/1ps

module if_id_tb;

logic clk;
logic reset;

logic [31:0] pc_in;
logic [31:0] instruction_in;

logic [31:0] pc_out;
logic [31:0] instruction_out;

if_id uut(
    .clk(clk),
    .reset(reset),
    .pc_in(pc_in),
    .instruction_in(instruction_in),
    .pc_out(pc_out),
    .instruction_out(instruction_out)
);

// Clock
always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    $dumpfile("if_id.vcd");
    $dumpvars(0, if_id_tb);

    pc_in = 0;
    instruction_in = 0;

    #10;

    reset = 0;

    pc_in = 32'd4;
    instruction_in = 32'h00500093;
    #10;

    pc_in = 32'd8;
    instruction_in = 32'h00A00113;
    #10;

    pc_in = 32'd12;
    instruction_in = 32'h002081B3;
    #10;

    $finish;

end

endmodule
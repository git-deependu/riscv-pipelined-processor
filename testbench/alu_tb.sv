`timescale 1ns/1ps

module alu_tb;

logic [31:0] a;
logic [31:0] b;
logic [3:0] alu_control;

logic [31:0] result;
logic zero;

alu uut(
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .result(result),
    .zero(zero)
);

initial begin

    $dumpfile("alu.vcd");
    $dumpvars(0, alu_tb);

    // ADD
    a = 20;
    b = 5;
    alu_control = 4'b0000;
    #10;

    // SUB
    alu_control = 4'b0001;
    #10;

    // AND
    alu_control = 4'b0010;
    #10;

    // OR
    alu_control = 4'b0011;
    #10;

    // XOR
    alu_control = 4'b0100;
    #10;

    // SLT
    a = 3;
    b = 10;
    alu_control = 4'b0101;
    #10;

    $finish;

end

endmodule
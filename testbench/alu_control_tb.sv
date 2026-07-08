`timescale 1ns/1ps

module alu_control_tb;

logic [1:0] ALUOp;
logic [2:0] funct3;
logic [6:0] funct7;

logic [3:0] alu_control;

alu_control uut(

    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .alu_control(alu_control)

);

initial begin

    $dumpfile("alu_control.vcd");
    $dumpvars(0, alu_control_tb);

    // ADD
    ALUOp = 2'b10;
    funct7 = 7'b0000000;
    funct3 = 3'b000;
    #10;

    // SUB
    funct7 = 7'b0100000;
    funct3 = 3'b000;
    #10;

    // AND
    funct7 = 7'b0000000;
    funct3 = 3'b111;
    #10;

    // OR
    funct3 = 3'b110;
    #10;

    // XOR
    funct3 = 3'b100;
    #10;

    // SLT
    funct3 = 3'b010;
    #10;

    // LOAD
    ALUOp = 2'b00;
    #10;

    // BRANCH
    ALUOp = 2'b01;
    #10;

    $finish;

end

endmodule
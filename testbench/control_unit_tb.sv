`timescale 1ns/1ps

module control_unit_tb;

logic [6:0] opcode;

logic RegWrite;
logic MemRead;
logic MemWrite;
logic MemtoReg;
logic ALUSrc;
logic Branch;
logic [1:0] ALUOp;

control_unit uut(

    .opcode(opcode),

    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .ALUSrc(ALUSrc),
    .Branch(Branch),
    .ALUOp(ALUOp)

);

initial begin

    $dumpfile("control_unit.vcd");
    $dumpvars(0, control_unit_tb);

    opcode = 7'b0110011;   // R-type
    #10;

    opcode = 7'b0000011;   // Load
    #10;

    opcode = 7'b0100011;   // Store
    #10;

    opcode = 7'b1100011;   // Branch
    #10;

    opcode = 7'b0010011;   // ADDI
    #10;

    $finish;

end

endmodule
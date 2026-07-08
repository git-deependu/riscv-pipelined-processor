`timescale 1ns/1ps

module imm_gen_tb;

logic [31:0] instruction;
logic [31:0] imm_out;

imm_gen uut(
    .instruction(instruction),
    .imm_out(imm_out)
);

initial begin

    $dumpfile("imm_gen.vcd");
    $dumpvars(0, imm_gen_tb);

    // ADDI x1,x0,5
    instruction = 32'h00500093;
    #10;

    // SW x2,8(x1)
    instruction = 32'h0020A423;
    #10;

    // BEQ x1,x2,16
    instruction = 32'h00208863;
    #10;

    $finish;

end

endmodule
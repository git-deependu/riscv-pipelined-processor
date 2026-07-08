`timescale 1ns/1ps

module imem_tb;

logic [31:0] addr;
logic [31:0] instruction;

imem uut (
    .addr(addr),
    .instruction(instruction)
);

initial begin
    $dumpfile("imem.vcd");
    $dumpvars(0, imem_tb);

    addr = 0;
    #10;

    addr = 4;
    #10;

    addr = 8;
    #10;

    addr = 12;
    #10;

    $finish;
end

endmodule
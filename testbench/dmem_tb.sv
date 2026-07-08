`timescale 1ns/1ps

module dmem_tb;

logic clk;
logic MemRead;
logic MemWrite;
logic [31:0] addr;
logic [31:0] write_data;
logic [31:0] read_data;

dmem uut(
    .clk(clk),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
);

// Clock
always #5 clk = ~clk;

initial begin

    clk = 0;

    $dumpfile("dmem.vcd");
    $dumpvars(0,dmem_tb);

    // Read location 0
    MemRead = 1;
    MemWrite = 0;
    addr = 0;
    #10;

    // Read location 1
    addr = 4;
    #10;

    // Write 999 into location 2
    MemRead = 0;
    MemWrite = 1;
    addr = 8;
    write_data = 32'd999;
    #10;

    // Read location 2
    MemWrite = 0;
    MemRead = 1;
    #10;

    $finish;

end

endmodule
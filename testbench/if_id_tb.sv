`timescale 1ns/1ps

module if_id_tb;

logic        clk;
logic        reset;
logic        if_id_write;
logic        flush;

logic [31:0] pc_in;
logic [31:0] instruction_in;

logic [31:0] pc_out;
logic [31:0] instruction_out;

if_id uut(
    .clk(clk),
    .reset(reset),
    .if_id_write(if_id_write),
    .flush(flush),
    .pc_in(pc_in),
    .instruction_in(instruction_in),
    .pc_out(pc_out),
    .instruction_out(instruction_out)
);

always #5 clk = ~clk;

initial begin
    clk         = 0;
    reset       = 1;
    if_id_write = 1;
    flush       = 0;

    $dumpfile("if_id.vcd");
    $dumpvars(0, if_id_tb);

    pc_in          = 0;
    instruction_in = 0;

    #10;
    reset = 0;

    // Vector 1
    pc_in          = 32'd4;
    instruction_in = 32'h00500093; // addi x1, x0, 5
    #10;

    // Vector 2
    pc_in          = 32'd8;
    instruction_in = 32'h00A00113; // addi x2, x0, 10
    #10;

    // Test Stall (if_id_write = 0)
    if_id_write    = 0;
    pc_in          = 32'd12;
    instruction_in = 32'h002081B3; // add x3, x1, x2
    #10;

    // Test Flush
    if_id_write    = 1;
    flush          = 1;
    #10;
    flush          = 0;
    #10;

    $finish;
end

endmodule

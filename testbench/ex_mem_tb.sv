`timescale 1ns/1ps

module ex_mem_tb;

logic        clk;
logic        reset;

logic [31:0] alu_result_in;
logic [31:0] write_data_in;
logic [4:0]  rd_in;
logic        RegWrite_in;
logic        MemRead_in;
logic        MemWrite_in;
logic        MemtoReg_in;

logic [31:0] alu_result_out;
logic [31:0] write_data_out;
logic [4:0]  rd_out;
logic        RegWrite_out;
logic        MemRead_out;
logic        MemWrite_out;
logic        MemtoReg_out;

ex_mem uut(
    .clk(clk),
    .reset(reset),

    .alu_result_in(alu_result_in),
    .write_data_in(write_data_in),
    .rd_in(rd_in),
    .RegWrite_in(RegWrite_in),
    .MemRead_in(MemRead_in),
    .MemWrite_in(MemWrite_in),
    .MemtoReg_in(MemtoReg_in),

    .alu_result_out(alu_result_out),
    .write_data_out(write_data_out),
    .rd_out(rd_out),
    .RegWrite_out(RegWrite_out),
    .MemRead_out(MemRead_out),
    .MemWrite_out(MemWrite_out),
    .MemtoReg_out(MemtoReg_out)
);

always #5 clk = ~clk;

initial begin
    clk           = 0;
    reset         = 1;
    alu_result_in = 0;
    write_data_in = 0;
    rd_in         = 0;
    RegWrite_in   = 0;
    MemRead_in    = 0;
    MemWrite_in   = 0;
    MemtoReg_in   = 0;

    $dumpfile("ex_mem.vcd");
    $dumpvars(0, ex_mem_tb);

    #10;
    reset = 0;

    // Vector 1: ALU result write-back
    alu_result_in = 32'd125;
    write_data_in = 32'd50;
    rd_in         = 5'd3;
    RegWrite_in   = 1'b1;
    MemtoReg_in   = 1'b0;
    #10;

    // Vector 2: Memory Store
    alu_result_in = 32'd250;
    write_data_in = 32'd75;
    rd_in         = 5'd0;
    MemWrite_in   = 1'b1;
    RegWrite_in   = 1'b0;
    #10;

    $finish;
end

endmodule

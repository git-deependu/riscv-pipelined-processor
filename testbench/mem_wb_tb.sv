`timescale 1ns/1ps

module mem_wb_tb;

logic        clk;
logic        reset;

logic [31:0] mem_data_in;
logic [31:0] alu_result_in;
logic [4:0]  rd_in;
logic        RegWrite_in;
logic        MemtoReg_in;

logic [31:0] mem_data_out;
logic [31:0] alu_result_out;
logic [4:0]  rd_out;
logic        RegWrite_out;
logic        MemtoReg_out;

mem_wb uut(
    .clk(clk),
    .reset(reset),

    .mem_data_in(mem_data_in),
    .alu_result_in(alu_result_in),
    .rd_in(rd_in),
    .RegWrite_in(RegWrite_in),
    .MemtoReg_in(MemtoReg_in),

    .mem_data_out(mem_data_out),
    .alu_result_out(alu_result_out),
    .rd_out(rd_out),
    .RegWrite_out(RegWrite_out),
    .MemtoReg_out(MemtoReg_out)
);

always #5 clk = ~clk;

initial begin
    clk           = 0;
    reset         = 1;
    mem_data_in   = 0;
    alu_result_in = 0;
    rd_in         = 0;
    RegWrite_in   = 0;
    MemtoReg_in   = 0;

    $dumpfile("mem_wb.vcd");
    $dumpvars(0, mem_wb_tb);

    #10;
    reset = 0;

    // Vector 1: ALU result
    mem_data_in   = 32'd111;
    alu_result_in = 32'd50;
    rd_in         = 5'd1;
    RegWrite_in   = 1'b1;
    MemtoReg_in   = 1'b0;
    #10;

    // Vector 2: Loaded Memory Data
    mem_data_in   = 32'd222;
    alu_result_in = 32'd100;
    rd_in         = 5'd2;
    RegWrite_in   = 1'b1;
    MemtoReg_in   = 1'b1;
    #10;

    $finish;
end

endmodule

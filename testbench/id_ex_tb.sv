`timescale 1ns/1ps

module id_ex_tb;

logic        clk;
logic        reset;
logic        flush;

logic [31:0] pc_in;
logic [31:0] rd1_in;
logic [31:0] rd2_in;
logic [31:0] imm_in;

logic [4:0]  rs1_in;
logic [4:0]  rs2_in;
logic [4:0]  rd_in;

logic [2:0]  funct3_in;
logic [6:0]  funct7_in;

logic        RegWrite_in;
logic        MemRead_in;
logic        MemWrite_in;
logic        MemtoReg_in;
logic        ALUSrc_in;
logic        Branch_in;
logic [1:0]  ALUOp_in;

logic [31:0] pc_out;
logic [31:0] rd1_out;
logic [31:0] rd2_out;
logic [31:0] imm_out;

logic [4:0]  rs1_out;
logic [4:0]  rs2_out;
logic [4:0]  rd_out;

logic [2:0]  funct3_out;
logic [6:0]  funct7_out;

logic        RegWrite_out;
logic        MemRead_out;
logic        MemWrite_out;
logic        MemtoReg_out;
logic        ALUSrc_out;
logic        Branch_out;
logic [1:0]  ALUOp_out;

id_ex uut(
    .clk(clk),
    .reset(reset),
    .flush(flush),

    .pc_in(pc_in),
    .rd1_in(rd1_in),
    .rd2_in(rd2_in),
    .imm_in(imm_in),
    .rs1_in(rs1_in),
    .rs2_in(rs2_in),
    .rd_in(rd_in),

    .funct3_in(funct3_in),
    .funct7_in(funct7_in),

    .RegWrite_in(RegWrite_in),
    .MemRead_in(MemRead_in),
    .MemWrite_in(MemWrite_in),
    .MemtoReg_in(MemtoReg_in),
    .ALUSrc_in(ALUSrc_in),
    .Branch_in(Branch_in),
    .ALUOp_in(ALUOp_in),

    .pc_out(pc_out),
    .rd1_out(rd1_out),
    .rd2_out(rd2_out),
    .imm_out(imm_out),
    .rs1_out(rs1_out),
    .rs2_out(rs2_out),
    .rd_out(rd_out),

    .funct3_out(funct3_out),
    .funct7_out(funct7_out),

    .RegWrite_out(RegWrite_out),
    .MemRead_out(MemRead_out),
    .MemWrite_out(MemWrite_out),
    .MemtoReg_out(MemtoReg_out),
    .ALUSrc_out(ALUSrc_out),
    .Branch_out(Branch_out),
    .ALUOp_out(ALUOp_out)
);

always #5 clk = ~clk;

initial begin
    clk         = 0;
    reset       = 1;
    flush       = 0;

    pc_in       = 0;
    rd1_in      = 0;
    rd2_in      = 0;
    imm_in      = 0;
    rs1_in      = 0;
    rs2_in      = 0;
    rd_in       = 0;
    funct3_in   = 0;
    funct7_in   = 0;
    RegWrite_in = 0;
    MemRead_in  = 0;
    MemWrite_in = 0;
    MemtoReg_in = 0;
    ALUSrc_in   = 0;
    Branch_in   = 0;
    ALUOp_in    = 0;

    $dumpfile("id_ex.vcd");
    $dumpvars(0, id_ex_tb);

    #10;
    reset = 0;

    // Test Vector 1: R-Type ADD
    pc_in       = 32'd4;
    rd1_in      = 32'd25;
    rd2_in      = 32'd100;
    imm_in      = 32'd0;
    rs1_in      = 5'd1;
    rs2_in      = 5'd2;
    rd_in       = 5'd3;
    funct3_in   = 3'b000;
    funct7_in   = 7'b0000000;
    RegWrite_in = 1'b1;
    ALUOp_in    = 2'b10;
    #10;

    // Test Vector 2: Flush Injection (Bubble)
    flush = 1'b1;
    #10;
    flush = 1'b0;
    #10;

    $finish;
end

endmodule

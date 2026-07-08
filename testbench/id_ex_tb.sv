`timescale 1ns/1ps

module id_ex_tb;

logic clk;
logic reset;

logic [31:0] pc_in;
logic [31:0] rd1_in;
logic [31:0] rd2_in;
logic [31:0] imm_in;

logic [4:0] rs1_in;
logic [4:0] rs2_in;
logic [4:0] rd_in;

logic [31:0] pc_out;
logic [31:0] rd1_out;
logic [31:0] rd2_out;
logic [31:0] imm_out;

logic [4:0] rs1_out;
logic [4:0] rs2_out;
logic [4:0] rd_out;

id_ex uut(
    .clk(clk),
    .reset(reset),

    .pc_in(pc_in),
    .rd1_in(rd1_in),
    .rd2_in(rd2_in),
    .imm_in(imm_in),

    .rs1_in(rs1_in),
    .rs2_in(rs2_in),
    .rd_in(rd_in),

    .pc_out(pc_out),
    .rd1_out(rd1_out),
    .rd2_out(rd2_out),
    .imm_out(imm_out),

    .rs1_out(rs1_out),
    .rs2_out(rs2_out),
    .rd_out(rd_out)
);

// Clock
always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    $dumpfile("id_ex.vcd");
    $dumpvars(0,id_ex_tb);

    pc_in  = 0;
    rd1_in = 0;
    rd2_in = 0;
    imm_in = 0;
    rs1_in = 0;
    rs2_in = 0;
    rd_in  = 0;

    #10;

    reset = 0;

    // Test Vector 1
    pc_in  = 32'd4;
    rd1_in = 32'd25;
    rd2_in = 32'd100;
    imm_in = 32'd8;
    rs1_in = 5'd1;
    rs2_in = 5'd2;
    rd_in  = 5'd3;

    #10;

    // Test Vector 2
    pc_in  = 32'd8;
    rd1_in = 32'd50;
    rd2_in = 32'd200;
    imm_in = 32'd16;
    rs1_in = 5'd4;
    rs2_in = 5'd5;
    rd_in  = 5'd6;

    #10;

    // Test Vector 3
    pc_in  = 32'd12;
    rd1_in = 32'd75;
    rd2_in = 32'd300;
    imm_in = 32'd24;
    rs1_in = 5'd7;
    rs2_in = 5'd8;
    rd_in  = 5'd9;

    #10;

    $finish;

end

endmodule
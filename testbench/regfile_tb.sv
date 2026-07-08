`timescale 1ns/1ps

module regfile_tb;

logic clk;
logic we;

logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;

logic [31:0] wd;

logic [31:0] rd1;
logic [31:0] rd2;

regfile uut(
    .clk(clk),
    .we(we),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(wd),
    .rd1(rd1),
    .rd2(rd2)
);

// Clock
always #5 clk = ~clk;

initial begin

    clk = 0;
    we = 0;

    $dumpfile("regfile.vcd");
    $dumpvars(0, regfile_tb);

    // Write 25 into x1
    we = 1;
    rd = 5'd1;
    wd = 32'd25;
    #10;

    // Write 100 into x2
    rd = 5'd2;
    wd = 32'd100;
    #10;

    we = 0;

    // Read x1 and x2
    rs1 = 5'd1;
    rs2 = 5'd2;
    #10;

    // Read x0 and x2
    rs1 = 5'd0;
    rs2 = 5'd2;
    #10;

    $finish;

end

endmodule
`timescale 1ns/1ps

module ex_mem_tb;

logic clk;
logic reset;

logic [31:0] alu_result_in;
logic [31:0] write_data_in;
logic [4:0] rd_in;

logic [31:0] alu_result_out;
logic [31:0] write_data_out;
logic [4:0] rd_out;

ex_mem uut(
    .clk(clk),
    .reset(reset),

    .alu_result_in(alu_result_in),
    .write_data_in(write_data_in),
    .rd_in(rd_in),

    .alu_result_out(alu_result_out),
    .write_data_out(write_data_out),
    .rd_out(rd_out)
);

// Clock
always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    $dumpfile("ex_mem.vcd");
    $dumpvars(0, ex_mem_tb);

    alu_result_in = 0;
    write_data_in = 0;
    rd_in = 0;

    #10;

    reset = 0;

    // Vector 1
    alu_result_in = 32'd125;
    write_data_in = 32'd50;
    rd_in = 5'd3;

    #10;

    // Vector 2
    alu_result_in = 32'd250;
    write_data_in = 32'd75;
    rd_in = 5'd6;

    #10;

    // Vector 3
    alu_result_in = 32'd500;
    write_data_in = 32'd100;
    rd_in = 5'd9;

    #10;

    $finish;

end

endmodule
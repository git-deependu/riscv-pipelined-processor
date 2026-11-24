`timescale 1ns/1ps

module pc_tb;

logic        clk;
logic        reset;
logic        pc_write;
logic [31:0] pc_in;
logic [31:0] pc_out;

pc uut(
    .clk(clk),
    .reset(reset),
    .pc_write(pc_write),
    .pc_in(pc_in),
    .pc_out(pc_out)
);

// Clock generation (10ns period)
always #5 clk = ~clk;

initial begin
    $dumpfile("pc.vcd");
    $dumpvars(0, pc_tb);

    clk      = 0;
    reset    = 1;
    pc_write = 1;
    pc_in    = 32'd0;

    #10;
    reset = 0;

    // Sequential increments
    pc_in = pc_out + 32'd4;
    #10;
    pc_in = pc_out + 32'd4;
    #10;

    // Stall test (pc_write = 0)
    pc_write = 0;
    pc_in = pc_out + 32'd4;
    #20;

    // Branch jump test (load arbitrary branch target)
    pc_write = 1;
    pc_in = 32'h00000040;
    #10;

    // Resume sequential increment
    pc_in = pc_out + 32'd4;
    #20;

    $finish;
end

endmodule

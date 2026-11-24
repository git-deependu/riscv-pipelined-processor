module pc(
    input  logic        clk,
    input  logic        reset,
    input  logic        pc_write,
    input  logic [31:0] pc_in,
    output logic [31:0] pc_out
);

always_ff @(posedge clk or posedge reset) begin
    if (reset)
        pc_out <= 32'd0;
    else if (pc_write)
        pc_out <= pc_in;
end

endmodule

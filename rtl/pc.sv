module pc(
    input logic clk,
    input logic reset,
    output logic [31:0] pc_out
);

always_ff @(posedge clk or posedge reset)
begin
    if (reset)
        pc_out <= 32'd0;
    else
        pc_out <= pc_out + 32'd4;
end

endmodule
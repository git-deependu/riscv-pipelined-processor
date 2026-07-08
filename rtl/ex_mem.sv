module ex_mem(
    input logic clk,
    input logic reset,

    input logic [31:0] alu_result_in,
    input logic [31:0] write_data_in,
    input logic [4:0]  rd_in,

    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0]  rd_out
);

always_ff @(posedge clk or posedge reset) begin
    if(reset) begin
        alu_result_out <= 0;
        write_data_out <= 0;
        rd_out <= 0;
    end
    else begin
        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;
        rd_out <= rd_in;
    end
end

endmodule
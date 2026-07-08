module id_ex(
    input logic clk,
    input logic reset,

    input logic [31:0] pc_in,
    input logic [31:0] rd1_in,
    input logic [31:0] rd2_in,
    input logic [31:0] imm_in,

    input logic [4:0] rs1_in,
    input logic [4:0] rs2_in,
    input logic [4:0] rd_in,

    output logic [31:0] pc_out,
    output logic [31:0] rd1_out,
    output logic [31:0] rd2_out,
    output logic [31:0] imm_out,

    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,
    output logic [4:0] rd_out
);

always_ff @(posedge clk or posedge reset) begin
    if(reset) begin
        pc_out  <= 0;
        rd1_out <= 0;
        rd2_out <= 0;
        imm_out <= 0;
        rs1_out <= 0;
        rs2_out <= 0;
        rd_out  <= 0;
    end
    else begin
        pc_out  <= pc_in;
        rd1_out <= rd1_in;
        rd2_out <= rd2_in;
        imm_out <= imm_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out  <= rd_in;
    end
end

endmodule
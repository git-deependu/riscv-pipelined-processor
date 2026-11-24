module mem_wb(
    input  logic        clk,
    input  logic        reset,

    // Data Signals
    input  logic [31:0] mem_data_in,
    input  logic [31:0] alu_result_in,
    input  logic [4:0]  rd_in,

    // Control Signals
    input  logic        RegWrite_in,
    input  logic        MemtoReg_in,

    // Data Outputs
    output logic [31:0] mem_data_out,
    output logic [31:0] alu_result_out,
    output logic [4:0]  rd_out,

    // Control Outputs
    output logic        RegWrite_out,
    output logic        MemtoReg_out
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        mem_data_out   <= 32'd0;
        alu_result_out <= 32'd0;
        rd_out         <= 5'd0;

        RegWrite_out   <= 1'b0;
        MemtoReg_out   <= 1'b0;
    end
    else begin
        mem_data_out   <= mem_data_in;
        alu_result_out <= alu_result_in;
        rd_out         <= rd_in;

        RegWrite_out   <= RegWrite_in;
        MemtoReg_out   <= MemtoReg_in;
    end
end

endmodule

module id_ex(
    input  logic        clk,
    input  logic        reset,
    input  logic        flush,

    // Data Signals
    input  logic [31:0] pc_in,
    input  logic [31:0] rd1_in,
    input  logic [31:0] rd2_in,
    input  logic [31:0] imm_in,

    input  logic [4:0]  rs1_in,
    input  logic [4:0]  rs2_in,
    input  logic [4:0]  rd_in,

    // Instruction Fields
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  funct7_in,

    // Control Signals
    input  logic        RegWrite_in,
    input  logic        MemRead_in,
    input  logic        MemWrite_in,
    input  logic        MemtoReg_in,
    input  logic        ALUSrc_in,
    input  logic        Branch_in,
    input  logic [1:0]  ALUOp_in,

    // Data Outputs
    output logic [31:0] pc_out,
    output logic [31:0] rd1_out,
    output logic [31:0] rd2_out,
    output logic [31:0] imm_out,

    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,
    output logic [4:0]  rd_out,

    // Instruction Fields
    output logic [2:0]  funct3_out,
    output logic [6:0]  funct7_out,

    // Control Outputs
    output logic        RegWrite_out,
    output logic        MemRead_out,
    output logic        MemWrite_out,
    output logic        MemtoReg_out,
    output logic        ALUSrc_out,
    output logic        Branch_out,
    output logic [1:0]  ALUOp_out
);

always_ff @(posedge clk or posedge reset) begin
    if (reset || flush) begin
        pc_out       <= 32'd0;
        rd1_out      <= 32'd0;
        rd2_out      <= 32'd0;
        imm_out      <= 32'd0;

        rs1_out      <= 5'd0;
        rs2_out      <= 5'd0;
        rd_out       <= 5'd0;

        funct3_out   <= 3'd0;
        funct7_out   <= 7'd0;

        RegWrite_out <= 1'b0;
        MemRead_out  <= 1'b0;
        MemWrite_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        ALUSrc_out   <= 1'b0;
        Branch_out   <= 1'b0;
        ALUOp_out    <= 2'b00;
    end
    else begin
        pc_out       <= pc_in;
        rd1_out      <= rd1_in;
        rd2_out      <= rd2_in;
        imm_out      <= imm_in;

        rs1_out      <= rs1_in;
        rs2_out      <= rs2_in;
        rd_out       <= rd_in;

        funct3_out   <= funct3_in;
        funct7_out   <= funct7_in;

        RegWrite_out <= RegWrite_in;
        MemRead_out  <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemtoReg_out <= MemtoReg_in;
        ALUSrc_out   <= ALUSrc_in;
        Branch_out   <= Branch_in;
        ALUOp_out    <= ALUOp_in;
    end
end

endmodule

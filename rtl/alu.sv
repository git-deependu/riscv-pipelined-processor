module alu(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_control,

    output logic [31:0] result,
    output logic        zero
);

always_comb begin
    case (alu_control)
        4'b0000: result = a + b;                                    // ADD / ADDI
        4'b0001: result = a - b;                                    // SUB
        4'b0010: result = a & b;                                    // AND / ANDI
        4'b0011: result = a | b;                                    // OR  / ORI
        4'b0100: result = a ^ b;                                    // XOR / XORI
        4'b0101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT / SLTI (signed)
        4'b0110: result = (a < b) ? 32'd1 : 32'd0;                 // SLTU / SLTIU (unsigned)
        4'b0111: result = a << b[4:0];                              // SLL / SLLI
        4'b1000: result = a >> b[4:0];                              // SRL / SRLI
        4'b1001: result = $signed(a) >>> b[4:0];                    // SRA / SRAI
        default: result = 32'd0;
    endcase
end

assign zero = (result == 32'd0);

endmodule

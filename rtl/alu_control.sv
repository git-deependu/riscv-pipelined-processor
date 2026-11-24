module alu_control(
    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,

    output logic [3:0] alu_control
);

always_comb begin
    case (ALUOp)
        // Load / Store
        2'b00:
            alu_control = 4'b0000;   // ADD

        // Branch (BEQ)
        2'b01:
            alu_control = 4'b0001;   // SUB

        // R-Type
        2'b10: begin
            case ({funct7, funct3})
                {7'b0000000, 3'b000}: alu_control = 4'b0000; // ADD
                {7'b0100000, 3'b000}: alu_control = 4'b0001; // SUB
                {7'b0000000, 3'b001}: alu_control = 4'b0111; // SLL
                {7'b0000000, 3'b010}: alu_control = 4'b0101; // SLT
                {7'b0000000, 3'b011}: alu_control = 4'b0110; // SLTU
                {7'b0000000, 3'b100}: alu_control = 4'b0100; // XOR
                {7'b0000000, 3'b101}: alu_control = 4'b1000; // SRL
                {7'b0100000, 3'b101}: alu_control = 4'b1001; // SRA
                {7'b0000000, 3'b110}: alu_control = 4'b0011; // OR
                {7'b0000000, 3'b111}: alu_control = 4'b0010; // AND
                default:              alu_control = 4'b0000;
            endcase
        end

        // I-Type Arithmetic (ADDI, SLTI, etc.)
        2'b11: begin
            case (funct3)
                3'b000: alu_control = 4'b0000;                      // ADDI
                3'b001: alu_control = 4'b0111;                      // SLLI
                3'b010: alu_control = 4'b0101;                      // SLTI
                3'b011: alu_control = 4'b0110;                      // SLTIU
                3'b100: alu_control = 4'b0100;                      // XORI
                3'b101: alu_control = funct7[5] ? 4'b1001 : 4'b1000; // SRAI / SRLI
                3'b110: alu_control = 4'b0011;                      // ORI
                3'b111: alu_control = 4'b0010;                      // ANDI
                default: alu_control = 4'b0000;
            endcase
        end

        default:
            alu_control = 4'b0000;
    endcase
end

endmodule

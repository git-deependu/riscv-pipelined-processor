module alu_control(

    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,

    output logic [3:0] alu_control

);

always_comb begin

    case (ALUOp)

        // Load / Store / ADDI
        2'b00:
            alu_control = 4'b0000;   // ADD

        // Branch
        2'b01:
            alu_control = 4'b0001;   // SUB

        // R-Type
        2'b10: begin

            case ({funct7, funct3})

                {7'b0000000,3'b000}: alu_control = 4'b0000; // ADD
                {7'b0100000,3'b000}: alu_control = 4'b0001; // SUB
                {7'b0000000,3'b111}: alu_control = 4'b0010; // AND
                {7'b0000000,3'b110}: alu_control = 4'b0011; // OR
                {7'b0000000,3'b100}: alu_control = 4'b0100; // XOR
                {7'b0000000,3'b010}: alu_control = 4'b0101; // SLT

                default:
                    alu_control = 4'b0000;

            endcase

        end

        default:
            alu_control = 4'b0000;

    endcase

end

endmodule
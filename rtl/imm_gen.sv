module imm_gen(

    input  logic [31:0] instruction,
    output logic [31:0] imm_out

);

always_comb begin

    case(instruction[6:0])

        // I-Type (Load, ADDI)
        7'b0000011,
        7'b0010011:
            imm_out = {{20{instruction[31]}}, instruction[31:20]};

        // S-Type (Store)
        7'b0100011:
            imm_out = {{20{instruction[31]}},
                       instruction[31:25],
                       instruction[11:7]};

        // B-Type (Branch)
        7'b1100011:
            imm_out = {{19{instruction[31]}},
                       instruction[31],
                       instruction[7],
                       instruction[30:25],
                       instruction[11:8],
                       1'b0};

        default:
            imm_out = 32'd0;

    endcase

end

endmodule
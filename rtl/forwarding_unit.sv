module forwarding_unit(
    input  logic [4:0] id_ex_rs1,
    input  logic [4:0] id_ex_rs2,
    input  logic [4:0] ex_mem_rd,
    input  logic       ex_mem_RegWrite,
    input  logic [4:0] mem_wb_rd,
    input  logic       mem_wb_RegWrite,

    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

always_comb begin
    // Forwarding for Operand A
    // EX hazard takes precedence over MEM hazard
    if (ex_mem_RegWrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
        forward_a = 2'b10; // Forward from EX/MEM stage
    end
    else if (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
        forward_a = 2'b01; // Forward from MEM/WB stage
    end
    else begin
        forward_a = 2'b00; // No forwarding (use ID/EX register)
    end

    // Forwarding for Operand B
    // EX hazard takes precedence over MEM hazard
    if (ex_mem_RegWrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
        forward_b = 2'b10; // Forward from EX/MEM stage
    end
    else if (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
        forward_b = 2'b01; // Forward from MEM/WB stage
    end
    else begin
        forward_b = 2'b00; // No forwarding (use ID/EX register)
    end
end

endmodule

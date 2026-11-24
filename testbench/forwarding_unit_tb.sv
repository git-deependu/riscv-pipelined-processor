`timescale 1ns/1ps

module forwarding_unit_tb;

logic [4:0] id_ex_rs1;
logic [4:0] id_ex_rs2;
logic [4:0] ex_mem_rd;
logic       ex_mem_RegWrite;
logic [4:0] mem_wb_rd;
logic       mem_wb_RegWrite;

logic [1:0] forward_a;
logic [1:0] forward_b;

forwarding_unit uut(
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_rd(ex_mem_rd),
    .ex_mem_RegWrite(ex_mem_RegWrite),
    .mem_wb_rd(mem_wb_rd),
    .mem_wb_RegWrite(mem_wb_RegWrite),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

initial begin
    $dumpfile("forwarding_unit.vcd");
    $dumpvars(0, forwarding_unit_tb);

    // Initial: No hazard
    id_ex_rs1       = 5'd1;
    id_ex_rs2       = 5'd2;
    ex_mem_rd       = 5'd0;
    ex_mem_RegWrite = 1'b0;
    mem_wb_rd       = 5'd0;
    mem_wb_RegWrite = 1'b0;
    #10;

    // EX Hazard on rs1: ex_mem_rd == id_ex_rs1 (forward_a = 2'b10)
    ex_mem_rd       = 5'd1;
    ex_mem_RegWrite = 1'b1;
    #10;

    // MEM Hazard on rs2: mem_wb_rd == id_ex_rs2 (forward_b = 2'b01)
    mem_wb_rd       = 5'd2;
    mem_wb_RegWrite = 1'b1;
    #10;

    // Priority Test: Both EX/MEM and MEM/WB write to rs1 (EX/MEM must win: forward_a = 2'b10)
    mem_wb_rd = 5'd1;
    #10;

    // Zero register destination: x0 must never be forwarded
    ex_mem_rd = 5'd0;
    mem_wb_rd = 5'd0;
    #10;

    $finish;
end

endmodule

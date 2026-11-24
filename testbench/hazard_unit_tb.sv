`timescale 1ns/1ps

module hazard_unit_tb;

logic [4:0] if_id_rs1;
logic [4:0] if_id_rs2;
logic [4:0] id_ex_rd;
logic       id_ex_MemRead;
logic       branch_taken;

logic       pc_write;
logic       if_id_write;
logic       flush_if_id;
logic       flush_id_ex;

hazard_unit uut(
    .if_id_rs1(if_id_rs1),
    .if_id_rs2(if_id_rs2),
    .id_ex_rd(id_ex_rd),
    .id_ex_MemRead(id_ex_MemRead),
    .branch_taken(branch_taken),
    .pc_write(pc_write),
    .if_id_write(if_id_write),
    .flush_if_id(flush_if_id),
    .flush_id_ex(flush_id_ex)
);

initial begin
    $dumpfile("hazard_unit.vcd");
    $dumpvars(0, hazard_unit_tb);

    // Initial: No hazard
    if_id_rs1     = 5'd1;
    if_id_rs2     = 5'd2;
    id_ex_rd      = 5'd3;
    id_ex_MemRead = 1'b0;
    branch_taken  = 1'b0;
    #10;

    // Load-Use Hazard: EX instruction is Load to x1, ID instruction needs x1 (rs1)
    id_ex_rd      = 5'd1;
    id_ex_MemRead = 1'b1;
    #10;

    // Load-Use resolved (non-load instruction in EX)
    id_ex_MemRead = 1'b0;
    #10;

    // Branch Taken: Flush speculative instructions in IF and ID
    branch_taken  = 1'b1;
    #10;

    branch_taken  = 1'b0;
    #10;

    $finish;
end

endmodule

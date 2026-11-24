module hazard_unit(
    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2,
    input  logic [4:0] id_ex_rd,
    input  logic       id_ex_MemRead,
    input  logic       branch_taken,

    output logic       pc_write,
    output logic       if_id_write,
    output logic       flush_if_id,
    output logic       flush_id_ex
);

logic load_use_hazard;

always_comb begin
    // Load-Use Hazard: if instruction in EX is Load and its rd matches rs1 or rs2 in ID
    load_use_hazard = id_ex_MemRead && (id_ex_rd != 5'd0) &&
                      ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));

    if (branch_taken) begin
        // Control hazard: flush speculative instructions
        pc_write     = 1'b1;
        if_id_write  = 1'b1;
        flush_if_id  = 1'b1; // Flush IF/ID register
        flush_id_ex  = 1'b1; // Flush ID/EX register
    end
    else if (load_use_hazard) begin
        // Data hazard: stall PC and IF/ID, insert bubble in ID/EX
        pc_write     = 1'b0; // Freeze PC
        if_id_write  = 1'b0; // Freeze IF/ID
        flush_if_id  = 1'b0;
        flush_id_ex  = 1'b1; // Inject bubble into EX
    end
    else begin
        // Normal execution
        pc_write     = 1'b1;
        if_id_write  = 1'b1;
        flush_if_id  = 1'b0;
        flush_id_ex  = 1'b0;
    end
end

endmodule

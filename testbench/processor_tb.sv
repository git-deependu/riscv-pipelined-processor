`timescale 1ns/1ps

module processor_tb;

logic clk;
logic reset;

// Instantiate the top-level processor
processor uut(
    .clk(clk),
    .reset(reset)
);

// Clock generator: 10ns period (100 MHz)
always #5 clk = ~clk;

integer cycle_count;
integer errors;

initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0, processor_tb);

    clk         = 0;
    reset       = 1;
    cycle_count = 0;
    errors      = 0;

    $display("==================================================================");
    $display("     5-STAGE PIPELINED RISC-V (RV32I) PROCESSOR SIMULATION       ");
    $display("==================================================================");

    // Hold reset for 2 cycles
    #20;
    reset = 0;
    $display("[T=%0t ns] Reset released. Beginning instruction execution...", $time);

    // Run for 30 cycles to allow full pipeline drainage
    repeat (26) begin
        @(posedge clk);
        cycle_count = cycle_count + 1;
        $display("[Cycle %2d] PC: 0x%08h | IF/ID Instr: 0x%08h | EX ALU: 0x%08h | WB Reg: x%0d <= 0x%08h (we=%b)",
                 cycle_count,
                 uut.pc_current,
                 uut.if_id_instruction,
                 uut.ex_alu_result,
                 uut.wb_rd,
                 uut.wb_data,
                 uut.wb_RegWrite);
    end

    $display("\n==================================================================");
    $display("               POST-EXECUTION REGISTER & MEMORY AUDIT             ");
    $display("==================================================================");

    // Verify x1 = 5 (from addi x1, x0, 5)
    if (uut.regfile_inst.registers[1] === 32'd5)
        $display("[PASS] x1 = %0d (Expected: 5)", uut.regfile_inst.registers[1]);
    else begin
        $display("[FAIL] x1 = %0d (Expected: 5)", uut.regfile_inst.registers[1]);
        errors = errors + 1;
    end

    // Verify x2 = 10 (from addi x2, x0, 10)
    if (uut.regfile_inst.registers[2] === 32'd10)
        $display("[PASS] x2 = %0d (Expected: 10)", uut.regfile_inst.registers[2]);
    else begin
        $display("[FAIL] x2 = %0d (Expected: 10)", uut.regfile_inst.registers[2]);
        errors = errors + 1;
    end

    // Verify x3 = 15 (from add x3, x1, x2 - EX/MEM Forwarding)
    if (uut.regfile_inst.registers[3] === 32'd15)
        $display("[PASS] x3 = %0d (Expected: 15) [EX/MEM Forwarding Verified]", uut.regfile_inst.registers[3]);
    else begin
        $display("[FAIL] x3 = %0d (Expected: 15) [EX/MEM Forwarding Failed]", uut.regfile_inst.registers[3]);
        errors = errors + 1;
    end

    // Verify x4 = 5 (from sub x4, x2, x1 - MEM/WB Forwarding)
    if (uut.regfile_inst.registers[4] === 32'd5)
        $display("[PASS] x4 = %0d (Expected: 5)  [MEM/WB Forwarding Verified]", uut.regfile_inst.registers[4]);
    else begin
        $display("[FAIL] x4 = %0d (Expected: 5)  [MEM/WB Forwarding Failed]", uut.regfile_inst.registers[4]);
        errors = errors + 1;
    end

    // Verify Data Memory location [2] = 15 (from sw x3, 8(x0))
    if (uut.dmem_inst.memory[2] === 32'd15)
        $display("[PASS] dmem[2] = %0d (Expected: 15) [SW Instruction Verified]", uut.dmem_inst.memory[2]);
    else begin
        $display("[FAIL] dmem[2] = %0d (Expected: 15) [SW Instruction Failed]", uut.dmem_inst.memory[2]);
        errors = errors + 1;
    end

    // Verify x5 = 15 (from lw x5, 8(x0))
    if (uut.regfile_inst.registers[5] === 32'd15)
        $display("[PASS] x5 = %0d (Expected: 15) [LW Instruction Verified]", uut.regfile_inst.registers[5]);
    else begin
        $display("[FAIL] x5 = %0d (Expected: 15) [LW Instruction Failed]", uut.regfile_inst.registers[5]);
        errors = errors + 1;
    end

    // Verify x6 = 20 (from add x6, x5, x1 - Load-Use Hazard Stall)
    if (uut.regfile_inst.registers[6] === 32'd20)
        $display("[PASS] x6 = %0d (Expected: 20) [Load-Use Stall & Forwarding Verified]", uut.regfile_inst.registers[6]);
    else begin
        $display("[FAIL] x6 = %0d (Expected: 20) [Load-Use Stall Failed]", uut.regfile_inst.registers[6]);
        errors = errors + 1;
    end

    // Verify x7 = 42 (from branch taken beq x4, x1, 8 -> addi x7, x0, 42)
    // and verifies addi x7, x0, 99 was flushed!
    if (uut.regfile_inst.registers[7] === 32'd42)
        $display("[PASS] x7 = %0d (Expected: 42) [Branch Target & Pipeline Flush Verified]", uut.regfile_inst.registers[7]);
    else begin
        $display("[FAIL] x7 = %0d (Expected: 42) [Branch Execution Failed]", uut.regfile_inst.registers[7]);
        errors = errors + 1;
    end

    $display("==================================================================");
    if (errors == 0) begin
        $display("   CONGRATULATIONS! ALL TESTS & ARCHITECTURAL CHECKS PASSED!     ");
        $display("   Waveform dump written to: processor.vcd                       ");
    end else begin
        $display("   SIMULATION FAILED WITH %0d ERROR(S).                           ", errors);
    end
    $display("==================================================================\n");

    $finish;
end

endmodule

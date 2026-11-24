module imem(
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

logic [31:0] memory [0:255];
integer i;

initial begin
    // Clear all instruction memory to NOPs
    for (i = 0; i < 256; i = i + 1) begin
        memory[i] = 32'h00000013; // nop (addi x0, x0, 0)
    end

    // Default verification program:
    // Tests: Arithmetic, Data Forwarding (EX/MEM & MEM/WB), Load/Store, Load-Use Stall, Branch & Flush
    memory[0] = 32'h00500093; // 0x00: addi x1, x0, 5       (x1 = 5)
    memory[1] = 32'h00A00113; // 0x04: addi x2, x0, 10      (x2 = 10)
    memory[2] = 32'h002081B3; // 0x08: add  x3, x1, x2      (x3 = 15, EX/MEM Forwarding)
    memory[3] = 32'h40110233; // 0x0C: sub  x4, x2, x1      (x4 = 5,  MEM/WB Forwarding)
    memory[4] = 32'h00302423; // 0x10: sw   x3, 8(x0)       (dmem[2] = 15)
    memory[5] = 32'h00802283; // 0x14: lw   x5, 8(x0)       (x5 = 15)
    memory[6] = 32'h00128333; // 0x18: add  x6, x5, x1      (x6 = 20, Load-Use Stall Hazard)
    memory[7] = 32'h00120463; // 0x1C: beq  x4, x1, 8       (5 == 5 -> Branch to 0x24)
    memory[8] = 32'h06300393; // 0x20: addi x7, x0, 99      (Skipped / Flushed)
    memory[9] = 32'h02A00393; // 0x24: addi x7, x0, 42      (Branch target: x7 = 42)
    memory[10]= 32'h00000013; // 0x28: nop
    memory[11]= 32'h00000013; // 0x2C: nop
end

// Safely bound address to 256 words
assign instruction = memory[addr[9:2]];

endmodule

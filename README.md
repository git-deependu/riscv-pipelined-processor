# 32-bit Five-Stage Pipelined RISC-V Processor

![SystemVerilog](https://img.shields.io/badge/HDL-SystemVerilog-blue)
![Simulator](https://img.shields.io/badge/simulator-Icarus%20Verilog%2012-green)
![ISA](https://img.shields.io/badge/ISA-RV32I%20(subset)-orange)
![Status](https://img.shields.io/badge/status-completed%20%26%20verified-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

A modular, synthesizable 32-bit RISC-V (RV32I subset) processor with a classic five-stage pipeline
(**IF**, **ID**, **EX**, **MEM**, **WB**), designed in SystemVerilog. Every building block is a separate
module with its own testbench, fully integrated into a verified top-level core with full data forwarding,
load-use hazard detection, branch resolution, and pipeline flushing.

Developed by **Deependu Sharma** (B.Tech, Electronics and Communication Engineering) at the
**University School of Information, Communication and Technology (USICT), Guru Gobind Singh Indraprastha University**,
New Delhi, in collaboration with **Vaidsys Technologies**.

---

## Table of Contents

1. [Project Status](#project-status)
2. [Architecture Overview](#architecture-overview)
3. [Hazard Management](#hazard-management)
4. [RTL Modules](#rtl-modules)
5. [Supported Instructions](#supported-instructions)
6. [Verification & Simulation](#verification--simulation)
7. [Repository Structure](#repository-structure)
8. [Getting Started](#getting-started)
9. [Verification Trace & Results](#verification-trace--results)
10. [Author & License](#author--license)

---

## Project Status

| Area | Status | Description |
|------|:------:|-------------|
| **RTL for All Modules (`rtl/`)** | ✅ **Done** | All 15 modules (`pc`, `imem`, `if_id`, `control_unit`, `regfile`, `imm_gen`, `hazard_unit`, `id_ex`, `forwarding_unit`, `alu_control`, `alu`, `ex_mem`, `dmem`, `mem_wb`, `processor`) are fully implemented and synthesizable. |
| **Top-Level Integration (`processor.sv`)** | ✅ **Done** | Complete 5-stage pipeline integration connecting Fetch, Decode, Execute, Memory, and Write-Back. |
| **Data Forwarding (`forwarding_unit.sv`)** | ✅ **Done** | Resolves RAW data hazards by forwarding directly from `EX/MEM` and `MEM/WB` stages to ALU inputs. |
| **Hazard Detection & Stalling (`hazard_unit.sv`)** | ✅ **Done** | Automatically detects Load-Use hazards, freezes `PC` and `IF/ID`, and injects bubbles into `ID/EX`. |
| **Branch Resolution & Flushing** | ✅ **Done** | Evaluates branches in `EX` stage, jumps to target PC, and flushes speculative instructions from `IF/ID` and `ID/EX`. |
| **Register File with Bypass (`regfile.sv`)** | ✅ **Done** | Dual read ports with combinational write-through forwarding and reset initialization. |
| **Signed SLT & Full ALU Operations** | ✅ **Done** | Signed comparison (`$signed(a) < $signed(b)`) and 10 full arithmetic/logical/shift operations. |
| **Unit Testbenches (`testbench/`)** | ✅ **Done** | All 14 individual unit testbenches pass cleanly under Icarus Verilog (`iverilog`). |
| **Top-Level System Testbench (`processor_tb.sv`)** | ✅ **Done** | Self-checking end-to-end integration test verifying arithmetic, forwarding, load/store, stalls, branches, and pipeline flushes. |

---

## Architecture Overview

```
+----------+      +----------+      +----------+      +----------+      +----------+
| IF Stage | ---> | ID Stage | ---> | EX Stage | ---> | MEM Stage| ---> | WB Stage |
+----------+      +----------+      +----------+      +----------+      +----------+
  PC & IMEM        RegFile,          ALU, Branch       Data Memory       Write-back
                   Decoder & Imm     Adder & Fwd       Read/Write        to RegFile
```

The processor implements the standard classic five-stage RISC-V pipelined datapath:
- **IF (Instruction Fetch):** Updates PC, fetches 32-bit instructions from Instruction Memory, and handles branch jumps.
- **ID (Instruction Decode):** Decodes opcodes, reads register file operands, sign-extends immediates, and evaluates load-use stalls.
- **EX (Execute):** ALU execution, secondary ALU control decoding, operand forwarding selection, branch target calculation, and branch decision.
- **MEM (Memory Access):** Synchronous write and combinational read access to Data Memory.
- **WB (Write Back):** Multiplexes memory load data and ALU execution results, writing back to the destination register.

---

## Hazard Management

### 1. Data Forwarding (RAW Hazards)
The **Forwarding Unit** ([`rtl/forwarding_unit.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/forwarding_unit.sv)) monitors destination registers in the `EX/MEM` and `MEM/WB` stages against source registers `rs1` and `rs2` in the `ID/EX` stage:
- **EX/MEM Forwarding (`forward = 2'b10`):** Forwards the ALU computation directly to the next instruction's ALU inputs.
- **MEM/WB Forwarding (`forward = 2'b01`):** Forwards the write-back data to instructions two cycles behind.
- **Priority Handling:** `EX/MEM` forwarding takes precedence over `MEM/WB` forwarding when both stages target the same register.
- **Register `x0` Protection:** Ensures destination `rd = 0` is never forwarded.

### 2. Load-Use Hazard Stalling
When an instruction in `EX` is a Load (`MemRead = 1`) and the instruction in `ID` depends on its loaded register:
- `pc_write = 0`: Freezes the Program Counter.
- `if_id_write = 0`: Freezes the IF/ID register.
- `flush_id_ex = 1`: Injects a NOP bubble into the `ID/EX` register.
- After 1 stall cycle, the loaded data is forwarded from `MEM/WB` to the ALU.

### 3. Branch Resolution & Pipeline Flushing
Conditional branches (`BEQ`) are evaluated in the `EX` stage:
- If branch condition is met (`Branch & zero`), the branch target address (`pc + imm`) is routed to the PC multiplexer.
- Speculative instructions already fetched into `IF/ID` and `ID/EX` are cleared (`flush_if_id = 1`, `flush_id_ex = 1`).

---

## RTL Modules

| File | Module | Description |
|------|--------|-------------|
| [`rtl/pc.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/pc.sv) | `pc` | Program counter with `pc_write` stall and `pc_in` branch jump support. |
| [`rtl/imem.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/imem.sv) | `imem` | 256-word instruction memory with preloaded verification program. |
| [`rtl/if_id.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/if_id.sv) | `if_id` | IF/ID pipeline register with stall (`if_id_write`) and `flush`. |
| [`rtl/control_unit.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/control_unit.sv) | `control_unit` | Decodes 7-bit opcode into control lines (`RegWrite`, `MemRead`, `MemWrite`, `MemtoReg`, `ALUSrc`, `Branch`, `ALUOp`). |
| [`rtl/regfile.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/regfile.sv) | `regfile` | 32 x 32-bit registers with combinational write-through bypass and reset clear. |
| [`rtl/imm_gen.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/imm_gen.sv) | `imm_gen` | Sign-extends immediates for I-type, S-type, B-type, U-type, and J-type instructions. |
| [`rtl/hazard_unit.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/hazard_unit.sv) | `hazard_unit` | Load-use hazard detection and branch flush controller. |
| [`rtl/id_ex.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/id_ex.sv) | `id_ex` | ID/EX pipeline register carrying operands, instruction fields (`funct3`/`funct7`), and control lines with bubble flush. |
| [`rtl/forwarding_unit.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/forwarding_unit.sv) | `forwarding_unit` | Multi-stage operand forwarding logic for ALU inputs A and B. |
| [`rtl/alu_control.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/alu_control.sv) | `alu_control` | Decodes `ALUOp`, `funct3`, and `funct7` into 4-bit ALU control codes. |
| [`rtl/alu.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/alu.sv) | `alu` | 32-bit ALU with signed `SLT`, unsigned `SLTU`, shifts (`SLL`/`SRL`/`SRA`), logic, arithmetic, and `zero` flag. |
| [`rtl/ex_mem.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/ex_mem.sv) | `ex_mem` | EX/MEM pipeline register carrying ALU result, store write data, destination register `rd`, and memory control signals. |
| [`rtl/dmem.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/dmem.sv) | `dmem` | 256-word data memory with synchronous write and combinational read. |
| [`rtl/mem_wb.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/mem_wb.sv) | `mem_wb` | MEM/WB pipeline register carrying memory data, ALU result, `rd`, and write-back control lines. |
| [`rtl/processor.sv`](file:///c:/Users/Deependu%20Sharma/Desktop/riscv-pipelined-processor/rtl/processor.sv) | `processor` | Integrated top-level 5-stage pipelined processor core. |

---

## Supported Instructions

| Instruction | Type | Opcode | Funct3 | Funct7 | Operation |
|:---:|:---:|:---:|:---:|:---:|:---|
| `ADD` | R | `0110011` | `000` | `0000000` | `rd = rs1 + rs2` |
| `SUB` | R | `0110011` | `000` | `0100000` | `rd = rs1 - rs2` |
| `SLL` | R | `0110011` | `001` | `0000000` | `rd = rs1 << rs2[4:0]` |
| `SLT` | R | `0110011` | `010` | `0000000` | `rd = ($signed(rs1) < $signed(rs2)) ? 1 : 0` |
| `SLTU` | R | `0110011` | `011` | `0000000` | `rd = (rs1 < rs2) ? 1 : 0` |
| `XOR` | R | `0110011` | `100` | `0000000` | `rd = rs1 ^ rs2` |
| `SRL` | R | `0110011` | `101` | `0000000` | `rd = rs1 >> rs2[4:0]` |
| `SRA` | R | `0110011` | `101` | `0100000` | `rd = $signed(rs1) >>> rs2[4:0]` |
| `OR` | R | `0110011` | `110` | `0000000` | `rd = rs1 | rs2` |
| `AND` | R | `0110011` | `111` | `0000000` | `rd = rs1 & rs2` |
| `ADDI` | I | `0010011` | `000` | — | `rd = rs1 + imm` |
| `SLTI` | I | `0010011` | `010` | — | `rd = ($signed(rs1) < $signed(imm)) ? 1 : 0` |
| `SLTIU` | I | `0010011` | `011` | — | `rd = (rs1 < imm) ? 1 : 0` |
| `XORI` | I | `0010011` | `100` | — | `rd = rs1 ^ imm` |
| `ORI` | I | `0010011` | `110` | — | `rd = rs1 | imm` |
| `ANDI` | I | `0010011` | `111` | — | `rd = rs1 & imm` |
| `SLLI` | I | `0010011` | `001` | `0000000` | `rd = rs1 << imm[4:0]` |
| `SRLI` | I | `0010011` | `101` | `0000000` | `rd = rs1 >> imm[4:0]` |
| `SRAI` | I | `0010011` | `101` | `0100000` | `rd = $signed(rs1) >>> imm[4:0]` |
| `LW` | I | `0000011` | `010` | — | `rd = memory[rs1 + imm]` |
| `SW` | S | `0100011` | `010` | — | `memory[rs1 + imm] = rs2` |
| `BEQ` | B | `1100011` | `000` | — | `if (rs1 == rs2) pc += imm` |

---

## Verification & Simulation

### 1. Run Complete Processor Integration Test
```powershell
iverilog -g2012 -o processor.out rtl/*.sv testbench/processor_tb.sv
vvp processor.out
```

### 2. View Waveforms in GTKWave
```powershell
gtkwave processor.vcd
```

### 3. Run All Unit Testbenches
```powershell
$tests = @("alu", "alu_control", "control_unit", "dmem", "ex_mem", "id_ex", "if_id", "imem", "imm_gen", "mem_wb", "pc", "regfile", "forwarding_unit", "hazard_unit")
foreach ($t in $tests) {
    iverilog -g2012 -o "bin_$t.vvp" "rtl/$t.sv" "testbench/${t}_tb.sv"
    vvp "bin_$t.vvp"
    Remove-Item "bin_$t.vvp"
}
```

---

## Verification Trace & Results

The built-in verification suite executes a diagnostic program covering all architectural features:

```text
==================================================================
     5-STAGE PIPELINED RISC-V (RV32I) PROCESSOR SIMULATION       
==================================================================
[T=20000 ns] Reset released. Beginning instruction execution...
[Cycle  1] PC: 0x00000000 | IF/ID Instr: 0x00000013 | EX ALU: 0x00000000 | WB Reg: x0 <= 0x00000000 (we=0)
[Cycle  2] PC: 0x00000004 | IF/ID Instr: 0x00500093 | EX ALU: 0x00000000 | WB Reg: x0 <= 0x00000000 (we=0)
[Cycle  3] PC: 0x00000008 | IF/ID Instr: 0x00a00113 | EX ALU: 0x00000005 | WB Reg: x0 <= 0x00000000 (we=0)
[Cycle  4] PC: 0x0000000c | IF/ID Instr: 0x002081b3 | EX ALU: 0x0000000a | WB Reg: x0 <= 0x00000000 (we=1)
[Cycle  5] PC: 0x00000010 | IF/ID Instr: 0x40110233 | EX ALU: 0x0000000f | WB Reg: x1 <= 0x00000005 (we=1)
[Cycle  6] PC: 0x00000014 | IF/ID Instr: 0x00302423 | EX ALU: 0x00000005 | WB Reg: x2 <= 0x0000000a (we=1)
[Cycle  7] PC: 0x00000018 | IF/ID Instr: 0x00802283 | EX ALU: 0x00000008 | WB Reg: x3 <= 0x0000000f (we=1)
[Cycle  8] PC: 0x0000001c | IF/ID Instr: 0x00128333 | EX ALU: 0x00000008 | WB Reg: x4 <= 0x00000005 (we=1)
[Cycle  9] PC: 0x0000001c | IF/ID Instr: 0x00128333 | EX ALU: 0x00000000 | WB Reg: x8 <= 0x00000008 (we=0)  <-- LOAD-USE STALL
[Cycle 10] PC: 0x00000020 | IF/ID Instr: 0x00120463 | EX ALU: 0x00000014 | WB Reg: x5 <= 0x0000000f (we=1)
[Cycle 11] PC: 0x00000024 | IF/ID Instr: 0x06300393 | EX ALU: 0x00000000 | WB Reg: x0 <= 0x00000000 (we=0)  <-- BRANCH TAKEN
[Cycle 12] PC: 0x00000024 | IF/ID Instr: 0x00000013 | EX ALU: 0x00000000 | WB Reg: x6 <= 0x00000014 (we=1)  <-- FLUSHED BUBBLE
[Cycle 13] PC: 0x00000028 | IF/ID Instr: 0x02a00393 | EX ALU: 0x00000000 | WB Reg: x8 <= 0x00000000 (we=0)
[Cycle 14] PC: 0x0000002c | IF/ID Instr: 0x00000013 | EX ALU: 0x0000002a | WB Reg: x0 <= 0x00000000 (we=0)
[Cycle 15] PC: 0x00000030 | IF/ID Instr: 0x00000013 | EX ALU: 0x00000000 | WB Reg: x0 <= 0x00000000 (we=1)
[Cycle 16] PC: 0x00000034 | IF/ID Instr: 0x00000013 | EX ALU: 0x00000000 | WB Reg: x7 <= 0x0000002a (we=1)  <-- x7 = 42 COMMITTED
...
==================================================================
               POST-EXECUTION REGISTER & MEMORY AUDIT             
==================================================================
[PASS] x1 = 5 (Expected: 5)
[PASS] x2 = 10 (Expected: 10)
[PASS] x3 = 15 (Expected: 15) [EX/MEM Forwarding Verified]
[PASS] x4 = 5 (Expected: 5)  [MEM/WB Forwarding Verified]
[PASS] dmem[2] = 15 (Expected: 15) [SW Instruction Verified]
[PASS] x5 = 15 (Expected: 15) [LW Instruction Verified]
[PASS] x6 = 20 (Expected: 20) [Load-Use Stall & Forwarding Verified]
[PASS] x7 = 42 (Expected: 42) [Branch Target & Pipeline Flush Verified]
==================================================================
   CONGRATULATIONS! ALL TESTS & ARCHITECTURAL CHECKS PASSED!     
   Waveform dump written to: processor.vcd                       
==================================================================
```

---

## Author & License

**Deependu Sharma**  
B.Tech, Electronics and Communication Engineering  
USICT, Guru Gobind Singh Indraprastha University, New Delhi  
VLSI Internship Project at Vaidsys Technologies

Released under the [MIT License](LICENSE).

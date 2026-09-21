# 32-bit Five-Stage Pipelined RISC-V Processor

![SystemVerilog](https://img.shields.io/badge/HDL-SystemVerilog-blue)
![Simulator](https://img.shields.io/badge/simulator-Icarus%20Verilog%2012-green)
![ISA](https://img.shields.io/badge/ISA-RV32I%20(subset)-orange)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

A modular 32-bit RISC-V (RV32I subset) processor with a classic five-stage pipeline
(IF, ID, EX, MEM, WB), written in SystemVerilog. Every building block is a separate
module with its own testbench, simulated with Icarus Verilog and inspected in GTKWave.

Developed as a B.Tech project (Electronics and Communication Engineering, Semester VII)
at the University School of Information, Communication and Technology (USICT),
Guru Gobind Singh Indraprastha University, New Delhi.

## Table of contents

1. [Project status](#project-status)
2. [Architecture](#architecture)
3. [Modules](#modules)
4. [Supported instructions](#supported-instructions)
5. [Control signals and ALU encoding](#control-signals-and-alu-encoding)
6. [Verification and waveforms](#verification-and-waveforms)
7. [Repository structure](#repository-structure)
8. [Getting started](#getting-started)
9. [Known limitations](#known-limitations)
10. [Roadmap](#roadmap)
11. [Documentation](#documentation)
12. [Author](#author)
13. [License](#license)

## Project status

| Area | Status |
|------|--------|
| RTL for all 13 modules (`rtl/`) | Done |
| Module testbenches with waveforms: ALU, ALU control, control unit, data memory, IF/ID, ID/EX, EX/MEM | Done, results below |
| Testbenches / waveforms for PC, instruction memory, register file, immediate generator, MEM/WB | Not yet added to the repo |
| Top-level `processor.sv` | **In progress.** Fetch and decode stages are wired up to the ID/EX register and ALU control. The ALU, EX/MEM, data memory, MEM/WB and write-back are not connected yet (see [Known limitations](#known-limitations)) |
| Hazard detection, forwarding, branch handling | Not implemented |

## Architecture

![Five-stage pipeline architecture](docs/images/architecture.png)

*Target architecture. The modules in the diagram all exist in `rtl/`; connecting the
Execute, Memory and Write-Back stages inside `processor.sv` is the remaining work.*

| Stage | Modules |
|-------|---------|
| **IF**  (Instruction Fetch)  | `pc`, `imem` |
| **ID**  (Instruction Decode) | `control_unit`, `regfile`, `imm_gen` |
| **EX**  (Execute)            | `alu_control`, `alu` |
| **MEM** (Memory Access)      | `dmem` |
| **WB**  (Write Back)         | write-back mux, `regfile` write port |
| Pipeline registers           | `if_id`, `id_ex`, `ex_mem`, `mem_wb` |

Design choices:

- **Modular, bottom-up design.** Each block was written and tested alone before integration.
- **Reset:** the PC and all pipeline registers use an asynchronous, active-high `reset`.
- **Memories:** instruction and data memories are 256 x 32-bit arrays, word-addressed with `addr[31:2]`.
- **Register file:** two combinational read ports and one write port that updates on the rising clock edge. Register `x0` always reads as zero and cannot be written.

## Modules

| File | Module | Description |
|------|--------|-------------|
| `rtl/pc.sv` | `pc` | Program counter. Resets to 0, then adds 4 on every rising clock edge. |
| `rtl/imem.sv` | `imem` | Instruction memory, 256 words, combinational read. Preloaded with a 4-instruction demo program (`addi x1,x0,5`, `addi x2,x0,10`, `add x3,x1,x2`, `nop`). |
| `rtl/if_id.sv` | `if_id` | IF/ID pipeline register (instruction and PC). |
| `rtl/control_unit.sv` | `control_unit` | Decodes the 7-bit opcode into `RegWrite`, `MemRead`, `MemWrite`, `MemtoReg`, `ALUSrc`, `Branch` and `ALUOp[1:0]`. |
| `rtl/regfile.sv` | `regfile` | 32 x 32-bit registers, ports `rs1`/`rs2` (read), `rd`/`wd`/`we` (write). |
| `rtl/imm_gen.sv` | `imm_gen` | Sign-extended immediate for I-type (loads, ADDI), S-type (stores) and B-type (branches). Returns 0 for other opcodes. |
| `rtl/id_ex.sv` | `id_ex` | ID/EX pipeline register: PC, both register operands, immediate, `rs1`/`rs2`/`rd`, `funct3`/`funct7` and all control signals. |
| `rtl/alu_control.sv` | `alu_control` | Converts `ALUOp`, `funct3` and `funct7` into a 4-bit ALU operation code. |
| `rtl/alu.sv` | `alu` | 32-bit ALU with a `zero` flag: ADD, SUB, AND, OR, XOR, SLT. |
| `rtl/ex_mem.sv` | `ex_mem` | EX/MEM pipeline register (ALU result, store data, `rd`). |
| `rtl/dmem.sv` | `dmem` | Data memory, 256 words, combinational read gated by `MemRead`, synchronous write when `MemWrite` is high. Words 0 to 3 are preloaded with 100, 200, 300, 400 for testing. |
| `rtl/mem_wb.sv` | `mem_wb` | MEM/WB pipeline register (memory data, ALU result, `rd`). |
| `rtl/processor.sv` | `processor` | Top level: `clk` and `reset` inputs, instantiates and connects the modules above. |

## Supported instructions

| Instruction | Format | Support in the individual modules |
|-------------|--------|-----------------------------------|
| `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT` | R | Decoded by `control_unit` and `alu_control`, executed by `alu` |
| `ADDI` | I | Decoded and executed as an addition |
| `LW` | I | Control signals, immediate and address addition are in place |
| `SW` | S | Control signals, immediate and address addition are in place |
| `BEQ` | B | Control signals, immediate and the subtraction / zero flag are in place. The PC does not yet jump (see [Known limitations](#known-limitations)) |

Not supported: shifts (`SLL`, `SRL`, `SRA`), the other I-type ALU instructions (`ANDI`,
`ORI`, ...), `LUI`, `AUIPC`, `JAL`, `JALR`, the other branches, and byte / half-word memory
accesses.

## Control signals and ALU encoding

**Control unit outputs** (values taken from `rtl/control_unit.sv`; blank = 0 / don't care):

| Instruction | Opcode | RegWrite | MemRead | MemWrite | MemtoReg | ALUSrc | Branch | ALUOp |
|-------------|--------|:--------:|:-------:|:--------:|:--------:|:------:|:------:|:-----:|
| R-type      | `0110011` | 1 | 0 | 0 | 0 | 0 | 0 | `10` |
| ADDI        | `0010011` | 1 | 0 | 0 | 0 | 1 | 0 | `00` |
| LW          | `0000011` | 1 | 1 | 0 | 1 | 1 | 0 | `00` |
| SW          | `0100011` | 0 | 0 | 1 | 0 | 1 | 0 | `00` |
| BEQ         | `1100011` | 0 | 0 | 0 | 0 | 0 | 1 | `01` |

**ALU control:** `ALUOp` `00` selects ADD, `01` selects SUB, and `10` selects by `{funct7, funct3}`.

| `alu_control` | Operation | R-type encoding (`funct7`, `funct3`) |
|:-------------:|-----------|--------------------------------------|
| `0000` | ADD | `0000000`, `000` |
| `0001` | SUB | `0100000`, `000` |
| `0010` | AND | `0000000`, `111` |
| `0011` | OR  | `0000000`, `110` |
| `0100` | XOR | `0000000`, `100` |
| `0101` | SLT | `0000000`, `010` |

## Verification and waveforms

Each module was simulated with a dedicated testbench (`<module>_tb`) using Icarus Verilog 12.
The waveform dumps are stored in [`docs/waveforms/`](docs/waveforms) and can be opened in
GTKWave. The images below are plots of those same dump files, with a 10 ns clock period
where a clock is present.

### ALU

Operands `a = 20`, `b = 5` for every operation, then `a = 3`, `b = 10` for SLT.

| `alu_control` | Operation | Result |
|:-------------:|-----------|:------:|
| `0000` | ADD | 25 |
| `0001` | SUB | 15 |
| `0010` | AND | 4 |
| `0011` | OR  | 21 |
| `0100` | XOR | 17 |
| `0101` | SLT (3 < 10) | 1 |

![ALU waveform](docs/images/waveform_alu.png)

### ALU control

All six R-type function codes plus `ALUOp = 00` and `01` produce the expected codes from the table above.

![ALU control waveform](docs/images/waveform_alu_control.png)

### Control unit

The five opcodes (R-type, LW, SW, BEQ, ADDI) produce exactly the signals in the control table above.

![Control unit waveform](docs/images/waveform_control_unit.png)

### Data memory

Reads address 0 (100) and address 4 (200), writes 999 to address 8 on a rising clock edge, then reads it back.

![Data memory waveform](docs/images/waveform_dmem.png)

### IF/ID register

After reset is released, the instructions `0x00500093`, `0x00A00113` and `0x002081B3` (with their PC values) appear at the output exactly one clock cycle after the input.

![IF/ID waveform](docs/images/waveform_if_id.png)

### ID/EX register

Operands, immediate, register numbers and PC are captured on the rising clock edge and appear at the output one cycle later. Reset clears every output.

![ID/EX waveform](docs/images/waveform_id_ex.png)

### EX/MEM register

ALU result, store data and destination register are captured on the rising clock edge and appear at the output one cycle later.

![EX/MEM waveform](docs/images/waveform_ex_mem.png)

## Repository structure

```
riscv-5stage-pipeline/
|-- rtl/                 SystemVerilog design files (13 modules)
|-- testbench/           One testbench per module (<module>_tb.sv)
|-- docs/
|   |-- images/          Architecture diagram and waveform plots
|   |-- waveforms/       VCD files, open with GTKWave
|   `-- (project report)
|-- README.md
|-- LICENSE
`-- .gitignore
```

## Getting started

### Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com) 12 (the version used for this project; older versions may work), run with the `-g2012` flag so that SystemVerilog syntax is accepted
- [GTKWave](http://gtkwave.sourceforge.net) for viewing waveforms

Installation: Windows, use the Icarus Verilog installer (it includes GTKWave). Ubuntu / Debian: `sudo apt install iverilog gtkwave`. macOS: `brew install icarus-verilog gtkwave`.

### Run a module testbench

```bash
git clone https://github.com/<your-username>/riscv-5stage-pipeline.git
cd riscv-5stage-pipeline
mkdir sim

# example: ALU
iverilog -g2012 -o sim/alu.out rtl/alu.sv testbench/alu_tb.sv
vvp sim/alu.out          # writes alu.vcd to the current directory
gtkwave alu.vcd
```

The same pattern works for the other modules: replace `alu` with `alu_control`,
`control_unit`, `dmem`, `if_id`, `id_ex` or `ex_mem`. Testbench files are expected as
`testbench/<module>_tb.sv`; adjust the path if you named a file differently.

Run all module testbenches in one go (Linux, macOS, Git Bash):

```bash
mkdir -p sim
for m in alu alu_control control_unit dmem if_id id_ex ex_mem; do
  iverilog -g2012 -o sim/$m.out rtl/$m.sv testbench/${m}_tb.sv && vvp sim/$m.out
done
```

To look at the waveforms from this repository without simulating, open any file from
`docs/waveforms/` directly in GTKWave.

## Known limitations

The processor is not yet a complete, runnable pipeline. The main gaps are:

- **Top level is partial.** `processor.sv` connects PC, instruction memory, IF/ID, control unit, register file, immediate generator, ID/EX and ALU control. The ALU, the ALUSrc multiplexer, EX/MEM, data memory, MEM/WB and the write-back multiplexer are not instantiated yet, and the register-file write enable and data are temporarily tied to 0.
- **Function-field wiring in `processor.sv`.** `alu_control` currently receives `funct3`/`funct7` from bits of the immediate instead of from the ID/EX register's `funct3_out`/`funct7_out`, and the `funct3_in`/`funct7_in` ports of `id_ex` are left unconnected.
- **Write-back register number.** The register file's `rd` input is taken from the instruction in the ID stage; once write-back is connected it must come from MEM/WB.
- **Control signals stop at ID/EX.** `ex_mem` and `mem_wb` carry only data and `rd`, so `RegWrite`, `MemRead`, `MemWrite` and `MemtoReg` still need to be passed through them. The `zero` flag and branch target are not registered either.
- **No hazard handling.** There is no hazard detection or forwarding. Because the register file writes on the rising edge and has no bypass, a dependent instruction has to be at least three instructions behind its producer (three NOPs between adjacent dependent instructions) until forwarding is added.
- **No branch or jump support in the PC.** The PC always advances by 4, so `BEQ` cannot yet change the program flow.
- **`SLT` is unsigned.** `alu.sv` uses `a < b` on unsigned vectors, whereas RV32I `SLT` is a signed comparison.
- **All I-type ALU opcodes act as `ADDI`.** The control unit maps opcode `0010011` to an addition regardless of `funct3`.
- **Uninitialised state.** The register file and the unused memory words start as `X` in simulation.

## Roadmap

- [x] RTL for all individual modules
- [x] Testbenches and waveforms for ALU, ALU control, control unit, data memory, IF/ID, ID/EX and EX/MEM
- [ ] Testbenches and waveforms for PC, instruction memory, register file, immediate generator and MEM/WB
- [ ] Complete the top-level wiring (ALU and mux, EX/MEM, data memory, MEM/WB, write-back)
- [ ] Carry control signals through EX/MEM and MEM/WB; fix the `funct3`/`funct7` and write-back `rd` connections
- [ ] Top-level testbench running a small program and checking register / memory contents
- [ ] Hazard detection unit and forwarding unit
- [ ] Branch and jump support with pipeline flush
- [ ] Shifts, remaining I-type ALU instructions, LUI/AUIPC/JAL/JALR, signed `SLT`
- [ ] Byte and half-word loads and stores
- [ ] Instruction and data caches, FPGA implementation with timing analysis

## Documentation

The project report (Word / PDF) is kept in [`docs/`](docs). It covers the background on
pipelining, the design methodology, module-by-module implementation, simulation results
and future scope.

**References**

1. A. Waterman and K. Asanovic (eds.), *The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA*, RISC-V International.
2. D. A. Patterson and J. L. Hennessy, *Computer Organization and Design RISC-V Edition*, Morgan Kaufmann.
3. IEEE Std 1800-2017, *IEEE Standard for SystemVerilog*.

## Author

**Deependu Sharma**
B.Tech, Electronics and Communication Engineering, USICT, GGSIPU, New Delhi

## License

Released under the [MIT License](LICENSE).

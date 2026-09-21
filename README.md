# 32-bit Five-Stage Pipelined RISC-V Processor

A modular 32-bit, five-stage pipelined RISC-V (RV32I subset) processor written in SystemVerilog and verified with Icarus Verilog and GTKWave.

Developed as a B.Tech project (ECE, Semester VII) at USICT, Guru Gobind Singh Indraprastha University, New Delhi.

## Pipeline

```
IF  ->  IF/ID  ->  ID  ->  ID/EX  ->  EX  ->  EX/MEM  ->  MEM  ->  MEM/WB  ->  WB
```

| Stage | Modules |
|-------|---------|
| IF  | Program Counter, Instruction Memory |
| ID  | Control Unit, Register File, Immediate Generator |
| EX  | ALU Control, ALU |
| MEM | Data Memory |
| WB  | Write-back mux, Register File write port |

Each module has its own testbench and was verified individually before integration into `processor.sv`.

## Repository structure

```
riscv-5stage-pipeline/
|-- rtl/            # SystemVerilog design files
|-- testbench/      # One testbench per module + full processor testbench
|-- docs/           # Project report and waveform screenshots
|-- README.md
|-- LICENSE
`-- .gitignore
```

## Supported instructions

[EDIT to match your RTL]

| Class | Instructions |
|-------|--------------|
| R-type | ADD, SUB, AND, OR, XOR, SLL, SRL, SLT |
| I-type | ADDI (and other immediate ALU forms) |
| Load / Store | LW, SW |
| Branch | BEQ |

## Running the simulation

Requirements: [Icarus Verilog](http://iverilog.icarus.com) and [GTKWave](http://gtkwave.sourceforge.net).

```bash
# compile (SystemVerilog mode is required)
iverilog -g2012 -o sim.vvp rtl/*.sv testbench/tb_processor.sv   # [EDIT testbench name]

# run
vvp sim.vvp

# view waveforms
gtkwave dump.vcd
```

## Waveforms

[Add screenshots to docs/images/ and link them here, for example:]

```markdown
![Full processor waveform](docs/images/processor_waveform.png)
```

## Known limitations

This design has **no hazard detection unit and no data forwarding**. Dependent instructions must be separated by NOPs (`addi x0, x0, 0`):

| Consumer position | NOPs needed |
|-------------------|-------------|
| Adjacent to producer | 2 |
| One instruction between | 1 |
| Two or more between | 0 |

Branches also need NOPs after them because there is no branch prediction or flushing. Byte and half-word memory accesses, JAL/JALR/LUI/AUIPC, caches and exceptions are not implemented.

## Future work

- Hazard detection unit and forwarding unit
- Branch/jump support with pipeline flushing, then branch prediction
- Complete RV32I, then the M extension
- Instruction and data caches
- FPGA implementation with timing analysis

## Documentation

The full project report is in [`docs/`](docs/).

## Author

**Deependu Sharma**
B.Tech ECE, USICT, GGSIPU, New Delhi

## License

Released under the MIT License. See [LICENSE](LICENSE).

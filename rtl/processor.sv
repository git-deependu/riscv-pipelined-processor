module processor(
    input  logic        clk,
    input  logic        reset
);

//=============================================================================
// 1. Fetch Stage Signals
//=============================================================================
logic [31:0] pc_current;
logic [31:0] pc_plus4;
logic [31:0] pc_next;
logic        pc_write;
logic [31:0] imem_instruction;

// IF/ID Pipeline Register Outputs
logic [31:0] if_id_pc;
logic [31:0] if_id_instruction;
logic        if_id_write;
logic        flush_if_id;

//=============================================================================
// 2. Decode Stage Signals
//=============================================================================
logic [6:0]  if_id_opcode;
logic [4:0]  if_id_rd;
logic [2:0]  if_id_funct3;
logic [4:0]  if_id_rs1;
logic [4:0]  if_id_rs2;
logic [6:0]  if_id_funct7;

assign if_id_opcode = if_id_instruction[6:0];
assign if_id_rd     = if_id_instruction[11:7];
assign if_id_funct3 = if_id_instruction[14:12];
assign if_id_rs1    = if_id_instruction[19:15];
assign if_id_rs2    = if_id_instruction[24:20];
assign if_id_funct7 = if_id_instruction[31:25];

// Control Unit Outputs
logic        id_RegWrite;
logic        id_MemRead;
logic        id_MemWrite;
logic        id_MemtoReg;
logic        id_ALUSrc;
logic        id_Branch;
logic [1:0]  id_ALUOp;

// Register File Outputs
logic [31:0] id_rd1;
logic [31:0] id_rd2;

// Immediate Generator Output
logic [31:0] id_imm;

// Hazard Unit Flush Output for ID/EX
logic        flush_id_ex;

// ID/EX Pipeline Register Outputs
logic [31:0] id_ex_pc;
logic [31:0] id_ex_rd1;
logic [31:0] id_ex_rd2;
logic [31:0] id_ex_imm;
logic [4:0]  id_ex_rs1;
logic [4:0]  id_ex_rs2;
logic [4:0]  id_ex_rd;
logic [2:0]  id_ex_funct3;
logic [6:0]  id_ex_funct7;

logic        id_ex_RegWrite;
logic        id_ex_MemRead;
logic        id_ex_MemWrite;
logic        id_ex_MemtoReg;
logic        id_ex_ALUSrc;
logic        id_ex_Branch;
logic [1:0]  id_ex_ALUOp;

//=============================================================================
// 3. Execute Stage Signals
//=============================================================================
logic [1:0]  forward_a;
logic [1:0]  forward_b;

logic [31:0] alu_operand_a;
logic [31:0] forwarded_rd2;
logic [31:0] alu_operand_b;
logic [3:0]  alu_ctrl;
logic [31:0] ex_alu_result;
logic        ex_zero;

// Branch Calculation
logic [31:0] branch_target;
logic        branch_taken;

assign branch_target = id_ex_pc + id_ex_imm;
assign branch_taken  = id_ex_Branch & ex_zero;

// Forwarding Multiplexers
always_comb begin
    case (forward_a)
        2'b10:   alu_operand_a = ex_mem_alu_result; // Forward from EX/MEM
        2'b01:   alu_operand_a = wb_data;           // Forward from MEM/WB
        default: alu_operand_a = id_ex_rd1;         // No forwarding
    endcase
end

always_comb begin
    case (forward_b)
        2'b10:   forwarded_rd2 = ex_mem_alu_result; // Forward from EX/MEM
        2'b01:   forwarded_rd2 = wb_data;           // Forward from MEM/WB
        default: forwarded_rd2 = id_ex_rd2;         // No forwarding
    endcase
end

// ALU Input B Multiplexer (Register/Forwarded value vs. Immediate)
assign alu_operand_b = (id_ex_ALUSrc) ? id_ex_imm : forwarded_rd2;

// EX/MEM Pipeline Register Outputs
logic [31:0] ex_mem_alu_result;
logic [31:0] ex_mem_write_data;
logic [4:0]  ex_mem_rd;
logic        ex_mem_RegWrite;
logic        ex_mem_MemRead;
logic        ex_mem_MemWrite;
logic        ex_mem_MemtoReg;

//=============================================================================
// 4. Memory Stage Signals
//=============================================================================
logic [31:0] mem_read_data;

// MEM/WB Pipeline Register Outputs
logic [31:0] mem_wb_mem_data;
logic [31:0] mem_wb_alu_result;
logic [4:0]  mem_wb_rd;
logic        mem_wb_RegWrite;
logic        mem_wb_MemtoReg;

//=============================================================================
// 5. Write-Back Stage Signals
//=============================================================================
logic [31:0] wb_data;
logic [4:0]  wb_rd;
logic        wb_RegWrite;

assign wb_data     = (mem_wb_MemtoReg) ? mem_wb_mem_data : mem_wb_alu_result;
assign wb_rd       = mem_wb_rd;
assign wb_RegWrite = mem_wb_RegWrite;

//=============================================================================
// Module Instantiations
//=============================================================================

//-----------------------------------------------------------------------------
// [IF Stage] Program Counter
//-----------------------------------------------------------------------------
assign pc_plus4 = pc_current + 32'd4;
assign pc_next  = (branch_taken) ? branch_target : pc_plus4;

pc pc_inst(
    .clk(clk),
    .reset(reset),
    .pc_write(pc_write),
    .pc_in(pc_next),
    .pc_out(pc_current)
);

//-----------------------------------------------------------------------------
// [IF Stage] Instruction Memory
//-----------------------------------------------------------------------------
imem imem_inst(
    .addr(pc_current),
    .instruction(imem_instruction)
);

//-----------------------------------------------------------------------------
// [Pipeline Reg] IF/ID
//-----------------------------------------------------------------------------
if_id if_id_inst(
    .clk(clk),
    .reset(reset),
    .if_id_write(if_id_write),
    .flush(flush_if_id),
    .pc_in(pc_current),
    .instruction_in(imem_instruction),
    .pc_out(if_id_pc),
    .instruction_out(if_id_instruction)
);

//-----------------------------------------------------------------------------
// [ID Stage] Control Unit
//-----------------------------------------------------------------------------
control_unit control_unit_inst(
    .opcode(if_id_opcode),
    .RegWrite(id_RegWrite),
    .MemRead(id_MemRead),
    .MemWrite(id_MemWrite),
    .MemtoReg(id_MemtoReg),
    .ALUSrc(id_ALUSrc),
    .Branch(id_Branch),
    .ALUOp(id_ALUOp)
);

//-----------------------------------------------------------------------------
// [ID Stage] Register File
//-----------------------------------------------------------------------------
regfile regfile_inst(
    .clk(clk),
    .reset(reset),
    .we(wb_RegWrite),
    .rs1(if_id_rs1),
    .rs2(if_id_rs2),
    .rd(wb_rd),
    .wd(wb_data),
    .rd1(id_rd1),
    .rd2(id_rd2)
);

//-----------------------------------------------------------------------------
// [ID Stage] Immediate Generator
//-----------------------------------------------------------------------------
imm_gen imm_gen_inst(
    .instruction(if_id_instruction),
    .imm_out(id_imm)
);

//-----------------------------------------------------------------------------
// [ID Stage] Hazard Detection Unit
//-----------------------------------------------------------------------------
hazard_unit hazard_unit_inst(
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

//-----------------------------------------------------------------------------
// [Pipeline Reg] ID/EX
//-----------------------------------------------------------------------------
id_ex id_ex_inst(
    .clk(clk),
    .reset(reset),
    .flush(flush_id_ex),

    // Data Inputs
    .pc_in(if_id_pc),
    .rd1_in(id_rd1),
    .rd2_in(id_rd2),
    .imm_in(id_imm),
    .rs1_in(if_id_rs1),
    .rs2_in(if_id_rs2),
    .rd_in(if_id_rd),

    // Instruction Fields
    .funct3_in(if_id_funct3),
    .funct7_in(if_id_funct7),

    // Control Inputs
    .RegWrite_in(id_RegWrite),
    .MemRead_in(id_MemRead),
    .MemWrite_in(id_MemWrite),
    .MemtoReg_in(id_MemtoReg),
    .ALUSrc_in(id_ALUSrc),
    .Branch_in(id_Branch),
    .ALUOp_in(id_ALUOp),

    // Data Outputs
    .pc_out(id_ex_pc),
    .rd1_out(id_ex_rd1),
    .rd2_out(id_ex_rd2),
    .imm_out(id_ex_imm),
    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .rd_out(id_ex_rd),

    // Instruction Fields
    .funct3_out(id_ex_funct3),
    .funct7_out(id_ex_funct7),

    // Control Outputs
    .RegWrite_out(id_ex_RegWrite),
    .MemRead_out(id_ex_MemRead),
    .MemWrite_out(id_ex_MemWrite),
    .MemtoReg_out(id_ex_MemtoReg),
    .ALUSrc_out(id_ex_ALUSrc),
    .Branch_out(id_ex_Branch),
    .ALUOp_out(id_ex_ALUOp)
);

//-----------------------------------------------------------------------------
// [EX Stage] Forwarding Unit
//-----------------------------------------------------------------------------
forwarding_unit fwd_unit_inst(
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_rd(ex_mem_rd),
    .ex_mem_RegWrite(ex_mem_RegWrite),
    .mem_wb_rd(mem_wb_rd),
    .mem_wb_RegWrite(mem_wb_RegWrite),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

//-----------------------------------------------------------------------------
// [EX Stage] ALU Control Unit
//-----------------------------------------------------------------------------
alu_control alu_control_inst(
    .ALUOp(id_ex_ALUOp),
    .funct3(id_ex_funct3),
    .funct7(id_ex_funct7),
    .alu_control(alu_ctrl)
);

//-----------------------------------------------------------------------------
// [EX Stage] Arithmetic Logic Unit (ALU)
//-----------------------------------------------------------------------------
alu alu_inst(
    .a(alu_operand_a),
    .b(alu_operand_b),
    .alu_control(alu_ctrl),
    .result(ex_alu_result),
    .zero(ex_zero)
);

//-----------------------------------------------------------------------------
// [Pipeline Reg] EX/MEM
//-----------------------------------------------------------------------------
ex_mem ex_mem_inst(
    .clk(clk),
    .reset(reset),

    // Data Inputs
    .alu_result_in(ex_alu_result),
    .write_data_in(forwarded_rd2),
    .rd_in(id_ex_rd),

    // Control Inputs
    .RegWrite_in(id_ex_RegWrite),
    .MemRead_in(id_ex_MemRead),
    .MemWrite_in(id_ex_MemWrite),
    .MemtoReg_in(id_ex_MemtoReg),

    // Data Outputs
    .alu_result_out(ex_mem_alu_result),
    .write_data_out(ex_mem_write_data),
    .rd_out(ex_mem_rd),

    // Control Outputs
    .RegWrite_out(ex_mem_RegWrite),
    .MemRead_out(ex_mem_MemRead),
    .MemWrite_out(ex_mem_MemWrite),
    .MemtoReg_out(ex_mem_MemtoReg)
);

//-----------------------------------------------------------------------------
// [MEM Stage] Data Memory
//-----------------------------------------------------------------------------
dmem dmem_inst(
    .clk(clk),
    .MemRead(ex_mem_MemRead),
    .MemWrite(ex_mem_MemWrite),
    .addr(ex_mem_alu_result),
    .write_data(ex_mem_write_data),
    .read_data(mem_read_data)
);

//-----------------------------------------------------------------------------
// [Pipeline Reg] MEM/WB
//-----------------------------------------------------------------------------
mem_wb mem_wb_inst(
    .clk(clk),
    .reset(reset),

    // Data Inputs
    .mem_data_in(mem_read_data),
    .alu_result_in(ex_mem_alu_result),
    .rd_in(ex_mem_rd),

    // Control Inputs
    .RegWrite_in(ex_mem_RegWrite),
    .MemtoReg_in(ex_mem_MemtoReg),

    // Data Outputs
    .mem_data_out(mem_wb_mem_data),
    .alu_result_out(mem_wb_alu_result),
    .rd_out(mem_wb_rd),

    // Control Outputs
    .RegWrite_out(mem_wb_RegWrite),
    .MemtoReg_out(mem_wb_MemtoReg)
);

endmodule

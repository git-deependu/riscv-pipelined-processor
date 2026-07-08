module imem(
    input logic [31:0] addr,
    output logic [31:0] instruction
);

logic [31:0] memory [0:255];

initial begin
    memory[0] = 32'h00500093; // addi x1,x0,5
    memory[1] = 32'h00A00113; // addi x2,x0,10
    memory[2] = 32'h002081B3; // add x3,x1,x2
    memory[3] = 32'h00000013; // nop
end

assign instruction = memory[addr[31:2]];

endmodule
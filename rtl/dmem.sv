module dmem(
    input  logic        clk,
    input  logic        MemRead,
    input  logic        MemWrite,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

logic [31:0] memory [0:255];

// Initialize memory
initial begin
    memory[0] = 32'd100;
    memory[1] = 32'd200;
    memory[2] = 32'd300;
    memory[3] = 32'd400;
end

// Read
assign read_data = (MemRead) ? memory[addr[31:2]] : 32'd0;

// Write
always_ff @(posedge clk) begin
    if (MemWrite)
        memory[addr[31:2]] <= write_data;
end

endmodule
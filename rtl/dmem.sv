module dmem(
    input  logic        clk,
    input  logic        MemRead,
    input  logic        MemWrite,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

logic [31:0] memory [0:255];
integer i;

// Initialize data memory
initial begin
    for (i = 0; i < 256; i = i + 1) begin
        memory[i] = 32'd0;
    end
    memory[0] = 32'd100;
    memory[1] = 32'd200;
    memory[2] = 32'd300;
    memory[3] = 32'd400;
end

// Read (asynchronous / combinational)
assign read_data = (MemRead) ? memory[addr[9:2]] : 32'd0;

// Write (synchronous)
always_ff @(posedge clk) begin
    if (MemWrite)
        memory[addr[9:2]] <= write_data;
end

endmodule

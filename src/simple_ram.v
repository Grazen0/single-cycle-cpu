`default_nettype none

module simple_ram #(
    parameter SIZE = 256,
    parameter ADDR_MASK = SIZE - 1
) (
    input wire clk,
    input wire rst_n,

    input wire [31:0] addr,
    input wire [31:0] wdata,
    input wire [ 3:0] wenable,

    output wire [31:0] rdata
);
  reg [7:0] mem[0:SIZE-1];

  integer i;

  always @(posedge clk) begin
    if (wenable[0]) mem[addr&ADDR_MASK] <= wdata[7:0];
    if (wenable[1]) mem[(addr+1)&ADDR_MASK] <= wdata[15:8];
    if (wenable[2]) mem[(addr+2)&ADDR_MASK] <= wdata[23:16];
    if (wenable[3]) mem[(addr+3)&ADDR_MASK] <= wdata[31:24];
  end

  assign rdata[7:0]   = mem[addr&ADDR_MASK];
  assign rdata[15:8]  = mem[(addr+1)&ADDR_MASK];
  assign rdata[23:16] = mem[(addr+2)&ADDR_MASK];
  assign rdata[31:24] = mem[(addr+3)&ADDR_MASK];

  initial begin
    $readmemh("data/firmware_data.hex", mem);
  end
endmodule

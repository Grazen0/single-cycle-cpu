`default_nettype none

module simple_memory #(
    parameter SIZE = 2 ** 12,
    parameter ADDR_MASK = SIZE - 1
) (
    input wire clk,

    input wire [31:0] addr,
    input wire [31:0] wdata,
    input wire [ 3:0] wenable,

    output wire [31:0] rdata
);
  reg [31:0] mem[0:SIZE-1];

  wire [29:0] word_addr = addr[31:2] & ADDR_MASK[31:2];
  wire [1:0] offset = addr[1:0];
  reg [31:0] wvalue;

  always @(*) begin
    wvalue = mem[word_addr];

    if (wenable[0]) wvalue[7:0] = wdata[7:0];
    if (wenable[1]) wvalue[15:8] = wdata[15:8];
    if (wenable[2]) wvalue[23:16] = wdata[23:16];
    if (wenable[3]) wvalue[31:24] = wdata[31:24];
  end

  always @(posedge clk) begin
    if (|wenable) begin
      mem[word_addr] <= wvalue;
    end
  end

  assign rdata = mem[word_addr] >> (8 * offset);

  integer i;

  initial begin
    $readmemh("data/firmware.hex", mem);
  end
endmodule

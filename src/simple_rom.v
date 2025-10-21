`default_nettype none

module simple_rom #(
    parameter SIZE = 1024,
    parameter ADDR_MASK = SIZE - 1
) (
    input  wire [31:0] addr,
    output wire [31:0] data
);
  reg [31:0] mem[0:SIZE-1];

  wire [29:0] phy_addr = addr[31:2] & ADDR_MASK;
  wire [1:0] offset = addr[1:0];
  wire [31:0] phy_data = mem[phy_addr];

  assign data = phy_data >> (8 * offset);

  initial begin
    $readmemh("data/firmware_instr.hex", mem);
  end
endmodule

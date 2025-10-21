`default_nettype none

module simple_rom #(
    parameter SIZE = 1024
) (
    input  wire [31:0] addr,
    output wire [31:0] data
);
  reg [7:0] mem[0:SIZE-1];

  assign data = {mem[(addr+3)%SIZE], mem[(addr+2)%SIZE], mem[(addr+1)%SIZE], mem[addr%SIZE]};

  initial begin
    $readmemh("data/firmware_instr.hex", mem);
  end
endmodule

module simple_rom #(
    parameter N = 32,
    parameter SIZE = 1024
) (
    input  wire [N-1:0] addr,
    output wire [N-1:0] data
);
  reg [7:0] mem[0:SIZE-1];

  assign data = {mem[(addr+3)%SIZE], mem[(addr+2)%SIZE], mem[(addr+1)%SIZE], mem[addr%SIZE]};

  initial begin
    $readmemh("data/firmware.hex", mem);
  end
endmodule

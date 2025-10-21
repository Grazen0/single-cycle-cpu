`default_nettype none

module simple_ram #(
    parameter N = 32,
    parameter SIZE = 1024,
    parameter ADDR_MASK = SIZE - 1
) (
    input wire clk,
    input wire rst_n,

    input wire [N-1:0] addr,
    input wire [N-1:0] write_data,
    input wire [  3:0] write_enable,

    output wire [N-1:0] data,
    output wire [7:0] lcd_data,
    output wire [1:0] lcd_ctrl,
    output wire lcd_enable
);
  reg [7:0] mem[0:SIZE-1];

  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < SIZE; i = i + 1) begin
        mem[i] <= 8'hAA;
      end
    end else begin
      if (write_enable[0]) mem[addr&ADDR_MASK] <= write_data[7:0];
      if (write_enable[1]) mem[(addr+1)&ADDR_MASK] <= write_data[15:8];
      if (write_enable[2]) mem[(addr+2)&ADDR_MASK] <= write_data[23:16];
      if (write_enable[3]) mem[(addr+3)&ADDR_MASK] <= write_data[31:24];
    end
  end

  assign data = {mem[(addr+3)%SIZE], mem[(addr+2)%SIZE], mem[(addr+1)%SIZE], mem[addr%SIZE]};

  assign lcd_data = mem[0];
  assign lcd_ctrl = mem[1];
  assign lcd_enable = mem[2];
endmodule

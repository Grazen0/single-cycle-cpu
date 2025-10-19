`default_nettype none

module simple_ram #(
    parameter N = 32,
    parameter SIZE = 1024
) (
    input wire clk,
    input wire rst_n,

    input wire [N-1:0] addr,
    input wire [N-1:0] write_data,
    input wire write_enable,

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
      if (write_enable) begin
        {mem[(addr+3)%SIZE], mem[(addr+2)%SIZE], mem[(addr+1)%SIZE], mem[addr%SIZE]} <= write_data;
      end
    end
  end

  assign data = {mem[(addr+3)%SIZE], mem[(addr+2)%SIZE], mem[(addr+1)%SIZE], mem[addr%SIZE]};

  assign lcd_data = mem[0];
  assign lcd_ctrl = mem[4];
  assign lcd_enable = mem[8];

  initial begin
    $dumpvars(0, mem[7]);
    $dumpvars(0, mem[8]);
    $dumpvars(0, mem[9]);
    $dumpvars(0, mem[10]);
    $dumpvars(0, mem[11]);
    $dumpvars(0, mem[12]);
  end
endmodule

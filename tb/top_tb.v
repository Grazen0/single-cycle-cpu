`timescale 1ns / 1ps

module top_tb ();
  reg clk, rst_n;
  always #5 clk = ~clk;

  wire clk_out;
  wire [7:0] lcd_data;
  wire [1:0] lcd_ctrl;
  wire lcd_enable;

  top t (
      .clk  (clk),
      .rst_n(rst_n),

      .clk_out(clk_out),
      .lcd_data(lcd_data),
      .lcd_ctrl(lcd_ctrl),
      .lcd_enable(lcd_enable)
  );

  initial begin
    $dumpvars(0, top_tb);

    clk   = 1;
    rst_n = 0;
    #1 rst_n = 1;

    #1500 $finish();
  end
endmodule

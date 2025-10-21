`timescale 1ns / 1ps `default_nettype none

module cpu_tb ();
  reg clk, rst_n;
  always #5 clk = ~clk;

  wire [31:0] instr_data;
  wire [31:0] instr_addr;

  simple_rom rom (
      .addr(instr_addr),
      .data(instr_data)
  );

  wire [31:0] data_addr, data_wdata, data_rdata;
  wire [3:0] data_wenable;

  always @(posedge clk or posedge rst_n) begin
    #1;
    $display("pc = %h, x1 = %h, mem = %h %h %h %h", instr_addr, c.register_file.regs[1],
             ram.mem[0], ram.mem[1], ram.mem[2], ram.mem[3]);
  end

  simple_ram ram (
      .clk(clk),

      .addr(data_addr),
      .wdata(data_wdata),
      .wenable(data_wenable),

      .rdata(data_rdata)
  );

  cpu c (
      .clk  (clk),
      .rst_n(rst_n),

      .instr_addr(instr_addr),
      .instr_data(instr_data),

      .data_addr(data_addr),
      .data_wdata(data_wdata),
      .data_wenable(data_wenable),
      .data_rdata(data_rdata)
  );

  initial begin
    $dumpvars(0, cpu_tb);

    clk   = 1;
    rst_n = 1;

    #1 rst_n = 0;
    #1 rst_n = 1;

    #300 $finish();
  end
endmodule

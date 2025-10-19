`timescale 1ns / 1ps

module cpu_tb ();
  reg clk, rst_n;

  wire [31:0] instr_data;
  wire [31:0] instr_addr;

  simple_rom rom (
      .addr(instr_addr),
      .data(instr_data)
  );

  always #5 clk = ~clk;

  wire [31:0] data_addr, data_wd, data_data;
  wire data_we;

  simple_ram ram (
      .clk  (clk),
      .rst_n(rst_n),

      .addr(data_addr),

      .write_data  (data_wd),
      .write_enable(data_we),

      .data(data_data)
  );

  cpu c (
      .clk  (clk),
      .rst_n(rst_n),

      .instr_addr(instr_addr),
      .instr_data(instr_data),

      .data_addr(data_addr),
      .data_wd(data_wd),
      .data_write_enable(data_we),
      .data_data(data_data)
  );

  integer i;

  generate
    genvar idx;
    for (idx = 0; idx < 32; idx = idx + 1) begin : g_register
      wire [31:0] val = cpu_tb.c.register_file.regs[idx];
    end
  endgenerate

  initial begin
    $dumpvars(0, cpu_tb);

    clk   = 1;
    rst_n = 1;

    #1 rst_n = 0;
    #1 rst_n = 1;

    #100 $finish();
  end
endmodule

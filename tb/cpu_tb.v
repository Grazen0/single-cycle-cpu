`timescale 1ns / 1ps

module cpu_tb ();
  reg clk, rst_n;
  reg  [31:0] instr_data;

  wire [31:0] instr_addr;

  always @(*) begin
    case (instr_addr)
      // lw     x6, -4(x9)
      0: instr_data = 32'hFFC4_A303;
      // sw     x0, 8(x9)
      4: instr_data = 32'h0004_A423;
      // addi   x3, x3, 2
      default: instr_data = {12'h02, 5'd3, 3'b000, 5'd3, 7'b0010011};
    endcase
  end

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

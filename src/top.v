module top (
    input wire clk,
    input wire rst_n,

    output wire clk_out,
    output wire [7:0] lcd_data,
    output wire [1:0] lcd_ctrl,
    output wire lcd_enable
);
  clk_divider #(
      .PERIOD(1_000_000)
  ) divider (
      .clk_in (clk),
      .rst_n  (rst_n),
      .clk_out(clk_out)
  );

  wire [31:0] instr_data;
  wire [31:0] instr_addr;

  simple_rom rom (
      .addr(instr_addr),
      .data(instr_data)
  );

  wire [31:0] data_addr, data_wdata, data_rdata;
  wire [3:0] data_we;

  simple_ram ram (
      .clk  (clk_out),
      .rst_n(rst_n),

      .addr(data_addr),
      .write_data(data_wdata),
      .write_enable(data_we),

      .data(data_rdata),

      .lcd_data  (lcd_data),
      .lcd_ctrl  (lcd_ctrl),
      .lcd_enable(lcd_enable)
  );

  cpu c (
      .clk  (clk_out),
      .rst_n(rst_n),

      .instr_addr(instr_addr),
      .instr_data(instr_data),

      .data_addr(data_addr),
      .data_wdata  (data_wdata),
      .data_we  (data_we),
      .data_rdata(data_rdata)
  );
endmodule

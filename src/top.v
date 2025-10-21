`default_nettype none

module top (
    input wire clk,
    input wire rst_n,

    output wire clk_out,
    output reg [7:0] lcd_data,
    output reg [1:0] lcd_ctrl,
    output reg lcd_enable
);
  clk_divider #(
      .PERIOD(2)
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
  wire [3:0] data_wenable;

  simple_ram ram (
      .clk  (clk_out),
      .rst_n(rst_n),

      .addr(data_addr),
      .wdata(data_wdata),
      .wenable(data_wenable & {4{~data_addr[31]}}),

      .rdata(data_rdata)
  );

  cpu c (
      .clk  (clk_out),
      .rst_n(rst_n),

      .instr_addr(instr_addr),
      .instr_data(instr_data),

      .data_addr(data_addr),
      .data_wdata(data_wdata),
      .data_wenable(data_wenable),
      .data_rdata(data_rdata)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lcd_data   <= 0;
      lcd_ctrl   <= 0;
      lcd_enable <= 0;
    end else if (data_wenable[0] && data_addr[31]) begin
      case (data_addr[1:0])
        2'b00: lcd_data <= data_wdata[7:0];
        2'b01: lcd_ctrl <= data_wdata[1:0];
        2'b10: lcd_enable <= data_wdata[0];
        default: begin
        end
      endcase
    end
  end

endmodule

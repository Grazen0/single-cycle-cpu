`default_nettype none

module cpu_alu (
    input wire [31:0] src_a,
    input wire [31:0] src_b,
    input wire [ 3:0] control,

    output reg signed [31:0] result,
    output reg carry,
    output reg borrow,
    output wire zero,
    output reg overflow,
    output wire neg,
    output reg lt
);
  wire signed [31:0] src_a_signed = src_a;
  wire signed [31:0] src_b_signed = src_b;

  wire [4:0] shamt = src_b[4:0];

  always @(*) begin
    carry    = 0;
    borrow   = 0;
    overflow = 0;
    lt       = 0;

    casez (control)
      4'b0000: {carry, result} = {1'b0, src_a} + {1'b0, src_b};
      4'b1000: begin
        {carry, result} = {1'b1, src_a} - {1'b0, src_b};
        borrow = ~carry;
        overflow = (src_a[31] != src_b[31]) && (result[31] != src_a[31]);
        lt = (result[31] ^ overflow);
      end
      4'b0001: result = src_a << shamt;
      4'b0010: result = {31'b0, src_a_signed < src_b_signed};
      4'b0011: result = {31'b0, src_a < src_b};
      4'b0100: result = src_a ^ src_b;
      4'b0101: result = src_a >> shamt;
      4'b1101: result = src_a_signed >>> shamt;
      4'b0110: result = src_a | src_b;
      4'b0111: result = src_a & src_b;
      4'b1001: result = src_a;
      4'b1010: result = src_b;
      4'b1111: result = {32{1'bx}};
      default: result = {32{1'bx}};
    endcase
  end

  assign zero = (result == 0);
  assign neg  = result[31];
endmodule

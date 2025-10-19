`default_nettype none

`define IMM_SRC_I 3'd0
`define IMM_SRC_S 3'd1
`define IMM_SRC_B 3'd2
`define IMM_SRC_U 3'd3
`define IMM_SRC_J 3'd4

`define ALU_SRC_RD 1'b0
`define ALU_SRC_IMM 1'b1

`define PC_SRC_STEP 1'b0
`define PC_SRC_JUMP 1'b1

`define RESULT_SRC_ALU 1'b0
`define RESULT_SRC_DATA 1'b1

module cpu_control (
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire alu_zero,

    output reg pc_src,
    output reg result_src,
    output reg mem_write,
    output reg [2:0] alu_control,
    output reg alu_src,
    output reg [2:0] imm_src,
    output reg reg_write
);
  always @(*) begin
    pc_src = `PC_SRC_STEP;
    mem_write = 0;
    reg_write = 0;

    case (op)
      7'b0000011: begin  // load
        imm_src = `IMM_SRC_I;
        alu_src = `ALU_SRC_IMM;
        alu_control = 3'b000;  // add
        result_src = `RESULT_SRC_DATA;
        reg_write = 1;
      end
      7'b0010011: begin  // alu (immediate)
        imm_src = `IMM_SRC_I;
        alu_src = `ALU_SRC_IMM;
        alu_control = funct3;  // TODO: implement srai
        result_src = `RESULT_SRC_ALU;
        reg_write = 1;
      end
      7'b0100111: begin
        $display("TODO: implement auipc");
      end
      7'b0100011: begin  // store
        imm_src = `IMM_SRC_S;
        alu_src = `ALU_SRC_IMM;
        alu_control = 3'b000;  // add
        mem_write = 1;
      end
      7'b0100011: begin  // alu (registers)
        alu_src = `ALU_SRC_RD;
        alu_control = funct3;  // TODO: implement sub and sra
        reg_write = 1;
      end
      7'b0110111: begin  // lui
        $display("TODO: implement lui");
      end
      7'b1100011: begin  // branch instructions
        imm_src = `IMM_SRC_B;
        alu_src = `ALU_SRC_RD;
        alu_control = 3'b000;

        if (alu_zero) pc_src = `PC_SRC_JUMP;
      end
      default: begin
        $display("Unknown op: %h", op);
      end
    endcase
  end
endmodule

module cpu_imm_extend #(
    parameter N = 32
) (
    input  wire [ 24:0] data,
    input  wire [  2:0] imm_src,
    output reg  [N-1:0] imm_ext
);
  wire [ 11:0] imm_i = data[24:13];
  wire [ 11:0] imm_s = {data[24:18], data[4:0]};
  wire [ 12:0] imm_b = {data[24], data[0], data[23:18], data[4:1], 1'b0};
  wire [N-1:0] imm_u = {data[24:5], {(N - 20) {1'b0}}};
  wire [ 20:0] imm_j = {data[24], data[12:5], data[13], data[23:14], 1'b0};

  always @(*) begin
    case (imm_src)
      `IMM_SRC_I: imm_ext = {{(N - 12) {imm_i[11]}}, imm_i};
      `IMM_SRC_S: imm_ext = {{(N - 12) {imm_s[11]}}, imm_s};
      `IMM_SRC_B: imm_ext = {{(N - 13) {imm_b[12]}}, imm_b};
      `IMM_SRC_U: imm_ext = imm_u;
      `IMM_SRC_J: imm_ext = {{(N - 21) {imm_j[20]}}, imm_j};
      default: imm_ext = 0;
    endcase
  end
endmodule

module cpu_alu #(
    parameter N = 32
) (
    input wire [N-1:0] src_a,
    input wire [N-1:0] src_b,
    input wire [  2:0] control,

    output reg [N-1:0] result,
    output wire zero
);
  wire signed [N-1:0] src_a_signed = src_a;
  wire signed [N-1:0] src_b_signed = src_b;

  wire [4:0] shamt = src_b[4:0];

  always @(*) begin
    case (control)
      3'b000:  result = src_a + src_b;
      3'b001:  result = src_a << shamt;
      3'b010:  result = src_a_signed < src_b_signed;
      3'b011:  result = src_a < src_b;
      3'b100:  result = src_a ^ src_b;
      3'b101:  result = src_a >> shamt;
      3'b110:  result = src_a | src_b;
      3'b111:  result = src_a & src_b;
      default: result = 0;
    endcase
  end

  assign zero = (result == 0);
endmodule

module cpu_register_file #(
    parameter N = 32
) (
    input wire clk,
    input wire rst_n,
    input wire [4:0] a1,
    input wire [4:0] a2,
    input wire [4:0] a3,
    input wire [N-1:0] wd3,
    input wire we3,

    output wire [N-1:0] rd1,
    output wire [N-1:0] rd2
);
  localparam REGS_SIZE = 32;

  reg [N-1:0] regs[0:REGS_SIZE-1];

  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset registers
      for (i = 0; i < REGS_SIZE; i = i + 1) begin
        regs[i] <= 0;
      end
    end else begin
      if (we3 && a3 != 0) begin
        regs[a3] <= wd3;
      end
    end
  end

  assign rd1 = (a1 == 0) ? 0 : regs[a1];
  assign rd2 = (a2 == 0) ? 0 : regs[a2];
endmodule

module cpu #(
    parameter N = 32
) (
    input wire clk,
    input wire rst_n,

    output wire [N-1:0] instr_addr,
    input  wire [N-1:0] instr_data,

    output wire [N-1:0] data_addr,
    output wire [N-1:0] data_wd,
    output wire data_write_enable,
    input wire [N-1:0] data_data
);
  reg [N-1:0] pc;

  wire pc_src;
  wire result_src;
  wire mem_write;
  wire [2:0] alu_control;
  wire alu_src;
  wire [2:0] imm_src;

  wire reg_write;
  wire alu_zero;

  cpu_control control (
      .op(instr_data[6:0]),
      .funct3(instr_data[14:12]),
      .funct7(instr_data[31:25]),
      .alu_zero(alu_zero),

      .pc_src(pc_src),
      .result_src(result_src),
      .mem_write(data_write_enable),
      .alu_control(alu_control),
      .alu_src(alu_src),
      .imm_src(imm_src),
      .reg_write(reg_write)
  );

  wire [N-1:0] imm_ext;

  cpu_imm_extend imm_extend (
      .data(instr_data[31:7]),
      .imm_src(imm_src),
      .imm_ext(imm_ext)
  );

  wire [N-1:0] pc_target = pc + imm_ext;

  wire [N-1:0] alu_result;

  wire [N-1:0] rd1, rd2;
  wire [N-1:0] result = result_src == `RESULT_SRC_DATA ? data_data : alu_result;

  cpu_register_file register_file (
      .clk(clk),
      .rst_n(rst_n),
      .a1(instr_data[19:15]),
      .a2(instr_data[24:20]),
      .a3(instr_data[11:7]),
      .we3(reg_write),
      .wd3(result),

      .rd1(rd1),
      .rd2(rd2)
  );

  assign data_addr = alu_result;
  assign data_wd   = rd2;

  cpu_alu alu (
      .src_a  (rd1),
      .src_b  (alu_src == `ALU_SRC_IMM ? imm_ext : rd2),
      .control(alu_control),

      .result(alu_result),
      .zero  (alu_zero)
  );

  wire [N-1:0] pc_next = pc_src == `PC_SRC_JUMP ? pc_target : pc + 4;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc <= 0;
    else pc <= pc_next;
  end

  assign instr_addr = pc;
endmodule

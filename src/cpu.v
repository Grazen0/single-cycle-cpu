`default_nettype none

`define IMM_SRC_I 3'd0
`define IMM_SRC_S 3'd1
`define IMM_SRC_B 3'd2
`define IMM_SRC_U 3'd3
`define IMM_SRC_J 3'd4

`define ALU_SRC_RD 1'b0
`define ALU_SRC_IMM 1'b1

`define PC_SRC_STEP 2'b00
`define PC_SRC_JUMP 2'b01
`define PC_SRC_ALU 2'b10
`define PC_SRC_CURRENT 2'b11

`define RESULT_SRC_ALU 3'b000
`define RESULT_SRC_DATA 3'b001
`define RESULT_SRC_IMM 3'b010
`define RESULT_SRC_PC_TARGET 3'b011
`define RESULT_SRC_PC_STEP 3'b100

module cpu_control (
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire alu_zero,
    input wire alu_lt,
    input wire alu_borrow,

    output reg [1:0] pc_src,
    output reg [2:0] result_src,
    output reg [2:0] data_ext_control,
    output reg [3:0] mem_write,
    output reg [3:0] alu_control,
    output reg alu_src,
    output reg [2:0] imm_src,
    output reg reg_write
);
  always @(*) begin
    pc_src = `PC_SRC_STEP;
    result_src = `RESULT_SRC_ALU;
    mem_write = 4'b0000;
    alu_control = 4'b1111;
    alu_src = `ALU_SRC_RD;
    imm_src = `IMM_SRC_I;
    reg_write = 0;

    case (op)
      7'b0000011: begin  // load
        imm_src = `IMM_SRC_I;
        alu_src = `ALU_SRC_IMM;
        alu_control = 4'b0000;  // add
        result_src = `RESULT_SRC_DATA;
        reg_write = 1;
        data_ext_control = funct3;
      end
      7'b0010011: begin  // alu (immediate)
        imm_src = `IMM_SRC_I;
        alu_src = `ALU_SRC_IMM;
        alu_control = {(funct3 == 3'b101) ? funct7[5] : 1'b0, funct3};
        result_src = `RESULT_SRC_ALU;
        reg_write = 1;
      end
      7'b0010111: begin  // auipc
        imm_src = `IMM_SRC_U;
        result_src = `RESULT_SRC_PC_TARGET;
        reg_write = 1;
      end
      7'b0100011: begin  // store
        imm_src = `IMM_SRC_S;
        alu_src = `ALU_SRC_IMM;
        alu_control = 4'b0000;  // add

        case (funct3)
          3'b000:  mem_write = 4'b0001;
          3'b001:  mem_write = 4'b0011;
          3'b010:  mem_write = 4'b1111;
          default: mem_write = 4'b0000;
        endcase
      end
      7'b0110011: begin  // alu (registers)
        alu_src = `ALU_SRC_RD;
        alu_control = {funct7[5], funct3};
        reg_write = 1;
      end
      7'b0110111: begin  // lui
        imm_src = `IMM_SRC_U;
        result_src = `RESULT_SRC_IMM;
        reg_write = 1;
      end
      7'b1100011: begin  // branch instructions
        imm_src = `IMM_SRC_B;
        alu_src = `ALU_SRC_RD;
        alu_control = 4'b1000;  // sub

        case (funct3)
          3'b000:  if (alu_zero) pc_src = `PC_SRC_JUMP;  // beq
          3'b001:  if (!alu_zero) pc_src = `PC_SRC_JUMP;  // bne
          3'b100:  if (alu_lt) pc_src = `PC_SRC_JUMP;  // blt
          3'b101:  if (!alu_lt) pc_src = `PC_SRC_JUMP;  // bge
          3'b110:  if (alu_borrow) pc_src = `PC_SRC_JUMP;  // bltu
          3'b111:  if (!alu_borrow) pc_src = `PC_SRC_JUMP;  // bgeu
          default: pc_src = `PC_SRC_STEP;
        endcase
      end
      7'b1100111: begin  // jalr
        imm_src = `IMM_SRC_I;
        alu_src = `ALU_SRC_IMM;
        alu_control = 4'b0000;  // add
        pc_src = `PC_SRC_ALU;

        result_src = `RESULT_SRC_PC_STEP;
        reg_write = 1;
      end
      7'b1101111: begin  // jal
        imm_src = `IMM_SRC_J;
        pc_src = `PC_SRC_JUMP;

        result_src = `RESULT_SRC_PC_STEP;
        reg_write = 1;
      end
      default: begin
        $display("Unknown op: %h", op);
        pc_src = `PC_SRC_CURRENT;
      end
    endcase
  end
endmodule

module cpu_imm_extend (
    input  wire [24:0] data,
    input  wire [ 2:0] imm_src,
    output reg  [31:0] imm_ext
);
  wire [11:0] imm_i = data[24:13];
  wire [11:0] imm_s = {data[24:18], data[4:0]};
  wire [12:0] imm_b = {data[24], data[0], data[23:18], data[4:1], 1'b0};
  wire [31:0] imm_u = {data[24:5], {12{1'b0}}};
  wire [20:0] imm_j = {data[24], data[12:5], data[13], data[23:14], 1'b0};

  always @(*) begin
    case (imm_src)
      `IMM_SRC_I: imm_ext = {{20{imm_i[11]}}, imm_i};
      `IMM_SRC_S: imm_ext = {{20{imm_s[11]}}, imm_s};
      `IMM_SRC_B: imm_ext = {{19{imm_b[12]}}, imm_b};
      `IMM_SRC_U: imm_ext = imm_u;
      `IMM_SRC_J: imm_ext = {{11{imm_j[20]}}, imm_j};
      default: imm_ext = 0;
    endcase
  end
endmodule

module cpu_data_extend (
    input  wire [31:0] data,
    input  wire [ 2:0] control,
    output reg  [31:0] data_ext
);
  always @(*) begin
    case (control)
      3'b000:  data_ext = {{24{data[7]}}, data[7:0]};
      3'b001:  data_ext = {{16{data[15]}}, data[15:0]};
      3'b010:  data_ext = data;
      3'b100:  data_ext = {{24{1'b0}}, data[7:0]};
      3'b101:  data_ext = {{16{1'b0}}, data[15:0]};
      default: data_ext = 32'b0;
    endcase
  end
endmodule

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
      4'b?001: result = src_a << shamt;
      4'b?010: result = src_a_signed < src_b_signed;
      4'b?011: result = src_a < src_b;
      4'b?100: result = src_a ^ src_b;
      4'b0101: result = src_a >> shamt;
      4'b1101: result = src_a_signed >>> shamt;
      4'b?110: result = src_a | src_b;
      4'b?111: result = src_a & src_b;
      4'b1111: result = 0;
      default: result = 0;
    endcase
  end

  assign zero = (result == 0);
  assign neg  = result[31];
endmodule

module cpu_register_file (
    input wire clk,
    input wire rst_n,
    input wire [4:0] a1,
    input wire [4:0] a2,
    input wire [4:0] a3,
    input wire [31:0] wd3,
    input wire we3,

    output wire [31:0] rd1,
    output wire [31:0] rd2
);
  localparam REGS_SIZE = 32;

  reg [31:0] regs[0:REGS_SIZE-1];

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

module cpu (
    input wire clk,
    input wire rst_n,

    output wire [31:0] instr_addr,
    input  wire [31:0] instr_data,

    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    output wire [ 3:0] data_we,
    input  wire [31:0] data_rdata
);
  reg [31:0] pc;

  wire [1:0] pc_src;
  wire [2:0] result_src;
  wire mem_write;
  wire [3:0] alu_control;
  wire alu_src;
  wire [2:0] imm_src;

  wire reg_write;
  wire alu_zero, alu_borrow, alu_lt;
  wire [2:0] data_ext_control;

  cpu_control control (
      .op(instr_data[6:0]),
      .funct3(instr_data[14:12]),
      .funct7(instr_data[31:25]),
      .alu_zero(alu_zero),
      .alu_borrow(alu_borrow),
      .alu_lt(alu_lt),

      .pc_src(pc_src),
      .result_src(result_src),
      .mem_write(data_we),
      .data_ext_control(data_ext_control),
      .alu_control(alu_control),
      .alu_src(alu_src),
      .imm_src(imm_src),
      .reg_write(reg_write)
  );

  wire [31:0] imm_ext;

  cpu_imm_extend imm_extend (
      .data(instr_data[31:7]),
      .imm_src(imm_src),
      .imm_ext(imm_ext)
  );

  wire [31:0] pc_target = pc + imm_ext;
  wire [31:0] alu_result;
  wire [31:0] rd1, rd2;
  wire [31:0] pc_plus_4 = pc + 4;

  wire [31:0] data_ext;

  cpu_data_extend data_extend (
      .data(data_rdata),
      .control(data_ext_control),
      .data_ext(data_ext)
  );

  reg [31:0] result;

  always @(*) begin
    case (result_src)
      `RESULT_SRC_ALU:       result = alu_result;
      `RESULT_SRC_DATA:      result = data_ext;
      `RESULT_SRC_IMM:       result = imm_ext;
      `RESULT_SRC_PC_TARGET: result = pc_target;
      `RESULT_SRC_PC_STEP:   result = pc_plus_4;
      default:               result = 32'b0;
    endcase
  end

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
  assign data_wdata   = rd2;

  cpu_alu alu (
      .src_a  (rd1),
      .src_b  (alu_src == `ALU_SRC_IMM ? imm_ext : rd2),
      .control(alu_control),

      .result(alu_result),
      .zero(alu_zero),
      .borrow(alu_borrow),
      .lt(alu_lt)
  );

  reg [31:0] pc_next;

  always @(*) begin
    case (pc_src)
      `PC_SRC_STEP:    pc_next = pc_plus_4;
      `PC_SRC_JUMP:    pc_next = pc_target;
      `PC_SRC_ALU:     pc_next = {alu_result[31:1], 1'b0};
      `PC_SRC_CURRENT: pc_next = pc;
      default:         pc_next = pc;
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc <= 0;
    else pc <= pc_next;
  end

  assign instr_addr = pc;
endmodule

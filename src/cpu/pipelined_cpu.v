`default_nettype none

`include "cpu_imm_extend.vh"
`include "cpu_alu.vh"

`define ALU_SRC_RD 1'b0
`define ALU_SRC_IMM 1'b1

`define PC_SRC_STEP 2'd0
`define PC_SRC_JUMP 2'd1
`define PC_SRC_ALU 2'd2
`define PC_SRC_CURRENT 2'd3

`define RESULT_SRC_ALU 2'd0
`define RESULT_SRC_DATA 2'd1
`define RESULT_SRC_PC_TARGET 2'd2
`define RESULT_SRC_PC_STEP 2'd3

`define BRANCH_NONE 3'd0
`define BRANCH_JALR 3'd1
`define BRANCH_JAL 3'd2
`define BRANCH_BREAK 3'd3
`define BRANCH_COND 3'd4

module pl_control (
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire alu_zero,
    input wire alu_lt,
    input wire alu_borrow,

    output reg [2:0] branch_type,
    output reg [1:0] result_src,
    output reg [2:0] data_ext_control,
    output reg [3:0] mem_write,
    output reg [3:0] alu_control,
    output reg alu_src,
    output reg [2:0] imm_src,
    output reg reg_write
);
  always @(*) begin
    branch_type = `BRANCH_NONE;
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
        alu_control = `ALU_ADD;
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
        alu_control = `ALU_ADD;
        result_src = `RESULT_SRC_ALU;

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
        result_src = `RESULT_SRC_ALU;
        reg_write = 1;
      end
      7'b0110111: begin  // lui
        imm_src = `IMM_SRC_U;
        alu_src = `ALU_SRC_IMM;
        alu_control = `ALU_PASS_B;
        result_src = `RESULT_SRC_ALU;
        reg_write = 1;
      end
      7'b1100011: begin  // branch instructions
        imm_src = `IMM_SRC_B;
        alu_src = `ALU_SRC_RD;
        alu_control = `ALU_SUB;
        branch_type = `BRANCH_COND;
      end
      7'b1100111: begin  // jalr
        imm_src = `IMM_SRC_I;
        alu_src = `ALU_SRC_IMM;
        alu_control = `ALU_ADD;
        branch_type = `BRANCH_JALR;

        result_src = `RESULT_SRC_PC_STEP;
        reg_write = 1;
      end
      7'b1101111: begin  // jal
        imm_src = `IMM_SRC_J;
        branch_type = `BRANCH_JAL;

        result_src = `RESULT_SRC_PC_STEP;
        reg_write = 1;
      end
      default: begin
        // $display("Unknown op: %h", op);
        branch_type = `BRANCH_BREAK;
      end
    endcase
  end
endmodule

module pl_branch_logic (
    input wire [2:0] branch_type,
    input wire [2:0] funct3,
    input wire alu_zero,
    input wire alu_lt,
    input wire alu_borrow,

    output reg [1:0] pc_src
);
  always @(*) begin
    case (branch_type)
      `BRANCH_NONE: pc_src = `PC_SRC_STEP;
      `BRANCH_JALR: pc_src = `PC_SRC_ALU;
      `BRANCH_JAL: pc_src = `PC_SRC_JUMP;
      `BRANCH_BREAK: pc_src = `PC_SRC_CURRENT;
      `BRANCH_COND: begin
        pc_src = `PC_SRC_STEP;

        case (funct3)
          3'b000:  if (alu_zero) pc_src = `PC_SRC_JUMP;  // beq
          3'b001:  if (!alu_zero) pc_src = `PC_SRC_JUMP;  // bne
          3'b100:  if (alu_lt) pc_src = `PC_SRC_JUMP;  // blt
          3'b101:  if (!alu_lt) pc_src = `PC_SRC_JUMP;  // bge
          3'b110:  if (alu_borrow) pc_src = `PC_SRC_JUMP;  // bltu
          3'b111:  if (!alu_borrow) pc_src = `PC_SRC_JUMP;  // bgeu
          default: pc_src = {2'bxx};
        endcase
      end
      default: pc_src = {2'bxx};
    endcase
  end
endmodule

`define FORWARD_NONE 2'd0
`define FORWARD_WRITEBACK 2'd1
`define FORWARD_MEMORY 2'd2

module pl_hazard_unit (
    input wire [4:0] rs1_e,
    input wire [4:0] rs2_e,
    input wire [4:0] rd_m,
    input wire [4:0] rd_w,
    input wire reg_write_m,
    input wire reg_write_w,
    output reg [1:0] forward_a_e,
    output reg [1:0] forward_b_e,

    input wire [4:0] rs1_d,
    input wire [4:0] rs2_d,
    input wire [4:0] rd_e,
    input wire [1:0] result_src_e,
    output wire stall_f,
    output wire stall_d,
    output wire flush_e,

    input wire [1:0] pc_src_e,
    output wire flush_d
);
  wire lw_stall = result_src_e == `RESULT_SRC_DATA && (rs1_d == rd_e || rs2_d == rd_e);

  always @(*) begin
    forward_a_e = `FORWARD_NONE;
    forward_b_e = `FORWARD_NONE;

    if (rs1_e == rd_m && reg_write_m && rs1_e != 0) begin
      forward_a_e = `FORWARD_MEMORY;
    end else if (rs1_e == rd_w && reg_write_w && rs1_e != 0) begin
      forward_a_e = `FORWARD_WRITEBACK;
    end

    if (rs2_e == rd_m && reg_write_m && rs2_e != 0) begin
      forward_b_e = `FORWARD_MEMORY;
    end else if (rs2_e == rd_w && reg_write_w && rs2_e != 0) begin
      forward_b_e = `FORWARD_WRITEBACK;
    end
  end

  assign stall_f = lw_stall;
  assign stall_d = lw_stall;
  assign flush_d = pc_src_e != `PC_SRC_STEP;
  assign flush_e = lw_stall || pc_src_e != `PC_SRC_STEP;
endmodule

module pipelined_cpu (
    input wire clk,
    input wire rst_n,

    output wire [31:0] instr_addr,
    input  wire [31:0] instr_data,

    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    output wire [ 3:0] data_wenable,
    input  wire [31:0] data_rdata
);
  wire [1:0] forward_a_e;
  wire [1:0] forward_b_e;
  wire stall_f;
  wire stall_d;
  wire flush_e;
  wire flush_d;

  pl_hazard_unit hazard_unit (
      .rs1_e(rs1_e),
      .rs2_e(rs2_e),
      .rd_m(rd_m),
      .rd_w(rd_w),
      .reg_write_m(reg_write_m),
      .reg_write_w(reg_write_w),
      .forward_a_e(forward_a_e),
      .forward_b_e(forward_b_e),

      .rs1_d(rs1_d),
      .rs2_d(rs2_d),
      .rd_e(rd_e),
      .result_src_e(result_src_e),
      .stall_f(stall_f),
      .stall_d(stall_d),
      .flush_e(flush_e),

      .pc_src_e(pc_src_e),
      .flush_d (flush_d)
  );

  // 1. Fetch
  reg [31:0] pc_f;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_f <= 0;
    end else if (!stall_f) begin
      pc_f <= pc_next;
    end
  end

  reg [31:0] pc_next;

  always @(*) begin
    case (pc_src_e)
      `PC_SRC_STEP:    pc_next = pc_plus_4_f;
      `PC_SRC_JUMP:    pc_next = pc_target_e;
      `PC_SRC_ALU:     pc_next = alu_result_e & ~1;
      `PC_SRC_CURRENT: pc_next = pc_f;
      default:         pc_next = {32{1'bx}};
    endcase
  end

  assign instr_addr = pc_f;
  wire [31:0] pc_plus_4_f = pc_f + 4;

  // 2. Decode
  reg  [31:0] instr_d;
  reg  [31:0] pc_d;
  reg  [31:0] pc_plus_4_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || flush_d) begin
      instr_d <= 32'h00000013;  // nop
      pc_d <= {32{1'bx}};
      pc_plus_4_d <= {32{1'bx}};
    end else if (!stall_d) begin
      instr_d <= instr_data;
      pc_d <= pc_f;
      pc_plus_4_d <= pc_plus_4_f;
    end
  end

  wire [2:0] funct3_d = instr_d[14:12];

  wire [1:0] pc_src_d;
  wire [2:0] branch_type_d;
  wire [1:0] result_src_d;
  wire [3:0] mem_write_d;
  wire [2:0] data_ext_control_d;
  wire [3:0] alu_control_d;
  wire alu_src_d;
  wire [2:0] imm_src_d;
  wire reg_write_d;

  wire [4:0] rs1_d = instr_d[19:15];
  wire [4:0] rs2_d = instr_d[24:20];
  wire [4:0] rd_d = instr_d[11:7];
  wire [31:0] imm_ext_d;
  wire [31:0] rd1_d;
  wire [31:0] rd2_d;

  pl_control control (
      .op(instr_d[6:0]),
      .funct3(funct3_d),
      .funct7(instr_d[31:25]),

      .branch_type(branch_type_d),
      .result_src(result_src_d),
      .mem_write(mem_write_d),
      .data_ext_control(data_ext_control_d),
      .alu_control(alu_control_d),
      .alu_src(alu_src_d),
      .imm_src(imm_src_d),
      .reg_write(reg_write_d)
  );

  cpu_register_file register_file (
      .clk(~clk),
      .rst_n(rst_n),
      .a1(rs1_d),
      .a2(rs2_d),
      .a3(rd_w),
      .we3(reg_write_w),
      .wd3(result_w),

      .rd1(rd1_d),
      .rd2(rd2_d)
  );

  cpu_imm_extend imm_extend (
      .data(instr_d[31:7]),
      .imm_src(imm_src_d),
      .imm_ext(imm_ext_d)
  );

  // 3. Execute
  reg reg_write_e;
  reg [1:0] result_src_e;
  reg [3:0] mem_write_e;
  reg [2:0] data_ext_control_e;
  reg [3:0] alu_control_e;
  reg alu_src_e;

  reg [31:0] rd1_e;
  reg [31:0] rd2_e;
  reg [31:0] pc_e;
  reg [4:0] rs1_e;
  reg [4:0] rs2_e;
  reg [4:0] rd_e;
  reg [31:0] imm_ext_e;
  reg [31:0] pc_plus_4_e;
  reg [2:0] branch_type_e;
  reg [2:0] funct3_e;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || flush_e) begin
      reg_write_e <= 0;
      result_src_e <= `RESULT_SRC_ALU;
      mem_write_e <= 0;
      data_ext_control_e <= 4'b0000;
      alu_control_e <= 4'b0000;
      alu_src_e <= `ALU_SRC_RD;

      rd1_e <= 5'b0;
      rd2_e <= 5'b0;
      pc_e <= {32{1'bx}};
      rs1_e <= 32'b0;
      rs2_e <= 32'b0;
      rd_e <= 5'b0;
      imm_ext_e <= {32{1'bx}};
      pc_plus_4_e <= {32{1'bx}};
      branch_type_e <= `BRANCH_NONE;
      funct3_e <= 3'bxxx;
    end else begin
      reg_write_e <= reg_write_d;
      result_src_e <= result_src_d;
      mem_write_e <= mem_write_d;
      data_ext_control_e <= data_ext_control_d;
      alu_control_e <= alu_control_d;
      alu_src_e <= alu_src_d;

      rd1_e <= rd1_d;
      rd2_e <= rd2_d;
      pc_e <= pc_d;
      rs1_e <= rs1_d;
      rs2_e <= rs2_d;
      rd_e <= rd_d;
      imm_ext_e <= imm_ext_d;
      pc_plus_4_e <= pc_plus_4_d;
      branch_type_e <= branch_type_d;
      funct3_e <= funct3_d;
    end
  end

  wire [31:0] pc_target_e = pc_e + imm_ext_e;
  wire [31:0] alu_result_e;
  wire alu_zero_e;
  wire alu_borrow_e;
  wire alu_lt_e;
  wire [1:0] pc_src_e;

  pl_branch_logic branch_logic (
      .branch_type(branch_type_e),
      .funct3(funct3_e),
      .alu_zero(alu_zero_e),
      .alu_borrow(alu_borrow_e),
      .alu_lt(alu_lt_e),

      .pc_src(pc_src_e)
  );

  reg [31:0] alu_src_a_e;
  reg [31:0] write_data_e;

  always @(*) begin
    case (forward_a_e)
      `FORWARD_NONE:      alu_src_a_e = rd1_e;
      `FORWARD_WRITEBACK: alu_src_a_e = result_w;
      `FORWARD_MEMORY: begin
        case (result_src_m)
          `RESULT_SRC_ALU:       alu_src_a_e = alu_result_m;
          `RESULT_SRC_PC_TARGET: alu_src_a_e = pc_target_m;
          `RESULT_SRC_PC_STEP:   alu_src_a_e = pc_plus_4_m;
          default:               alu_src_a_e = {32{1'bx}};
        endcase
      end
      default:            alu_src_a_e = {32{1'bx}};
    endcase

    case (forward_b_e)
      `FORWARD_NONE:      write_data_e = rd2_e;
      `FORWARD_WRITEBACK: write_data_e = result_w;
      `FORWARD_MEMORY: begin
        case (result_src_m)
          `RESULT_SRC_ALU:       write_data_e = alu_result_m;
          `RESULT_SRC_PC_TARGET: write_data_e = pc_target_m;
          `RESULT_SRC_PC_STEP:   write_data_e = pc_plus_4_m;
          default:               write_data_e = {32{1'bx}};
        endcase
      end
      default:            write_data_e = {32{1'bx}};
    endcase
  end

  wire [31:0] alu_src_b_e = alu_src_e == `ALU_SRC_IMM ? imm_ext_e : write_data_e;

  cpu_alu alu (
      .src_a  (alu_src_a_e),
      .src_b  (alu_src_b_e),
      .control(alu_control_e),

      .result(alu_result_e),
      .zero(alu_zero_e),
      .borrow(alu_borrow_e),
      .lt(alu_lt_e)
  );

  // 4. Memory
  reg reg_write_m;
  reg [1:0] result_src_m;
  reg [3:0] mem_write_m;
  reg [2:0] data_ext_control_m;

  reg [31:0] alu_result_m;
  reg [31:0] write_data_m;
  reg [4:0] rd_m;
  reg [31:0] pc_target_m;
  reg [31:0] pc_plus_4_m;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_write_m <= 0;
      result_src_m <= `RESULT_SRC_ALU;
      mem_write_m <= 4'b0000;
      data_ext_control_m <= 4'b0000;

      alu_result_m <= 32'b0;
      write_data_m <= 32'b0;
      rd_m <= 5'b0;
      pc_target_m <= {32{1'bx}};
      pc_plus_4_m <= {32{1'bx}};
    end else begin
      reg_write_m <= reg_write_e;
      result_src_m <= result_src_e;
      mem_write_m <= mem_write_e;
      data_ext_control_m <= data_ext_control_e;

      alu_result_m <= alu_result_e;
      write_data_m <= write_data_e;
      rd_m <= rd_e;
      pc_target_m <= pc_target_e;
      pc_plus_4_m <= pc_plus_4_e;
    end
  end

  wire [31:0] read_data_m;

  assign data_addr = alu_result_m;
  assign data_wdata = write_data_m;
  assign data_wenable = mem_write_m;

  cpu_data_extend data_extend (
      .data(data_rdata),
      .control(data_ext_control_m),
      .data_ext(read_data_m)
  );

  // 5. Writeback
  reg reg_write_w;
  reg [1:0] result_src_w;

  reg [31:0] alu_result_w;
  reg [31:0] read_data_w;
  reg [4:0] rd_w;
  reg [31:0] pc_target_w;
  reg [31:0] pc_plus_4_w;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_write_w <= 0;
      result_src_w <= `RESULT_SRC_ALU;

      alu_result_w <= 32'b0;
      read_data_w <= 32'b0;
      rd_w <= 5'b0;
      pc_target_w <= {32{1'bx}};
      pc_plus_4_w <= {32{1'bx}};
    end else begin
      reg_write_w <= reg_write_m;
      result_src_w <= result_src_m;

      alu_result_w <= alu_result_m;
      read_data_w <= read_data_m;
      rd_w <= rd_m;
      pc_target_w <= pc_target_m;
      pc_plus_4_w <= pc_plus_4_m;
    end
  end

  reg [31:0] result_w;

  always @(*) begin
    case (result_src_w)
      `RESULT_SRC_ALU:       result_w = alu_result_w;
      `RESULT_SRC_DATA:      result_w = read_data_w;
      `RESULT_SRC_PC_TARGET: result_w = pc_target_w;
      `RESULT_SRC_PC_STEP:   result_w = pc_plus_4_w;
      default:               result_w = {32{1'bx}};
    endcase
  end
endmodule

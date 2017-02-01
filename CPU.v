
module cpu_module (
  input [31:0] instr_in,
  output [31:0] instr_sel,
  input clock,
  input reset
  );

  `include "asm_codes.vh"

  // Разбор инструкции
  wire [5:0] instr_opcode = instr_in[31:26]; // 6 бит
  // Инструкции P-типа
  wire [4:0] instr_rs = instr_in[25:21]; // 5 бит
  wire [4:0] instr_rt = instr_in[20:16]; // 5 бит
  wire [4:0] instr_rd = instr_in[15:11]; // 5 бит
  wire [4:0] instr_shamt = instr_in[10:6]; // 5 бит
  wire [5:0] instr_funct = instr_in[5:0]; // 6 бит
  // Инструкции L-типа
  wire [15:0] instr_imm = instr_in[15:0]; // 16 бит
  // Инструкции J-типа
  wire [25:0] instr_addr = instr_in[25:0]; // 26 бит

  // Счетчик команд
  wire [31:0]pc_out;
  wire [31:0]pc_in;
  wire pc_write;
  register pc (.clock(clock), .write(pc_write), .in(pc_in), .out(pc_out));

  assign instr_sel = pc_out; // Порядок имеет значение!
  assign pc_in = reset ? 32'd0 : (pc_out + 32'd4); // Пока PC=PC+4;
  assign pc_write = 1'b1;
  
  // Регистры процессора
  wire [4:0]regs_rnum1;
  wire [4:0]regs_rnum2;
  wire [4:0]regs_wnum;
  wire [31:0]regs_rdata1;
  wire [31:0]regs_rdata2;
  wire [31:0]regs_wdata;
  wire regs_write;
  registers_array regs (.clock(clock), .write(regs_write), .rnum1(regs_rnum1), .rnum2(regs_rnum2), .wnum(regs_wnum), .rdata1(regs_rdata1), .rdata2(regs_rdata2), .wdata(regs_wdata), .reset(reset));

  assign regs_rnum1 = // Номер регистра А для чтения из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? instr_rs : // ADD: Первый аргумент аргумент инструкции
    (instr_opcode == OP_ADDI) ? instr_rt // ADDI: Второй аргумент инструкции
    : 5'b0;

  assign regs_rnum2 = // Номер регистра Б для чтения из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? instr_rd : // ADD: Второй аргумент аргумент инструкции
    (instr_opcode == OP_ADDI) ? 5'b0 // ADDI: Регистр Б не используется
    : 5'b0;

  assign regs_write = ( // При исполнении каких инструкции производить запись в регистры
    (instr_opcode == OP_R) & (instr_funct == OPR_ADD) | // ADD
    (instr_opcode == OP_ADDI) // ADDI
    ) ? 1'b1 : 1'b0;

  assign regs_wnum = // Номер регистра в который производить запись
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? instr_rd : // ADD: Третий аргумент инструкции
    (instr_opcode == OP_ADDI) ? instr_rs // ADDI: Первый аргумент инструкции
    : 32'b0;

  assign regs_wdata = // Данные для записи в блок регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? alu_out : // ADD: С выхода АЛУ
    (instr_opcode == OP_ADDI) ? alu_out // ADDI: С выхода АЛУ
    : 32'b0;

  // АЛУ
  wire [31:0]alu_int1;
  wire [31:0]alu_int2;
  wire [5:0]alu_opcode;
  wire [31:0]alu_out;
  alu_module alu (.int1(alu_int1), .int2(alu_int2), .opcode(alu_opcode), .out(alu_out));

  assign alu_int1 = // Первый аргумент для АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? regs_rdata1 : // ADD: Регистр А из блока регистров
    (instr_opcode == OP_ADDI) ? regs_rdata1 // ADDI: Регистр А из блока регистров
    : 32'b0;

  assign alu_int2 = // Второй аргумент для АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? regs_rdata2 : // ADD: Регистр Б из блока регистров
    (instr_opcode == OP_ADDI) ? instr_imm // ADDI: Константа из инструкции
    : 32'b0;

  assign alu_opcode = // Операция для АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? ALU_ADD : // ADD: Сложить
    (instr_opcode == OP_ADDI) ? ALU_ADD // ADDI: Сложить
    : 32'b0;

endmodule

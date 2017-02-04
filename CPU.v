
module cpu_module (
  input [31:0] instr_in,
  output [31:0] instr_sel,
  output [31:0] ram_rnum,
  output [31:0] ram_wnum,
  input [31:0] ram_rdata,
  output [31:0] ram_wdata,
  output ram_write,
  output ram_clock,
  input clock,
  input reset
  );

  `include "asm_codes.vh"

  // Разбор инструкции
  wire [5:0] instr_opcode = instr_in[31:26]; // 6 бит
  // Инструкции P-типа
  wire [4:0] instr_rs = instr_in[25:21];     // 5 бит
  wire [4:0] instr_rt = instr_in[20:16];     // 5 бит
  wire [4:0] instr_rd = instr_in[15:11];     // 5 бит
  wire [4:0] instr_shamt = instr_in[10:6];   // 5 бит
  wire [5:0] instr_funct = instr_in[5:0];    // 6 бит
  // Инструкции L-типа
  wire [15:0] instr_imm = instr_in[15:0];    // 16 бит
  // Инструкции J-типа
  wire [25:0] instr_addr = instr_in[25:0];   // 26 бит

  // Счетчик команд
  wire [31:0]pc_out;
  wire [31:0]pc_in;
  wire pc_write;

  register pc ( // Program Counter
    .clock(clock),
    .write(pc_write),
    .in(pc_in),
    .out(pc_out)
    );

  assign instr_sel = pc_out; // Порядок имеет значение! Аналог диода (логический повторитель).
  assign pc_write = 1'b1; // Program Counter записывается на каждом такте
  assign pc_in = reset ? 32'd0 : // Следующее значение счетчика команд
    ((instr_opcode == OP_BNE) & ( alu_zero)) ? (instr_imm << 2) + 32'd4 : // BNE
    ((instr_opcode == OP_BEQ) & (!alu_zero)) ? (instr_imm << 2) + 32'd4 : // BEQ
    (instr_opcode == OP_J) ? (instr_addr << 2) : // Jump
    (pc_out + 32'd4); // По-умолчанию PC=PC+4;
  
  // Регистры процессора
  wire [4:0]regs_rnum1;
  wire [4:0]regs_rnum2;
  wire [4:0]regs_wnum;
  wire [31:0]regs_rdata1;
  wire [31:0]regs_rdata2;
  wire [31:0]regs_wdata;
  wire regs_write;

  registers_array regs (
    .clock(clock),
    .write(regs_write),
    .rnum1(regs_rnum1),
    .rnum2(regs_rnum2),
    .wnum(regs_wnum),
    .rdata1(regs_rdata1),
    .rdata2(regs_rdata2),
    .wdata(regs_wdata),
    .reset(reset)
    );

  assign regs_rnum1 = // Номер регистра А для чтения из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? instr_rs : // ADD: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SUB)) ? instr_rs : // SUB: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLL)) ? instr_rs : // SLL: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRL)) ? instr_rs : // SRL: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRA)) ? instr_rs : // SRA: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLT)) ? instr_rs : // SLT: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_AND)) ? instr_rs : // AND: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_XOR)) ? instr_rs : // XOR: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_NOR)) ? instr_rs : // NOR: Первый аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_OR)) ? instr_rs :  // OR: Первый аргумент аргумент инструкции
    (instr_opcode == OP_ADDI) ? instr_rs :                           // ADDI: Первый аргумент инструкции
    (instr_opcode == OP_ADDIU) ? instr_rs :                          // ADDIU: Первый аргумент инструкции
    (instr_opcode == OP_ANDI) ? instr_rs :                           // ANDI: Первый аргумент инструкции
    (instr_opcode == OP_ORI) ? instr_rs :                            // ORI: Первый аргумент инструкции
    (instr_opcode == OP_SLTI) ? instr_rs :                           // SLTI: Первый аргумент инструкции
    (instr_opcode == OP_SLTIU) ? instr_rs :                          // SLTIU: Первый аргумент инструкции
    (instr_opcode == OP_BNE) ? instr_rs :                            // BNE: Первый аргумент инструкции
    (instr_opcode == OP_BEQ) ? instr_rs :                            // BEQ: Первый аргумент инструкции
    (instr_opcode == OP_J) ? 5'b0 :                                  // J не испоьзует чтение из регистров
    (instr_opcode == OP_LW) ? 5'b0 :                                 // LW не испоьзует чтение из регистров
    (instr_opcode == OP_SW) ? instr_rs :                             // SW: Первый аргумент инструкции
    5'b0;

  assign regs_rnum2 = // Номер регистра Б для чтения из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? instr_rt : // ADD: Второй аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SUB)) ? instr_rt : // SUB: Второй аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLL)) ? 5'b0 :     // SLL: Регистр Б не используется
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRL)) ? 5'b0 :     // SRL: Регистр Б не используется
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRA)) ? 5'b0 :     // SRA: Регистр Б не используется
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLT)) ? instr_rt : // SLT: Второй аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_AND)) ? instr_rt : // AND: Второй аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_XOR)) ? instr_rt : // XOR: Второй аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_NOR)) ? instr_rt : // NOR: Второй аргумент аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_OR)) ? instr_rt :  // OR: Второй аргумент аргумент инструкции
    (instr_opcode == OP_ADDI) ? 5'b0 :                               // ADDI: Регистр Б не используется
    (instr_opcode == OP_ADDIU) ? 5'b0 :                              // ADDIU: Регистр Б не используется
    (instr_opcode == OP_ANDI) ? 5'b0 :                               // ANDI: Регистр Б не используется
    (instr_opcode == OP_ORI) ? 5'b0 :                                // ORI: Регистр Б не используется
    (instr_opcode == OP_ORI) ? 5'b0 :                                // ORI: Регистр Б не используется
    (instr_opcode == OP_SLTI) ? 5'b0 :                               // SLTI: Регистр Б не используется
    (instr_opcode == OP_SLTIU) ? 5'b0 :                              // SLTIU: Регистр Б не используется
    (instr_opcode == OP_BNE) ? instr_rt :                            // BNE: Второй аргумент аргумент инструкции
    (instr_opcode == OP_BEQ) ? instr_rt :                            // BEQ: Второй аргумент аргумент инструкции
    (instr_opcode == OP_J) ? 5'b0 :                                  // J не испоьзует чтение из регистров
    (instr_opcode == OP_LW) ? 5'b0 :                                 // LW не испоьзует чтение из регистров
    (instr_opcode == OP_SW) ? instr_rt :                             // SW: Второй аргумент аргумент инструкции
    5'b0;

  assign regs_write = ( // При исполнении каких инструкции производить запись в регистры
    (instr_opcode == OP_R) & (instr_funct == OPR_ADD) | // ADD
    (instr_opcode == OP_R) & (instr_funct == OPR_SUB) | // SUB
    (instr_opcode == OP_R) & (instr_funct == OPR_SLL) | // SLL
    (instr_opcode == OP_R) & (instr_funct == OPR_SRL) | // SRL
    (instr_opcode == OP_R) & (instr_funct == OPR_SRA) | // SRA
    (instr_opcode == OP_R) & (instr_funct == OPR_SLT) | // SLT
    (instr_opcode == OP_R) & (instr_funct == OPR_AND) | // AND
    (instr_opcode == OP_R) & (instr_funct == OPR_XOR) | // XOR
    (instr_opcode == OP_R) & (instr_funct == OPR_NOR) | // NOR
    (instr_opcode == OP_R) & (instr_funct == OPR_OR) |  // OR
    (instr_opcode == OP_ADDI) |                         // ADDI
    (instr_opcode == OP_ADDIU) |                        // ADDIU
    (instr_opcode == OP_ANDI) |                         // ANDI
    (instr_opcode == OP_ORI) |                          // ORI
    (instr_opcode == OP_SLTI) |                         // SLTI
    (instr_opcode == OP_SLTIU)|                         // SLTIU
    // BNE не использует запись в регистры
    // BEQ не использует запись в регистры
    // J не использует запись в регистры
    (instr_opcode == OP_LW)                             // LW
    // SW не использует запись в регистры
    ) ? 1'b1 : 1'b0;

  assign regs_wnum = // Номер регистра в который производить запись
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? instr_rd : // ADD: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SUB)) ? instr_rd : // SUB: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLL)) ? instr_rd : // SLL: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRL)) ? instr_rd : // SRL: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRA)) ? instr_rd : // SRA: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLT)) ? instr_rd : // SLT: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_AND)) ? instr_rd : // AND: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_XOR)) ? instr_rd : // XOR: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_NOR)) ? instr_rd : // NOR: Третий аргумент инструкции
    ((instr_opcode == OP_R) & (instr_funct == OPR_OR)) ? instr_rd :  // OR: Третий аргумент инструкции
    (instr_opcode == OP_ADDI) ? instr_rt :                           // ADDI: Второй аргумент инструкции
    (instr_opcode == OP_ADDIU) ? instr_rt :                          // ADDIU: Второй аргумент инструкции
    (instr_opcode == OP_ANDI) ? instr_rt :                           // ANDI: Второй аргумент инструкции
    (instr_opcode == OP_ORI) ? instr_rt :                            // ORI: Второй аргумент инструкции
    (instr_opcode == OP_SLTI) ? instr_rt :                           // SLTI: Второй аргумент инструкции
    (instr_opcode == OP_SLTIU) ? instr_rt :                          // SLTIU: Второй аргумент инструкции
    (instr_opcode == OP_BNE) ? 32'b0 :                               // BNE не использует запись в регистры
    (instr_opcode == OP_BEQ) ? 32'b0 :                               // BEQ не использует запись в регистры
    (instr_opcode == OP_J) ? 32'b0 :                                 // J не использует запись в регистры
    (instr_opcode == OP_LW) ? instr_rt :                             // LW: Второй аргумент инструкции
    (instr_opcode == OP_SW) ? 32'b0 :                                // SW не использует запись в регистры
    32'b0;

  assign regs_wdata = // Данные для записи в блок регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? alu_out : // ADD: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_SUB)) ? alu_out : // SUB: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLL)) ? alu_out : // SLL: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRL)) ? alu_out : // SRL: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRA)) ? alu_out : // SRA: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLT)) ? alu_out : // SLT: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_AND)) ? alu_out : // AND: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_XOR)) ? alu_out : // XOR: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_NOR)) ? alu_out : // NOR: С выхода АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_OR)) ? alu_out :  // OR: С выхода АЛУ
    (instr_opcode == OP_ADDI) ? alu_out :                           // ADDI: С выхода АЛУ
    (instr_opcode == OP_ADDIU) ? alu_out :                          // ADDIU: С выхода АЛУ
    (instr_opcode == OP_ANDI) ? alu_out :                           // ANDI: С выхода АЛУ
    (instr_opcode == OP_ORI) ? alu_out :                            // ORI: С выхода АЛУ
    (instr_opcode == OP_SLTI) ? alu_out :                           // SLTI: С выхода АЛУ
    (instr_opcode == OP_SLTIU) ? alu_out :                          // SLTIU: С выхода АЛУ
    (instr_opcode == OP_BNE) ? 32'b0 :                              // BNE не использует запись в регистры
    (instr_opcode == OP_BEQ) ? 32'b0 :                              // BEQ не использует запись в регистры
    (instr_opcode == OP_J) ? 32'b0 :                                // J не использует запись в регистры
    (instr_opcode == OP_LW) ? ram_rdata :                           // LW: Значение из оперативной памяти
    (instr_opcode == OP_SW) ? 32'b0 :                               // SW не использует запись в регистры
    32'b0;

  // АЛУ
  wire [31:0]alu_int1;
  wire [31:0]alu_int2;
  wire [5:0]alu_opcode;
  wire [31:0]alu_out;
  wire alu_zero;

  alu_module alu (
    .int1(alu_int1),
    .int2(alu_int2),
    .opcode(alu_opcode),
    .out(alu_out),
    .zero(alu_zero)
    );

  assign alu_int1 = // Первый аргумент для АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? regs_rdata1 : // ADD: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_SUB)) ? regs_rdata1 : // SUB: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLL)) ? regs_rdata1 : // SLL: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRL)) ? regs_rdata1 : // SRL: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRA)) ? regs_rdata1 : // SRA: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLT)) ? regs_rdata1 : // SLT: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_AND)) ? regs_rdata1 : // AND: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_XOR)) ? regs_rdata1 : // XOR: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_NOR)) ? regs_rdata1 : // NOR: Регистр А из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_OR)) ? regs_rdata1 :  // OR: Регистр А из блока регистров
    (instr_opcode == OP_ADDI) ? regs_rdata1 :                           // ADDI: Регистр А из блока регистров
    (instr_opcode == OP_ADDIU) ? regs_rdata1 :                          // ADDIU: Регистр А из блока регистров
    (instr_opcode == OP_ANDI) ? regs_rdata1 :                           // ANDI: Регистр А из блока регистров
    (instr_opcode == OP_ORI) ? regs_rdata1 :                            // ORI: Регистр А из блока регистров
    (instr_opcode == OP_SLTI) ? regs_rdata1 :                           // SLTI: Регистр А из блока регистров
    (instr_opcode == OP_SLTIU) ? regs_rdata1 :                          // SLTIU: Регистр А из блока регистров
    (instr_opcode == OP_BNE) ? regs_rdata1 :                            // BEQ: Регистр А из блока регистров
    (instr_opcode == OP_BEQ) ? regs_rdata1 :                            // BEQ: Регистр А из блока регистров
    (instr_opcode == OP_J) ? 32'b0 :                                    // J не использует АЛУ
    (instr_opcode == OP_LW) ? instr_rs :                                // LW: Первый аргумент инструкции
    (instr_opcode == OP_SW) ? regs_rdata1 :                             // SW: Первый аргумент инструкции
    32'b0;

  assign alu_int2 = // Второй аргумент для АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? regs_rdata2 : // ADD: Регистр Б из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_SUB)) ? regs_rdata2 : // SUB: Регистр Б из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLL)) ? instr_shamt : // SLL: SHAMT
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRL)) ? instr_shamt : // SRL: SHAMT
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRA)) ? instr_shamt : // SRA: SHAMT
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLT)) ? regs_rdata2 : // SLT: Регистр Б из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_AND)) ? regs_rdata2 : // AND: Регистр Б из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_XOR)) ? regs_rdata2 : // XOR: Регистр Б из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_NOR)) ? regs_rdata2 : // NOR: Регистр Б из блока регистров
    ((instr_opcode == OP_R) & (instr_funct == OPR_OR)) ? regs_rdata2 :  // OR: Регистр Б из блока регистров
    (instr_opcode == OP_ADDI) ? ((instr_imm & 16'h7FFF) | ((instr_imm & 16'h8000) << 16)) : // ADDI: Константа из инструкции, расширеная, со знаком
    (instr_opcode == OP_ADDIU) ? instr_imm :                            // ADDIU: Константа из инструкции
    (instr_opcode == OP_ANDI) ? instr_imm :                             // ANDI: Константа из инструкции
    (instr_opcode == OP_ORI) ? instr_imm :                              // ORI: Константа из инструкции
    (instr_opcode == OP_SLTI) ? ((instr_imm & 16'h7FFF) | ((instr_imm & 16'h8000) << 16)) : // SLTI: Константа из инструкции, расширеная, со знаком
    (instr_opcode == OP_SLTIU) ? instr_imm :                            // SLTIU: Константа из инструкции
    (instr_opcode == OP_BNE) ? regs_rdata2 :                            // BNE: Регистр Б из блока регистров
    (instr_opcode == OP_BEQ) ? regs_rdata2 :                            // BEQ: Регистр Б из блока регистров
    (instr_opcode == OP_J) ? 32'b0 :                                    // J не использует АЛУ
    (instr_opcode == OP_LW) ? instr_imm :                               // LW: Константа из инструкции
    (instr_opcode == OP_SW) ? instr_imm :                               // SW: Константа из инструкции
    32'b0;

  assign alu_opcode = // Операция для АЛУ
    ((instr_opcode == OP_R) & (instr_funct == OPR_ADD)) ? ALU_ADD : // ADD: Сложить
    ((instr_opcode == OP_R) & (instr_funct == OPR_SUB)) ? ALU_SUB : // SUB: Вычесть
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLL)) ? ALU_SHL : // SLL: Сдвиг влево
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRL)) ? ALU_SHR : // SRL: Сдвиг вправо
    ((instr_opcode == OP_R) & (instr_funct == OPR_SRA)) ? ALU_SRA : // SRA: SRA
    ((instr_opcode == OP_R) & (instr_funct == OPR_SLT)) ? ALU_SLT : // SLT: Сравнение "Меньше"
    ((instr_opcode == OP_R) & (instr_funct == OPR_AND)) ? ALU_AND : // AND: Логическое AND
    ((instr_opcode == OP_R) & (instr_funct == OPR_XOR)) ? ALU_XOR : // XOR: Логическое XOR
    ((instr_opcode == OP_R) & (instr_funct == OPR_NOR)) ? ALU_NOR : // NOR: Логическое NOR
    ((instr_opcode == OP_R) & (instr_funct == OPR_OR)) ? ALU_OR :   // OR: Логическое OR
    (instr_opcode == OP_ADDI) ? ALU_ADD :                           // ADDI: Сложить
    (instr_opcode == OP_ADDIU) ? ALU_ADD :                          // ADDIU: Сложить
    (instr_opcode == OP_ANDI) ? ALU_AND :                           // ANDI: Логическое AND
    (instr_opcode == OP_ORI) ? ALU_OR :                             // ORI: Логическое OR
    (instr_opcode == OP_SLTI) ? ALU_SLT :                           // SLTI: Сравнение "Меньше"
    (instr_opcode == OP_SLTIU) ? ALU_SLT :                          // SLTIU: Сравнение "Меньше"
    (instr_opcode == OP_BNE) ? ALU_XOR :                            // BNE: Сравнение путём XOR
    (instr_opcode == OP_BEQ) ? ALU_XOR :                            // BNE: Сравнение путём XOR
    (instr_opcode == OP_J) ? 32'b0 :                                // J не использует АЛУ
    (instr_opcode == OP_LW) ? ALU_ADD :                             // LW: Сложить адреса
    (instr_opcode == OP_SW) ? ALU_ADD :                             // SW: Сложить адреса
    32'b0;

  // Оперативная память
  assign ram_rnum = // Номер ячейки, с которой читаем из RAM
    (instr_opcode == OP_LW) ? alu_out : // LW: Результат сложения адресов из АЛУ
    32'b0;
  assign ram_wnum = // Номер ячейки RAM , в которую пишем
    (instr_opcode == OP_SW) ? alu_out : // SW: Результат сложения адресов из АЛУ
    32'b0;
  assign ram_wdata = // Информация, которую пишем в RAM
    (instr_opcode == OP_SW) ? regs_rdata2 : // Регистр А из блока регистров
    32'b0;
  assign ram_write = // Флаг записи RAM
    (instr_opcode == OP_SW);
  assign ram_clock = // Тактовый генератор RAM
    (instr_opcode == OP_SW) & clock; // Тактирование для нашей оперативной памяти обязательно только при записи

endmodule


module alu_module (
  input [31:0] int1,
  input [31:0] int2,
  input [5:0] opcode,
  output [31:0] out,
  output zero
  );
 
  `include "asm_codes.vh"

  assign out = 
  (opcode == ALU_ADD) ? int1 + int2 :
  (opcode == ALU_SUB) ? int1 - int2 :
  (opcode == ALU_SHL) ? int1 << int2 :
  (opcode == ALU_SHR) ? int1 >> int2 :
  (opcode == ALU_SRA) ? int1 >>> int2 :
  (opcode == ALU_SLT) ? int1 < int2 :
  (opcode == ALU_AND) ? int1 & int2 :
  (opcode == ALU_XOR) ? int1 ^ int2 :
  (opcode == ALU_NOR) ? ~(int1 | int2) :
  (opcode == ALU_OR) ? int1 | int2 :
  32'd0;

  assign zero = (out == 0);

endmodule


module alu_module (
  input [31:0] int1,
  input [31:0] int2,
  input [5:0] opcode,
  output reg [31:0] out, // reg is bad idea
  output zero
  );
 
  `include "asm_codes.vh"
  
  always @(int1, int2, opcode)
  begin
  	case (opcode)
  	ALU_ADD: out <= int1 + int2;
  	ALU_SUB: out <= int1 - int2;
  	default: out <= 0;
  	endcase
  end

  assign zero = (out == 0);

endmodule

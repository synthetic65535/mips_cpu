module instruction_memory (
  input [31:0] sel,
  output reg [31:0] out,
  input clock
  );
  
  `include "asm_codes.vh"
  
  always @(posedge clock)
  begin
    case (sel)
      32'h00000000 : out <= {OP_ADDI, R01, R01, 16'd1};       // ADDI R0, R0, 1
      32'h00000004 : out <= {OP_ADDI, R02, R02, 16'd2};       // ADDI R1, R1, 2
      32'h00000008 : out <= {OP_R, R01, R02, R03, OPR_ADD};   // ADD R0, R1, R2
      default: out <= 0;
    endcase
  end
endmodule

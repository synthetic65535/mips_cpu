module instruction_memory (
  input [31:0] sel,
  output reg [31:0] out,
  input clock
  );
  
  parameter OP_R = 6'b000000;
  parameter OP_ADDI = 6'b001000;
  parameter OP_BEQ = 6'b000100;
  parameter OP_BNE = 6'b000101;
  parameter OP_LW = 6'b100011;
  parameter OP_SW = 6'b101011;
  
  parameter OPR_ADD = 6'b100000;
  parameter OPR_SUB = 6'b100010;
  
  parameter R00 = 5'd0;
  parameter R01 = 5'd1;
  parameter R02 = 5'd2;
  parameter R03 = 5'd3;
  parameter R04 = 5'd4;
  parameter R05 = 5'd5;
  parameter R06 = 5'd6;
  parameter R07 = 5'd7;
  parameter R08 = 5'd8;
  parameter R09 = 5'd9;
  parameter R10 = 5'd0;
  parameter R11 = 5'd1;
  parameter R12 = 5'd2;
  parameter R13 = 5'd3;
  parameter R14 = 5'd4;
  parameter R15 = 5'd5;
  parameter R16 = 5'd6;
  parameter R17 = 5'd7;
  parameter R18 = 5'd8;
  parameter R19 = 5'd9;
  parameter R20 = 5'd0;
  parameter R21 = 5'd1;
  parameter R22 = 5'd2;
  parameter R23 = 5'd3;
  parameter R24 = 5'd4;
  parameter R25 = 5'd5;
  parameter R26 = 5'd6;
  parameter R27 = 5'd7;
  parameter R28 = 5'd8;
  parameter R29 = 5'd9;
  parameter R30 = 5'd0;
  parameter R31 = 5'd1;
  
  always @(posedge clock)
  begin
    case (sel)
      32'h00000000 : out <= {OP_R, R00, R02, R02, OPR_ADD};
      32'h00000001 : out <= {OP_R, R01, R02, R02, OPR_ADD};
      32'h00000002 : out <= {OP_BEQ, R00, R01, 16'hFFFD};
      default: out <= 0;
    endcase
  end
endmodule

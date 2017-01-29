
module register (
  input [31:0] in,
  output reg [31:0] out,
  input write,
  input clock
  );
  
  always @(posedge clock)
  begin
    if (write) out <= in;
  end

endmodule


module register (
  input [31:0] in,
  output reg [31:0] out,
  input write,
  input clock
  );
  
  always @(negedge clock) // Чтение данных по фронту clock, запись - по спаду
  begin
    if (write) out <= in;
  end

endmodule

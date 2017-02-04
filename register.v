
module register
  #(parameter WIDH = 32)
  (
  input [WIDH-1:0] in,
  output reg [WIDH-1:0] out,
  input write,
  input clock
  );
  
  always @(negedge clock) // Чтение данных по фронту clock, запись - по спаду
  begin
    if (write) out <= in;
  end

endmodule

module registers_array (
  input [4:0] rnum1,
  input [4:0] rnum2,
  input [4:0] wnum,
  input [31:0] wdata,
  output [31:0] rdata1,
  output [31:0] rdata2,
  input clock,
  input write,
  input reset
  );
  
  // Выходы регистров
  wire [31:0]register_out [0:31];

  // Массив регистров
  genvar i;
  generate
  for (i=0; i < 32; i=i+1)
    begin: myregs
      register myreg (
        .clock(clock),
        .write(write & (wnum == i) | reset),
        .in(reset ? 32'd0 : wdata),
        .out(register_out[i])
        );
      assign rdata1 = (rnum1 == i) ? register_out[i] : 32'hzzzzzzzz;
      assign rdata2 = (rnum2 == i) ? register_out[i] : 32'hzzzzzzzz;
    end
  endgenerate
  
endmodule

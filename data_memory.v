module data_memory
  #(parameter SIZE = 64)
  (
  input [31:0] rnum,
  input [31:0] wnum,
  input [31:0] wdata,
  output [31:0] rdata,
  input clock,
  input write,
  input reset
  );

  // Эта оперативная память читается/пишется блоками по 32 бита, для упрощения
  
  // Выходы регистров
  wire [31:0]register_out [0:SIZE-1];

  // Массив регистров
  genvar i;  
  generate  
  for (i=0; i < SIZE; i=i+1)
    begin: myregs  
      register myreg (
        .clock(clock),
        .write(write & (wnum == i) | reset),
        .in(reset ? 32'd0 : wdata),
        .out(register_out[i])
        );
      assign rdata = (rnum == i) ? register_out[i] : 32'hzzzzzzzz;
    end
  endgenerate  
  
endmodule

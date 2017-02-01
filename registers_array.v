module registers_array (
  input [4:0] rnum1,
  input [4:0] rnum2,
  input [4:0] wnum,
  input [31:0] wdata,
  output reg [31:0] rdata1,
  output reg [31:0] rdata2,
  input clock,
  input write,
  input reset
  );
  
  // Выходы регистров
  wire [31:0]register_out [31:0];
  
  // Регистры
  register r00 (.clock(clock), .write(write & (wnum == 5'd00) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd00]));
  register r01 (.clock(clock), .write(write & (wnum == 5'd01) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd01]));
  register r02 (.clock(clock), .write(write & (wnum == 5'd02) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd02]));
  register r03 (.clock(clock), .write(write & (wnum == 5'd03) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd03]));
  register r04 (.clock(clock), .write(write & (wnum == 5'd04) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd04]));
  register r05 (.clock(clock), .write(write & (wnum == 5'd05) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd05]));
  register r06 (.clock(clock), .write(write & (wnum == 5'd06) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd06]));
  register r07 (.clock(clock), .write(write & (wnum == 5'd07) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd07]));
  register r08 (.clock(clock), .write(write & (wnum == 5'd08) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd08]));
  register r09 (.clock(clock), .write(write & (wnum == 5'd09) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd09]));
  register r10 (.clock(clock), .write(write & (wnum == 5'd10) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd10]));
  register r11 (.clock(clock), .write(write & (wnum == 5'd11) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd11]));
  register r12 (.clock(clock), .write(write & (wnum == 5'd12) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd12]));
  register r13 (.clock(clock), .write(write & (wnum == 5'd13) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd13]));
  register r14 (.clock(clock), .write(write & (wnum == 5'd14) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd14]));
  register r15 (.clock(clock), .write(write & (wnum == 5'd15) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd15]));
  register r16 (.clock(clock), .write(write & (wnum == 5'd16) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd16]));
  register r17 (.clock(clock), .write(write & (wnum == 5'd17) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd17]));
  register r18 (.clock(clock), .write(write & (wnum == 5'd18) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd18]));
  register r19 (.clock(clock), .write(write & (wnum == 5'd19) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd19]));
  register r20 (.clock(clock), .write(write & (wnum == 5'd20) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd20]));
  register r21 (.clock(clock), .write(write & (wnum == 5'd21) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd21]));
  register r22 (.clock(clock), .write(write & (wnum == 5'd22) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd22]));
  register r23 (.clock(clock), .write(write & (wnum == 5'd23) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd23]));
  register r24 (.clock(clock), .write(write & (wnum == 5'd24) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd24]));
  register r25 (.clock(clock), .write(write & (wnum == 5'd25) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd25]));
  register r26 (.clock(clock), .write(write & (wnum == 5'd26) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd26]));
  register r27 (.clock(clock), .write(write & (wnum == 5'd27) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd27]));
  register r28 (.clock(clock), .write(write & (wnum == 5'd28) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd28]));
  register r29 (.clock(clock), .write(write & (wnum == 5'd29) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd29]));
  register r30 (.clock(clock), .write(write & (wnum == 5'd30) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd30]));
  register r31 (.clock(clock), .write(write & (wnum == 5'd31) | reset), .in(reset ? 32'd0 : wdata), .out(register_out[5'd31]));
  
  // Мультиплексор, осуществляющий чтение rdata1 по фронту clock
  always @(posedge clock)
  begin
    case (rnum1)
    5'd00 : rdata1 <= register_out[00];
    5'd01 : rdata1 <= register_out[01];
    5'd02 : rdata1 <= register_out[02];
    5'd03 : rdata1 <= register_out[03];
    5'd04 : rdata1 <= register_out[04];
    5'd05 : rdata1 <= register_out[05];
    5'd06 : rdata1 <= register_out[06];
    5'd07 : rdata1 <= register_out[07];
    5'd08 : rdata1 <= register_out[08];
    5'd09 : rdata1 <= register_out[09];
    5'd10 : rdata1 <= register_out[10];
    5'd11 : rdata1 <= register_out[11];
    5'd12 : rdata1 <= register_out[12];
    5'd13 : rdata1 <= register_out[13];
    5'd14 : rdata1 <= register_out[14];
    5'd15 : rdata1 <= register_out[15];
    5'd16 : rdata1 <= register_out[16];
    5'd17 : rdata1 <= register_out[17];
    5'd18 : rdata1 <= register_out[18];
    5'd19 : rdata1 <= register_out[19];
    5'd20 : rdata1 <= register_out[20];
    5'd21 : rdata1 <= register_out[21];
    5'd22 : rdata1 <= register_out[22];
    5'd23 : rdata1 <= register_out[23];
    5'd24 : rdata1 <= register_out[24];
    5'd25 : rdata1 <= register_out[25];
    5'd26 : rdata1 <= register_out[26];
    5'd27 : rdata1 <= register_out[27];
    5'd28 : rdata1 <= register_out[28];
    5'd29 : rdata1 <= register_out[29];
    5'd30 : rdata1 <= register_out[30];
    5'd31 : rdata1 <= register_out[31];
    default: rdata1 <= 0;
    endcase
  end
  
  // Мультиплексор, осуществляющий чтение rdata2 по фронту clock
  always @(posedge clock)
  begin
    case (rnum2)
    5'd00 : rdata2 <= register_out[00];
    5'd01 : rdata2 <= register_out[01];
    5'd02 : rdata2 <= register_out[02];
    5'd03 : rdata2 <= register_out[03];
    5'd04 : rdata2 <= register_out[04];
    5'd05 : rdata2 <= register_out[05];
    5'd06 : rdata2 <= register_out[06];
    5'd07 : rdata2 <= register_out[07];
    5'd08 : rdata2 <= register_out[08];
    5'd09 : rdata2 <= register_out[09];
    5'd10 : rdata2 <= register_out[10];
    5'd11 : rdata2 <= register_out[11];
    5'd12 : rdata2 <= register_out[12];
    5'd13 : rdata2 <= register_out[13];
    5'd14 : rdata2 <= register_out[14];
    5'd15 : rdata2 <= register_out[15];
    5'd16 : rdata2 <= register_out[16];
    5'd17 : rdata2 <= register_out[17];
    5'd18 : rdata2 <= register_out[18];
    5'd19 : rdata2 <= register_out[19];
    5'd20 : rdata2 <= register_out[20];
    5'd21 : rdata2 <= register_out[21];
    5'd22 : rdata2 <= register_out[22];
    5'd23 : rdata2 <= register_out[23];
    5'd24 : rdata2 <= register_out[24];
    5'd25 : rdata2 <= register_out[25];
    5'd26 : rdata2 <= register_out[26];
    5'd27 : rdata2 <= register_out[27];
    5'd28 : rdata2 <= register_out[28];
    5'd29 : rdata2 <= register_out[29];
    5'd30 : rdata2 <= register_out[30];
    5'd31 : rdata2 <= register_out[31];
    default: rdata2 <= 0;
    endcase
  end
  
endmodule

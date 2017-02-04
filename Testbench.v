`timescale 1ns/1ps

module mips_testbench();

reg clock;
reg reset;
integer i, ramfile;

// Инициализируем переменные
initial begin
  $dumpfile("out.vcd");
  $dumpvars(0, mips_testbench);
  clock = 0;       // Начальное значнеие для clock
  reset = 0;       // Начальное значнеие для reset
  // Тактирование
  #1 reset = 1;    // Установка сброса
  #4 reset = 0;    // Снятие сброса
  #1000 // Сохраняем оперативную память в файл
    begin
    ramfile = $fopen("ram_dump.log","w");
    for(i=0; i<64; i=i+1)
      begin
      $fwrite(ramfile, "%d %d\n", i, ram.register_out[i]);
      end
    end
  #1001 reset = 1;  // Установка сброса
  #1010 $finish;    // Конец симуляции
end

// Тактовый генератор
always begin
  #2 clock = ~clock;
end

// Присоединяем модули

wire [31:0]instr_sel;
wire [31:0]instr_out;
instruction_memory instr (
  .sel(instr_sel),
  .out(instr_out),
  .clock(clock)
  );

wire [31:0]ram_rnum;
wire [31:0]ram_wnum;
wire [31:0]ram_rdata;
wire [31:0]ram_wdata;
wire ram_write;
wire ram_clock;

data_memory ram (
  .rnum(ram_rnum),
  .wnum(ram_wnum),
  .rdata(ram_rdata),
  .wdata(ram_wdata),
  .clock(ram_clock),
  .write(ram_write),
  .reset(reset)
  );

cpu_module cpu (
  .instr_in(instr_out),
  .instr_sel(instr_sel),
  .clock(clock),
  .reset(reset),
  .ram_rnum(ram_rnum),
  .ram_wnum(ram_wnum),
  .ram_rdata(ram_rdata),
  .ram_wdata(ram_wdata),
  .ram_write(ram_write),
  .ram_clock(ram_clock)
  );

endmodule

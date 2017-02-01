`timescale 1ns/1ps

module mips_testbench();
// Входы делаем регистрами, а выходы - проводами
reg clock;
reg reset;
reg shutdown;

// Инициализируем переменные
initial begin
  $dumpfile("out.vcd");
  $dumpvars(0, mips_testbench);
  clock = 0;       // Начальное значнеие для clock
  reset = 0;       // Начальное значнеие для reset
  // Тактирование
  #1 reset = 1;    // Установка сброса
  #4 reset = 0;   // Снятие сброса
  #496 reset = 1;    // Установка сброса
  #500 shutdown = 1;    // Завершение

end

// Тактовый генератор
always begin
  #2 clock = ~clock;
end

// Конец симуляции
always @(posedge shutdown) begin
  $finish;
end

// Присоединяем модули
wire [31:0]mem_sel;
wire [31:0]mem_out;

instruction_memory mem (.sel(mem_sel), .out(mem_out), .clock(clock));
cpu_module cpu (.instr_in(mem_out), .instr_sel(mem_sel), .clock(clock), .reset(reset));

endmodule

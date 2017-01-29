`timescale 1ns/1ps

module mips_testbench();
// Входы делаем регистрами, а выходы - проводами
reg clock;
reg reset;
reg shutdown;
wire [31:0]mem_sel;
wire [31:0]mem_out;

// Инициализируем переменные
initial begin
  $dumpfile("out.vcd");
  $dumpvars(0, mips_testbench);
  clock = 0;       // Начальное значнеие для clock
  reset = 0;       // Начальное значнеие для reset
  // Тактирование
  #2 reset = 0;    // Установка сброса
  #3 reset = 1;   // Снятие сброса
  #496 reset = 0;    // Установка сброса
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
instruction_memory instr_mem(.sel(mem_sel), .out(mem_out), .clock(clock));

endmodule

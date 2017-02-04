module instruction_memory (
  input [31:0] sel,
  output reg [31:0] out,
  input clock
  );
  
  `include "asm_codes.vh"
  
  // Предполагаем, что CPU всегда передает sel кратный четырем
  wire [31:0] addr = (sel >> 2);

  always @(posedge clock)
  begin
    case (addr)
      // Программа для вычисления чисел Фибоначчи
      32'd000 : out <= {OP_ADDIU, R01, R01, 16'd1};            // Записать в R1 единицу
      32'd001 : out <= {OP_ADDIU, R02, R02, 16'd1};            // Записать в R2 единицу
      32'd002 : out <= {OP_SW, R00, R01, 16'd0};               // Записать R1 в RAM по адресу R0
      32'd003 : out <= {OP_ADDIU, R00, R00, 16'd1};            // Увеличить адрес в R0 на единицу
      32'd004 : out <= {OP_SW, R00, R02, 16'd0};               // Записать R2 в RAM по адресу R0
      32'd005 : out <= {OP_R, R01, R02, R03, SHAMT0, OPR_ADD}; // Сложить R1+R2 и записать в R3, shamt=0
      32'd006 : out <= {OP_ADDIU, R02, R01, 16'd0};            // Скопировать из R2 в R1
      32'd007 : out <= {OP_ADDIU, R03, R02, 16'd0};            // Скопировать из R3 в R2
      32'd008 : out <= {OP_J, 26'd3};                          // Прыгнуть на инструкию №3
      default: out <= 0;
    endcase
  end
endmodule


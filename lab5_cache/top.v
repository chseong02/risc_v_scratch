// Do not submit this file.
`include "cpu.v"

module top(input reset,
           input clk,
           output is_halted,
           output [31:0] print_reg [0:31],
           output [31:0] hit_stack,
           output [31:0] mem_access_all);

  cpu cpu(
    .reset(reset), 
    .clk(clk),
    .is_halted(is_halted),
    .print_reg(print_reg),
    .print_hit_stack(hit_stack),
    .print_mem_access_all(mem_access_all)
  );

endmodule

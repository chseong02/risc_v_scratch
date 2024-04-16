`include "opcodes.v"

module control_unit(
   input clk,
   input reset,
   input [3:0] state_in,
   input [6:0] opcode,
   output reg pc_write,
   output reg pc_write_cond,
   output reg i_or_d,
   output reg mem_read,
   output reg mem_write,
   output reg ir_write,
   output reg aluout_write,
   output reg mem_to_reg,
   output reg pc_source,
   output reg [1:0] alu_op,
   output reg [1:0] alu_src_b,
   output reg alu_src_a,
   output reg reg_write,
   output reg [3:0] state_out,
   output reg is_ecall
);
    
   reg [3:0] state;

   always @(posedge clk)
      begin
      if (reset) begin
         state_out <= 4'd0;
      end
      else begin
         case (state_in)
            4'd0:
               state_out <= 4'd1;
            4'd1:
               case (opcode)
                  `LOAD,
                  `STORE: state_out <= 4'd2;
                  `ARITHMETIC: state_out <= 4'd6;
                  `BRANCH: state_out <= 4'd8;
                  // state: 4'd10
                  `JAL: state_out <= 4'd13;
                  // state: 4'd11
                  `JALR: state_out <= 4'd12;
                  `ARITHMETIC_IMM: state_out <= 4'd9;
                  `ECALL: state_out <= 4'd0;
                  default: state_out <= 4'd0;
               endcase
            4'd2:
               case (opcode)
                  `LOAD: state_out <=4'd3;
                  `STORE: state_out <= 4'd5;
                  default: state_out <= 4'd0;
               endcase
            4'd3:
               state_out <= 4'd4;
            4'd4:
               state_out <= 4'd0;
            4'd5:
               state_out <= 4'd0;
            4'd6:
               state_out <= 4'd7;
            4'd7:
               state_out <= 4'd0;
            4'd8:
               state_out <= 4'd0;
            4'd9:
               state_out <= 4'd7;
            4'd12:
               state_out <= 4'd13;   
            4'd13:
               state_out <= 4'd0;
            default:
               state_out <= 4'd0;
         endcase
      end
   end

   always @(*) begin
      pc_write = 1'b0;
      pc_write_cond = 1'b0;
      i_or_d = 1'b0;
      mem_read = 1'b0;
      mem_write = 1'b0;
      ir_write = 1'b0;
      mem_to_reg = 1'b0;
      pc_source = 1'b0;
      alu_op = 2'b00;
      alu_src_b = 2'b00;
      alu_src_a = 1'b0;
      reg_write = 1'b0;
      is_ecall = 1'b0;
      aluout_write = 1'b1;

      if(opcode == `JAL && state_in == 4'd1) begin
         state = 4'd10;
      end
      else if(opcode == `JALR && state_in == 4'd1) begin
         state = 4'd11;
      end
      else begin
         state = state_in;
      end

      if(reset != 1'b1) begin
         pc_write = state == 4'd1 || state == 4'd10 || state == 4'd12;
         pc_write_cond = state == 4'd8;
         i_or_d =  state == 4'd3 || state == 4'd5;
         mem_read = state == 4'd0 || state == 4'd3;
         mem_write = state == 4'd5;
         ir_write = state == 4'd0;
         aluout_write = state != 4'd10 && state != 4'd11 && state != 4'd12;
         mem_to_reg = state == 4'd4;
         pc_source = state == 4'd1 || state == 4'd8;
         if(state == 4'd8) begin
            alu_op = 2'b01;
         end
         else if(state == 4'd6 || state == 4'd9) begin
            alu_op = 2'b10;
         end
         if(state == 4'd0) begin
            alu_src_b = 2'b01;
         end
         else if(state == 4'd1 || state == 4'd2 || state == 4'd9 || state == 4'd10 || state == 4'd12) begin
            alu_src_b=2'b10;
         end
         alu_src_a = state == 4'd2 || state == 4'd6 || state == 4'd8 || state == 4'd9 || state == 4'd12;
         reg_write = state == 4'd4 || state == 4'd7 || state == 4'd13;
         is_ecall = opcode == `ECALL;
      end
   end
endmodule

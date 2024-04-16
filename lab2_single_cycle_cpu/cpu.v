// Submit this file with other files you created.
// Do not touch port declarations of the module 'cpu'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,                     // positive reset signal
           input clk,                       // clock signal
           output is_halted,                // Whehther to finish simulation
           output [31:0] print_reg [0:31]); // TO PRINT REGISTER VALUES IN TESTBENCH (YOU SHOULD NOT USE THIS)
  /***** Wire declarations *****/
  wire [31:0] current_pc;
  wire [31:0] next_pc;
  wire [31:0] default_next_pc;
  wire [31:0] instruction;
  wire [6:0] opcode; 
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [31:0] full_immediate;
  wire [31:0] immediate_data;

  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] rd_din;
  wire [31:0] imm_gen_out;

  wire [3:0] alu_op; 

  wire alu_bcond;

  wire [31:0] alu_result;

  wire [31:0] mem_dout;


  wire is_jal;
  wire is_jalr;
  wire branch;
  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable;
  wire pc_to_reg;
  wire is_ecall;

  wire branch_possible;

  wire is_x17_10;

  wire [31:0] pc_immediate_sum;
  wire [31:0] pc_src1;
  wire is_pc_src1;

  wire [31:0] data_candidate;
  

  /***** Register declarations *****/
  reg [31:0] four = 32'd4;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  instruction_memory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(instruction)     // output
  );

  instruction_decoder decoder(
    .instruction(instruction),
    .opcode(opcode),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .full_instruction(full_immediate)
  );

  // ---------- Register File ----------
  register_file reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (rs1),          // input
    .rs2 (rs2),          // input
    .rd (rd),           // input
    .rd_din (rd_din),       // input
    .write_enable (write_enable), // input
    .is_x17_10 (is_x17_10),    // output
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),     // output
    .print_reg (print_reg)  //DO NOT TOUCH THIS
  );


  // ---------- Control Unit ----------
  control_unit ctrl_unit (
    .part_of_inst(opcode),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),  // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .part_of_inst(full_immediate),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .part30_of_inst(full_immediate[30]),  // input
    .part14_12_of_inst(full_immediate[14:12]),
    .part6_0_of_inst(full_immediate[6:0]),
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(alu_op),      // input
    .alu_in_1(rs1_dout),    // input  
    .alu_in_2(immediate_data),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)    // output
  );

  // ---------- Data Memory ----------
  data_memory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_result),       // input
    .din (rs2_dout),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (mem_dout)        // output
  );


  // ---------- Mux ----------
  mux2_1 pc_to_reg_mux(
    .in_0(data_candidate),
    .in_1(default_next_pc),
    .cond(pc_to_reg),
    .out(rd_din)
  );

  mux2_1 alu_src_mux(
    .in_0(rs2_dout),
    .in_1(imm_gen_out),
    .cond(alu_src),
    .out(immediate_data)
  );

  mux2_1 is_pc_src1_mux(
    .in_0(default_next_pc),
    .in_1(pc_immediate_sum),
    .cond(is_pc_src1),
    .out(pc_src1)
  );

  mux2_1 is_pc_src2_mux(
    .in_0(pc_src1),
    .in_1(alu_result),
    .cond(is_jalr),
    .out(next_pc)
  );
  
  mux2_1 mem_to_reg_mux(
    .in_0(alu_result),
    .in_1(mem_dout),
    .cond(mem_to_reg),
    .out(data_candidate)
  );

  // ---------- Adder ----------
  adder adder_4(
    .in_1(current_pc),
    .in_2(four),
    .out(default_next_pc)
  );

  adder adder_pc_immediate(
    .in_1(current_pc),
    .in_2(imm_gen_out),
    .out(pc_immediate_sum)
  );


  // ---------- And ----------
  and_module and_branch_bcond(
    .in_1(branch),
    .in_2(alu_bcond),
    .out(branch_possible)
  );

  // ---------- Or ----------
  or_module or_jal_branch_possible(
    .in_1(is_jal),
    .in_2(branch_possible),
    .out(is_pc_src1)
  );

  // ---------- Halt Unit ----------
  halt_unit halt_unit(
    .is_ecall(is_ecall),
    .is_x17_10(is_x17_10),
    .is_halted(is_halted)
  );
endmodule

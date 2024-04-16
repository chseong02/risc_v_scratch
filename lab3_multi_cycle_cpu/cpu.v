// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted,
           output [31:0]print_reg[0:31]
           ); // Whehther to finish simulation
  /***** Wire declarations *****/
  wire pc_write_cond;
  wire [31:0] current_pc;
  wire [31:0] next_pc;

  wire [6:0] opcode;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [31:0] full_instruction;
  wire [31:0] full_immediate;
  wire [31:0] rd_din;
  

  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire is_x17_10;

  wire [31:0] mem_addr;
  wire [31:0] mem_din;
  wire [31:0] mem_out;

  wire [3:0] alu_operation;

  wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;
  wire [31:0] alu_result;
  wire alu_bcond;

  wire is_ecall;
  wire pc_write;
  wire i_or_d;
  wire mem_read;
  wire mem_write;
  wire mem_to_reg;
  wire ir_write;
  wire aluout_write;
  wire pc_source;
  wire [1:0] alu_op;
  wire alu_src_a;
  wire [1:0] alu_src_b;
  wire reg_write;
  
  wire pc_update_cond;
  wire pc_branch_cond;

  wire [3:0] state_connect;

  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  conditional_register pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .cond(pc_update_cond),
    .in(next_pc),     // inputS
    .out(current_pc)   // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(rs1),          // input
    .rs2(rs2),          // input
    .rd(rd),           // input
    .rd_din(rd_din),       // input
    .write_enable(reg_write),    // input
    .is_x17_10(is_x17_10),
    .rs1_dout(rs1_dout),     // output
    .rs2_dout(rs2_dout),      // output
    .print_reg(print_reg)     // output (TO PRINT REGISTER VALUES IN TESTBENCH)
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(mem_addr),         // input
    .din(B),          // input
    .mem_read(mem_read),     // input
    .mem_write(mem_write),    // input
    .dout(mem_out)          // output
  );

  // ---------- Control Unit ----------
  control_unit ctrl_unit(
    .clk(clk),
    .reset(reset),
    .state_in(state_connect),
    .opcode(opcode),
    .pc_write_cond(pc_write_cond),
    .pc_write(pc_write),
    .i_or_d(i_or_d),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .ir_write(ir_write),
    .aluout_write(aluout_write),
    .pc_source(pc_source),
    .alu_op(alu_op),
    .alu_src_a(alu_src_a),
    .alu_src_b(alu_src_b),
    .reg_write(reg_write),
    .state_out(state_connect),  
    .is_ecall(is_ecall)
  );

  // ---------- Immediate Generator ----------
  immediate_generator immediate_generator(
    .part_of_inst(full_instruction),  // input
    .imm_gen_out(full_immediate)    // output
  );

  // ---------- ALU ----------
  alu alu(
    .alu_operation(alu_operation),      // input
    .alu_in_1(alu_in_1),    // input  
    .alu_in_2(alu_in_2),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)   // output
  );

  alu_control_unit alu_control_unit(
    .part30_of_inst(full_instruction[30]),
    .part14_12_of_inst(full_instruction[14:12]),
    .part6_0_of_inst(full_instruction[6:0]),
    .alu_op(alu_op),
    .alu_operation(alu_operation)
  );


  // ---------- Register ----------
  conditional_register instruction_register(
    .reset(reset),
    .clk(clk),
    .cond(ir_write),
    .in(mem_out),
    .out(IR)
  );

  instruction_decoder decoder(
    .instruction(IR),
    .opcode(opcode),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .full_instruction(full_instruction)
  );

  single_register memory_data_register(
    .reset(reset),
    .clk(clk),
    .in(mem_out),
    .out(MDR)
  );
  
  single_register a_register(
    .reset(reset),
    .clk(clk),
    .in(rs1_dout),
    .out(A)
  );

  single_register b_register(
    .reset(reset),
    .clk(clk),
    .in(rs2_dout),
    .out(B)
  );

  conditional_register aluout(
    .reset(reset),
    .clk(clk),
    .cond(aluout_write),
    .in(alu_result),
    .out(ALUOut)
  );

  // ---------- MUX ----------
  mux2_1 i_or_d_mux(
    .in_0(current_pc),
    .in_1(ALUOut),
    .cond(i_or_d),
    .out(mem_addr)
  );

  mux2_1 mem_to_reg_mux(
    .in_0(ALUOut),
    .in_1(MDR),
    .cond(mem_to_reg),
    .out(rd_din)
  );

  mux2_1 alu_src_a_mux(
    .in_0(current_pc),
    .in_1(A),
    .cond(alu_src_a),
    .out(alu_in_1)
  );

  mux4_1 alu_src_b_mux(
    .in_0(B),
    .in_1(32'b100),
    .in_2(full_immediate),
    .in_3(32'b0),
    .cond(alu_src_b),
    .out(alu_in_2)
  );

  mux2_1 pc_source_mux(
    .in_0(alu_result),
    .in_1(ALUOut),
    .cond(pc_source),
    .out(next_pc)
  );

  // ---------- Gate ----------
  and_module and_module(
    .in_1(alu_bcond),
    .in_2(pc_write_cond),
    .out(pc_branch_cond)
  );

  or_module or_module(
    .in_1(pc_branch_cond),
    .in_2(pc_write),
    .out(pc_update_cond)
  );

  // ---------- Halt Unit ----------
  halt_unit halt_unit(
    .is_ecall(is_ecall),
    .is_x17_10(is_x17_10),
    .is_halted(is_halted)
  );

endmodule

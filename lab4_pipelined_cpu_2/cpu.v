// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted, // Whehther to finish simulation
           output [31:0]print_reg[0:31]); // Whehther to finish simulation
  /***** Wire declarations *****/
  wire pc_update_cond;
  wire [31:0] pc_in;
  wire [31:0] pc_out;
  wire is_flush;
  wire [31:0] imem_dout;

  wire [4:0] bhsr_state_out;
  wire [4:0] pht_idx;
  wire pht_is_taken;
  wire btb_is_valid;
  wire [24:0] btb_tag;
  wire [31:0] btb_target_pc;

  wire [6:0] opcode;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire is_sub;
  wire [2:0] funct3;
  wire [31:0] full_instruction;
  wire [31:0] immediate;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  wire [4:0] rs1_choice;
  wire IF_ID_write;
  wire is_nop;

  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire reg_write;
  wire [1:0] alu_op;
  wire is_ecall;
  wire is_jal;
  wire is_jalr;
  wire branch;
  wire is_jump_or_branch;
  wire pc_to_reg;

  wire is_halted_ctrl;

  wire [3:0] alu_operation;
  wire [31:0] forwarded_alu_in_1;
  wire [31:0] forwarded_or_imm_alu_in_2;

  wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;

  wire [31:0] pc_adder_in_1;
  wire branch_taken;
  wire branch_is_jal;
  wire use_changed_pc;

  wire [31:0] calculated_pc;
  wire alu_bcond;
  wire [31:0] alu_result;

  wire [31:0] alu_src_mux_out;

  wire [1:0] forward_A;
  wire [1:0] forward_B;

  wire [31:0] dmem_dout;

  wire [31:0] reg_write_data;

  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;           // will be used in ID stage
  reg [31:0] IF_ID_pc;
  reg [31:0] IF_ID_predict_pc;
  reg IF_ID_is_valid;
  reg [4:0] IF_ID_pht_idx;

  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg [1:0] ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  reg ID_EX_is_ecall;
  reg ID_EX_is_jal;
  reg ID_EX_is_jalr;
  reg ID_EX_branch;
  reg ID_EX_pc_to_reg;
  reg ID_EX_is_jump_or_branch;

  // From others
  reg [31:0] ID_EX_pc;
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  reg [31:0] ID_EX_imm;
  reg ID_EX_ALU_ctrl_unit_input;
  reg ID_EX_is_sub;
  reg [2:0] ID_EX_funct3;
  reg [6:0] ID_EX_opcode;
  reg [4:0] ID_EX_rd;
  reg [4:0] ID_EX_rs_1;
  reg [4:0] ID_EX_rs_2;
  reg [31:0] ID_EX_predict_pc;
  reg ID_EX_is_valid;
  reg [4:0] ID_EX_pht_idx;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  reg EX_MEM_is_halted;
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0] EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  reg MEM_WB_is_halted;
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd;
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  ConditionalRegister pc(
    .reset(reset),         // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),             // input
    .in(pc_in),            // input
    .cond(pc_update_cond), // input
    .out(pc_out)           // output
  );
  
  // ---------- Branch Prediction ----------
  BranchHistoryShiftRegister branch_history_shift_register(
    .reset(reset),
    .clk(clk),
    .is_taken(use_changed_pc),
    .is_jump_or_branch(ID_EX_is_jump_or_branch),
    .state_out(bhsr_state_out)
  );

  XorModule #(.data_width(5)) pht_xor(
    .in_0(pc_out[6:2]),
    .in_1(bhsr_state_out),
    .out(pht_idx)
  );

  PatternHistoryTable pattern_history_table(
    .reset(reset),
    .clk(clk),
    .predict_index(pht_idx),
    .real_index(ID_EX_pht_idx),
    .real_is_jump_or_branch(ID_EX_is_jump_or_branch),
    .real_is_taken(use_changed_pc),
    .predict_is_taken(pht_is_taken)
  );

  BranchTargetBuffer branch_target_buffer(
    .reset(reset),
    .clk(clk),
    .read_index(pc_out[6:2]),
    .update_index(ID_EX_pc[6:2]),
    .update_tag(ID_EX_pc[31:7]),
    .update_target_pc(calculated_pc),
    .update_is_valid(ID_EX_is_valid),
    .update_is_jump_or_branch(ID_EX_is_jump_or_branch),
    .is_valid(btb_is_valid),
    .tag(btb_tag),
    .target_pc(btb_target_pc)
  );

  NextPcSelecter next_pc_selecter(
    .tag(pc_out[31:7]),
    .btb_tag(btb_tag),
    .btb_is_valid(btb_is_valid),
    .predict_is_taken(pht_is_taken),
    .btb_target_pc(btb_target_pc),
    .now_pc(pc_out),
    .ex_predict_pc(ID_EX_predict_pc),
    .ex_inst_pc(ID_EX_pc),
    .ex_taken_pc(calculated_pc),
    .ex_is_valid(ID_EX_is_valid),
    .ex_is_taken(use_changed_pc),
    .next_pc(pc_in),
    .is_flush(is_flush)
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),       // input
    .addr(pc_out),   // input
    .dout(imem_dout) // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset||is_flush) begin
      IF_ID_inst <= 32'b0;
      IF_ID_pc <= 32'b0;
      IF_ID_predict_pc <= 32'b0;
      IF_ID_is_valid <= 1'b0;
      IF_ID_pht_idx <= 5'b0;
    end
    else if(IF_ID_write == 1'b1) begin
      IF_ID_inst <= imem_dout;
      IF_ID_pc <= pc_out;
      IF_ID_predict_pc <= pc_in;
      IF_ID_is_valid <= 1'b1;
      IF_ID_pht_idx <= pht_idx;
    end
  end

  // ---------- Instruction Decoder ----------
  InstructionDecoder decoder(
    .instruction(IF_ID_inst),
    .opcode(opcode),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .is_sub(is_sub),
    .funct3(funct3),
    .full_instruction(full_instruction)
  );

  // ---------- Register File ----------
  Mux2_1 #(.data_width(5)) is_ecall_mux (
    .in_0(rs1),
    .in_1(5'd17),
    .cond(is_ecall),
    .out(rs1_choice)
  );

  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (rs1_choice),          // input
    .rs2 (rs2),          // input
    .rd (MEM_WB_rd),           // input
    .rd_din (reg_write_data),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),      // output
    .print_reg(print_reg)
  );

  // ---------- Hazard Detection Unit ----------
  HazardDetectionUnit hazard_detection_unit(
    .rs1(rs1_choice),
    .rs2(rs2),
    .ID_EX_mem_read(ID_EX_mem_read),
    .ID_EX_rd(ID_EX_rd),
    .pc_write(pc_update_cond),
    .IF_ID_write(IF_ID_write),
    .is_nop(is_nop)
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(opcode),  // input
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .branch(branch),
    .is_jump_or_branch(is_jump_or_branch),
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .reg_write(reg_write),  // output
    .alu_op(alu_op),        // output
    .is_ecall(is_ecall),       // output (ecall inst)
    .pc_to_reg(pc_to_reg)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(full_instruction),  // input
    .imm_gen_out(immediate)    // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset || is_nop || is_flush) begin
      ID_EX_mem_read <= 1'b0;
      ID_EX_mem_to_reg <= 1'b0;
      ID_EX_mem_write <= 1'b0;
      ID_EX_alu_src <= 1'b0;
      ID_EX_reg_write <= 1'b0;
      ID_EX_alu_op <= 2'b00;
      ID_EX_is_ecall <= 1'b0;
      ID_EX_is_jal <= 1'b0;
      ID_EX_is_jalr <= 1'b0;
      ID_EX_branch <= 1'b0;
      ID_EX_pc_to_reg <= 1'b0;
      ID_EX_is_jump_or_branch <= 1'b0;

      ID_EX_rs1_data <= 32'b0;
      ID_EX_rs2_data <= 32'b0;
      ID_EX_imm <= 32'b0;
      ID_EX_is_sub <= 1'b0;
      ID_EX_funct3 <= 3'b0;
      ID_EX_opcode <= 7'b0;
      ID_EX_rd <= 5'b0;
      ID_EX_rs_1 <= 5'b0;
      ID_EX_rs_2 <= 5'b0;
      ID_EX_pc <= 32'b0;
      ID_EX_predict_pc <= 32'b0;
      ID_EX_is_valid <= 1'b0;
      ID_EX_pht_idx <= 5'b0;
    end
    else begin
      ID_EX_mem_read <= mem_read;
      ID_EX_mem_to_reg <= mem_to_reg;
      ID_EX_mem_write <= mem_write;
      ID_EX_alu_src <= alu_src;
      ID_EX_reg_write <= reg_write;
      ID_EX_alu_op <= alu_op;
      ID_EX_is_ecall <= is_ecall;
      ID_EX_is_jal <= is_jal;
      ID_EX_is_jalr <= is_jalr;
      ID_EX_branch <= branch;
      ID_EX_pc_to_reg <= pc_to_reg;
      ID_EX_is_jump_or_branch <= is_jump_or_branch;
      
      ID_EX_rs1_data <= rs1_dout;
      ID_EX_rs2_data <= rs2_dout;
      ID_EX_imm <= immediate;
      ID_EX_is_sub <= is_sub;
      ID_EX_funct3 <= funct3;
      ID_EX_opcode <= opcode;
      ID_EX_rd <= rd;
      ID_EX_rs_1 <= rs1_choice;
      ID_EX_rs_2 <= rs2;
      ID_EX_pc <= IF_ID_pc;
      ID_EX_predict_pc <= IF_ID_predict_pc;
      ID_EX_is_valid <= IF_ID_is_valid;
      ID_EX_pht_idx <= IF_ID_pht_idx;
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part30_of_inst(ID_EX_is_sub),
    .part14_12_of_inst(ID_EX_funct3),
    .part6_0_of_inst(ID_EX_opcode),// input
    .alu_op(ID_EX_alu_op),        
    .alu_operation(alu_operation) // output
  );

  // ---------- ALU ----------
  Mux2_1 alu_src_mux(
    .in_0(alu_src_mux_out),
    .in_1(ID_EX_imm),
    .cond(ID_EX_alu_src),
    .out(forwarded_or_imm_alu_in_2)
  );

  Mux2_1 alu_in_2_pc_to_reg_mux(
    .in_0(forwarded_or_imm_alu_in_2),
    .in_1(32'd4),
    .cond(ID_EX_pc_to_reg),
    .out(alu_in_2)
  );

  alu alu (
    .alu_operation(alu_operation),      // input
    .alu_in_1(alu_in_1),    // input  
    .alu_in_2(alu_in_2),    // input
    .alu_bcond(alu_bcond),
    .alu_result(alu_result)  // output
  );

  ForwardingUnit forwarding_unit(
    .rs_1_EX(ID_EX_rs_1),
    .rs_2_EX(ID_EX_rs_2),
    .rd_MEM(EX_MEM_rd),
    .rd_WB(MEM_WB_rd),
    .RegWrite_MEM(EX_MEM_reg_write),
    .RegWrite_WB(MEM_WB_reg_write),
    .forward_A(forward_A),
    .forward_B(forward_B)
  );

  Mux4_1 forward_A_mux3_1(
    .in_0(ID_EX_rs1_data),
    .in_1(EX_MEM_alu_out),
    .in_2(reg_write_data),
    .in_3(0),
    .cond(forward_A),
    .out(forwarded_alu_in_1)
  );

  Mux2_1 alu_in_1_pc_to_reg_mux(
    .in_0(forwarded_alu_in_1),
    .in_1(ID_EX_pc),
    .cond(ID_EX_pc_to_reg),
    .out(alu_in_1)
  );

  Mux4_1 forward_B_mux3_1(
    .in_0(ID_EX_rs2_data),
    .in_1(EX_MEM_alu_out),
    .in_2(reg_write_data),
    .in_3(0),
    .cond(forward_B),
    .out(alu_src_mux_out)
  );

  IsHaltedControlUnit is_halted_ctrl_unit (
    .is_ecall(ID_EX_is_ecall),
    .x17_data(alu_in_1),
    .is_halted(is_halted_ctrl)
  );

  // pc related
  Mux2_1 pc_or_reg_mux(
    .in_0(ID_EX_pc),
    .in_1(forwarded_alu_in_1),
    .cond(ID_EX_is_jalr),
    .out(pc_adder_in_1)
  );

  Adder pc_immediate_adder(
    .in_1(pc_adder_in_1),
    .in_2(ID_EX_imm),
    .out(calculated_pc)
  );

  AndModule branch_taken_and(
    .in_1(ID_EX_branch),
    .in_2(alu_bcond),
    .out(branch_taken)
  );

  OrModule branch_is_jal_or(
    .in_1(branch_taken),
    .in_2(ID_EX_is_jal),
    .out(branch_is_jal)
  );

  OrModule branch_is_jalr_or(
    .in_1(branch_is_jal),
    .in_2(ID_EX_is_jalr),
    .out(use_changed_pc)
  );

  
  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_mem_read <= 1'b0;
      EX_MEM_mem_to_reg <= 1'b0;
      EX_MEM_mem_write <= 1'b0;
      EX_MEM_reg_write <= 1'b0;
      EX_MEM_is_halted <= 1'b0;

      EX_MEM_rd <= 5'b0;
      EX_MEM_alu_out <= 32'b0;
      EX_MEM_dmem_data <= 32'b0;
    end
    else begin
      EX_MEM_mem_read <= ID_EX_mem_read;
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
      EX_MEM_mem_write <= ID_EX_mem_write;
      EX_MEM_reg_write <= ID_EX_reg_write;
      EX_MEM_is_halted <= is_halted_ctrl;

      EX_MEM_rd <= ID_EX_rd;
      EX_MEM_alu_out <= alu_result;
      EX_MEM_dmem_data <= alu_src_mux_out;
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (EX_MEM_alu_out),       // input
    .din (EX_MEM_dmem_data),        // input
    .mem_read (EX_MEM_mem_read),   // input
    .mem_write (EX_MEM_mem_write),  // input
    .dout (dmem_dout)        // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      MEM_WB_mem_to_reg <= 1'b0;
      MEM_WB_reg_write <= 1'b0;
      MEM_WB_is_halted <= 1'b0;

      MEM_WB_mem_to_reg_src_1 <= 32'b0;
      MEM_WB_mem_to_reg_src_2 <= 32'b0;
      MEM_WB_rd <= 5'b0;
    end
    else begin
      MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
      MEM_WB_reg_write <= EX_MEM_reg_write;
      MEM_WB_is_halted <= EX_MEM_is_halted;
      
      MEM_WB_mem_to_reg_src_1 <= EX_MEM_alu_out;
      MEM_WB_mem_to_reg_src_2 <= dmem_dout;
      MEM_WB_rd <= EX_MEM_rd;
    end
  end

  // ---------- Write Back ----------
  Mux2_1 mem_to_reg_mux(
    .in_0(MEM_WB_mem_to_reg_src_1),
    .in_1(MEM_WB_mem_to_reg_src_2),
    .cond(MEM_WB_mem_to_reg),
    .out(reg_write_data)
  );

  HaltUnit halt_unit(
    .clk(clk),
    .is_halted_ctrl(MEM_WB_is_halted),
    .is_halted(is_halted)
  );
  
endmodule

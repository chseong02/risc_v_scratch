`include "opcodes.v"

module JumpBranchCheckUnit (
    part_of_inst,  // input
    is_jump_or_branch    // output
);
    input [6:0] part_of_inst;
    output reg is_jump_or_branch;

    always @(*) begin
        is_jump_or_branch = part_of_inst == `JAL || part_of_inst == `JALR 
          || part_of_inst == `BRANCH;
    end

endmodule

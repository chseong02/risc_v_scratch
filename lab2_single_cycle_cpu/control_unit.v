`include "opcodes.v"

module control_unit (
    part_of_inst,  // input
    is_jal,        // output
    is_jalr,       // output
    branch,        // output
    mem_read,      // output
    mem_to_reg,    // output
    mem_write,     // output
    alu_src,       // output
    write_enable,  // output
    pc_to_reg,     // output
    is_ecall       // output
);
    input [6:0] part_of_inst;
    output reg is_jal;
    output reg is_jalr;
    output reg branch;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg alu_src;
    output reg write_enable;
    output reg pc_to_reg;
    output reg is_ecall;

    always @(*) begin
        is_jal = part_of_inst == `JAL;
        is_jalr = part_of_inst == `JALR;
        branch = part_of_inst == `BRANCH;
        mem_read = part_of_inst == `LOAD;
        mem_to_reg = part_of_inst == `LOAD;
        mem_write = part_of_inst == `STORE;
        alu_src = part_of_inst != `ARITHMETIC && part_of_inst != `BRANCH;
        write_enable = part_of_inst != `STORE && part_of_inst != `BRANCH && part_of_inst != `ECALL;
        pc_to_reg = part_of_inst == `JAL || part_of_inst == `JALR;
        is_ecall = part_of_inst == `ECALL;
    end

endmodule

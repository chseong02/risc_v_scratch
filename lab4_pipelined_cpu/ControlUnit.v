`include "opcodes.v"

module ControlUnit (
    part_of_inst,  // input
    mem_read,      // output
    mem_to_reg,    // output
    mem_write,     // output
    write_enable,  // output
    is_ecall       // output
);
    input [6:0] part_of_inst;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg write_enable;
    output reg is_ecall;

    always @(*) begin
        mem_read = part_of_inst == `LOAD;
        mem_to_reg = part_of_inst == `LOAD;
        mem_write = part_of_inst == `STORE;
        write_enable = part_of_inst != `STORE && part_of_inst != `BRANCH && part_of_inst != `ECALL;
        pc_to_reg = part_of_inst == `JAL || part_of_inst == `JALR;
        is_ecall = part_of_inst == `ECALL;
    end

endmodule

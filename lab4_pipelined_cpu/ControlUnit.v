`include "opcodes.v"

module ControlUnit (
    part_of_inst,  // input
    mem_read,      // output
    mem_to_reg,    // output
    mem_write,     // output
    alu_src,       // output
    write_enable,  // output
    alu_op,
    is_ecall       // output
);
    input [6:0] part_of_inst;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg alu_src;
    output reg write_enable;
    output reg [1:0] alu_op;
    output reg is_ecall;

    always @(*) begin
        mem_read = part_of_inst == `LOAD;
        mem_to_reg = part_of_inst == `LOAD;
        mem_write = part_of_inst == `STORE;
        alu_src = part_of_inst != `ARITHMETIC && part_of_inst != `BRANCH;
        write_enable = part_of_inst != `STORE && part_of_inst != `BRANCH && part_of_inst != `ECALL;
        if(part_of_inst == `BRANCH) begin
            alu_op = 2'b01;
        end
        else if(part_of_inst == `ARITHMETIC || part_of_inst == `ARITHMETIC_IMM) begin
            alu_op = 2'b10;
        end
        else begin
            alu_op = 2'b00;
        end
        pc_to_reg = part_of_inst == `JAL || part_of_inst == `JALR;
        is_ecall = part_of_inst == `ECALL;
    end

endmodule

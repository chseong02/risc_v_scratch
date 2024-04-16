`include "constants.v"
`include "opcodes.v"

module alu (
    alu_op,         // input
    alu_in_1,       // input
    alu_in_2,       // input
    alu_bcond,      // output
    alu_result      // output
);

    input [`kDataWidth - 1 : 0] alu_in_1;
    input [`kDataWidth - 1 : 0] alu_in_2; 
    input [`kAluFuncCodeLength - 1 : 0] alu_op;
    output reg alu_bcond;
    output reg [`kDataWidth - 1 : 0] alu_result;

    always @(*) begin
        alu_bcond = 0;
        alu_result = alu_in_1;

        case (alu_op)
            `FUNC_ADD: alu_result = alu_in_1 + alu_in_2;
            `FUNC_SUB: alu_result = alu_in_1 - alu_in_2;
            `FUNC_EQ:  alu_bcond = alu_in_1 == alu_in_2;
            `FUNC_NEQ: alu_bcond = alu_in_1 != alu_in_2;
            `FUNC_AND: alu_result = alu_in_1 & alu_in_2;
            `FUNC_OR: alu_result = alu_in_1 | alu_in_2;
            `FUNC_XOR: alu_result = alu_in_1 ^ alu_in_2;
            `FUNC_LT: alu_bcond = alu_in_1 < alu_in_2;
            `FUNC_GE: alu_bcond = alu_in_1 >= alu_in_2;
            `FUNC_LLS: alu_result = alu_in_1 << alu_in_2;
            `FUNC_LRS: alu_result = alu_in_1 >> alu_in_2;
            `FUNC_ZERO: alu_result = `kDataWidth'b0;
            default: alu_result = `kDataWidth'b0;
        endcase
    end

endmodule


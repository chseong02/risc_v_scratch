`include "constants.v"
`include "opcodes.v"

module alu (
    alu_operation,  // input
    alu_in_1,       // input
    alu_in_2,       // input
    alu_result      // output
);

    input [`kDataWidth - 1 : 0] alu_in_1;
    input [`kDataWidth - 1 : 0] alu_in_2; 
    input [`kAluFuncCodeLength - 1 : 0] alu_operation;
    output reg [`kDataWidth - 1 : 0] alu_result;

    always @(*) begin
        alu_result = alu_in_1;

        case (alu_operation)
            `FUNC_ADD: alu_result = alu_in_1 + alu_in_2;
            `FUNC_SUB: alu_result = alu_in_1 - alu_in_2;
            `FUNC_AND: alu_result = alu_in_1 & alu_in_2;
            `FUNC_OR: alu_result = alu_in_1 | alu_in_2;
            `FUNC_XOR: alu_result = alu_in_1 ^ alu_in_2;
            `FUNC_LLS: alu_result = alu_in_1 << alu_in_2;
            `FUNC_LRS: alu_result = alu_in_1 >> alu_in_2;
            `FUNC_ZERO: alu_result = `kDataWidth'b0;
            default: alu_result = `kDataWidth'b0;
        endcase
    end

endmodule


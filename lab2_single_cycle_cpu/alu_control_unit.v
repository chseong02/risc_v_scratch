`include "constants.v"
`include "opcodes.v"

module alu_control_unit (
    part30_of_inst,     // input
    part14_12_of_inst,  // input
    part6_0_of_inst,    // input
    alu_op              // output
);

    input part30_of_inst;
    input [2:0] part14_12_of_inst;
    input [6:0] part6_0_of_inst;
    output reg [`kAluFuncCodeLength-1:0] alu_op; 
    
    always @(*) begin
        case (part6_0_of_inst)
            `JAL,
            `JALR,
            `LOAD,
            `STORE: alu_op = `FUNC_ADD;
            `ARITHMETIC_IMM:
                case (part14_12_of_inst)
                    `FUNCT3_ADD: alu_op = `FUNC_ADD;
                    `FUNCT3_SLL: alu_op = `FUNC_LLS;
                    `FUNCT3_XOR: alu_op = `FUNC_XOR;
                    `FUNCT3_BGE: alu_op = `FUNC_LRS;
                    `FUNCT3_OR: alu_op = `FUNC_OR;
                    `FUNCT3_AND: alu_op = `FUNC_AND;
                    default: alu_op = `FUNC_ZERO;
                endcase
            `ARITHMETIC:
                case (part14_12_of_inst)
                    `FUNCT3_ADD:
                        case (part30_of_inst)
                            1'b0: alu_op = `FUNC_ADD;
                            1'b1: alu_op = `FUNC_SUB;
                        endcase
                    `FUNCT3_SLL: alu_op = `FUNC_LLS;
                    `FUNCT3_XOR: alu_op = `FUNC_XOR;
                    `FUNCT3_BGE: alu_op = `FUNC_LRS;
                    `FUNCT3_OR: alu_op = `FUNC_OR;
                    `FUNCT3_AND: alu_op = `FUNC_AND;
                    default: alu_op = `FUNC_ZERO;
                endcase
            `BRANCH:
                case (part14_12_of_inst)
                    `FUNCT3_BEQ: alu_op = `FUNC_EQ;
                    `FUNCT3_BNE: alu_op = `FUNC_NEQ;
                    `FUNCT3_BLT: alu_op = `FUNC_LT;
                    `FUNCT3_BGE: alu_op = `FUNC_GE;
                    default: alu_op = `FUNC_ZERO;
                endcase
            default: alu_op = `FUNC_ZERO;
        endcase
    end

endmodule

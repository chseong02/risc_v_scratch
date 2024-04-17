`include "constants.v"
`include "opcodes.v"

module AluControlUnit (
    part30_of_inst,     // input
    part14_12_of_inst,  // input
    part6_0_of_inst,    // input
    alu_op,             // input
    alu_operation       // output
);

    input part30_of_inst;
    input [2:0] part14_12_of_inst;
    input [6:0] part6_0_of_inst;
    input [1:0] alu_op;
    output reg [`kAluFuncCodeLength-1:0] alu_operation; 
    
    always @(*) begin
        case (alu_op)
            2'b00: alu_operation = `FUNC_ADD;
            default:
                case (part6_0_of_inst)
                `JAL,
                `JALR,
                `LOAD,
                `STORE: alu_operation = `FUNC_ADD;
                `ARITHMETIC_IMM:
                    case (part14_12_of_inst)
                        `FUNCT3_ADD: alu_operation = `FUNC_ADD;
                        `FUNCT3_SLL: alu_operation = `FUNC_LLS;
                        `FUNCT3_XOR: alu_operation = `FUNC_XOR;
                        `FUNCT3_BGE: alu_operation = `FUNC_LRS;
                        `FUNCT3_OR: alu_operation = `FUNC_OR;
                        `FUNCT3_AND: alu_operation = `FUNC_AND;
                        default: alu_operation = `FUNC_ZERO;
                    endcase
                `ARITHMETIC:
                    case (part14_12_of_inst)
                        `FUNCT3_ADD:
                            case (part30_of_inst)
                                1'b0: alu_operation = `FUNC_ADD;
                                1'b1: alu_operation = `FUNC_SUB;
                            endcase
                        `FUNCT3_SLL: alu_operation = `FUNC_LLS;
                        `FUNCT3_XOR: alu_operation = `FUNC_XOR;
                        `FUNCT3_BGE: alu_operation = `FUNC_LRS;
                        `FUNCT3_OR: alu_operation = `FUNC_OR;
                        `FUNCT3_AND: alu_operation = `FUNC_AND;
                        default: alu_operation = `FUNC_ZERO;
                    endcase
                `BRANCH:
                    case (part14_12_of_inst)
                        `FUNCT3_BEQ: alu_operation = `FUNC_EQ;
                        `FUNCT3_BNE: alu_operation = `FUNC_NEQ;
                        `FUNCT3_BLT: alu_operation = `FUNC_LT;
                        `FUNCT3_BGE: alu_operation = `FUNC_GE;
                        default: alu_operation = `FUNC_ZERO;
                    endcase
                default: alu_operation = `FUNC_ZERO;
            endcase
        endcase

    end

endmodule

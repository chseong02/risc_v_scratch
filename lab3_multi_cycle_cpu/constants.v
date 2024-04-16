// ALU FuncCodes
`define FUNC_ADD    4'b0000
`define FUNC_SUB    4'b0001
`define FUNC_EQ     4'b0010
`define FUNC_NEQ    4'b0011
`define FUNC_AND    4'b0100
`define FUNC_OR     4'b0101
`define FUNC_LT     4'b0110
`define FUNC_GE     4'b0111
`define FUNC_XOR    4'b1000
`define FUNC_LLS    4'b1010
`define FUNC_LRS    4'b1011
`define FUNC_ZERO   4'b1111

`define kDataWidth 32
`define kInstructionWidth 32
`define kAluFuncCodeLength 4

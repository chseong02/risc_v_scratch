`include "constants.v"

module InstructionDecoder (
    instruction,       // input
    opcode,            // output
    rs1,               // output
    rs2,               // output
    rd,                // output
    full_instruction   // output
);

    input [`kInstructionWidth-1:0] instruction;
    output reg [6:0] opcode;
    output reg [4:0] rs1;
    output reg [4:0] rs2;
    output reg [4:0] rd;
    output reg [`kInstructionWidth-1:0] full_instruction;

    always @(*)begin
        opcode = instruction[6:0];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        rd = instruction[11:7];
        full_instruction = instruction;
    end
endmodule

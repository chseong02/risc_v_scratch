`include "constants.v"

module Mux4_1 (
    in_0, // input
    in_1, // input
    in_2, // input
    in_3, // input
    cond, // input
    out   // output
);

    input [`kDataWidth-1:0] in_0;
    input [`kDataWidth-1:0] in_1;
    input [`kDataWidth-1:0] in_2;
    input [`kDataWidth-1:0] in_3;
    input[1:0] cond;
    output reg [`kDataWidth-1:0] out;

    always @(*)begin
        case(cond)
            2'b00: out = in_0;
            2'b01: out = in_1;
            2'b10: out = in_2;
            2'b11: out = in_3;
            default: out = 0;
        endcase
    end
endmodule

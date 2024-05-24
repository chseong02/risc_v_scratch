`include "constants.v"

module Adder(
    in_1,  // input
    in_2,  // input
    out    // output
);
    input [`kDataWidth - 1 : 0] in_1;
    input [`kDataWidth - 1 : 0] in_2;
    output reg [`kDataWidth - 1 : 0] out;

    always @(*) begin
        assign out = in_1 + in_2;
    end

endmodule

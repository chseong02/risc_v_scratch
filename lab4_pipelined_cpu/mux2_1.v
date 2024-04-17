`include "constants.v"

module Mux2_1 (
    in_0, // input
    in_1, // input
    cond, // input
    out   // output
);

    input [`kDataWidth-1:0] in_0;
    input [`kDataWidth-1:0] in_1;
    input cond;
    output reg [`kDataWidth-1:0] out;

    always @(*)begin
        if(cond) begin
            out = in_1;
        end
        else begin
            out = in_0;
        end
    end
endmodule

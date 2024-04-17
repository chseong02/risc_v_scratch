`include "constants.v"

module conditional_register (
    reset,
    clk,
    cond,
    in,
    out
    );

    input reset;
    input clk;
    input cond;
    input [`kDataWidth-1:0] in;
    output reg [`kDataWidth-1:0] out;

    always @(posedge clk) begin
        if (reset) begin
            out <= 32'b0;
        end

        else if(cond) begin
            out <= in;
        end
    end
endmodule

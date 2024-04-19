`include "constants.v"
`include "opcodes.v"

module HaltUnit (
    clk,
    is_halted_ctrl,
    is_halted
);
    input is_halted_ctrl;
    input clk;
    output reg is_halted;

    always @(posedge clk) begin
        is_halted <= is_halted_ctrl;
    end

endmodule


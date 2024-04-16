`include "constants.v"

module pc (
    reset,         // input
    clk,           // input
    next_pc,       // input
    current_pc     // output
);
    input reset;
    input clk;
    input [`kDataWidth - 1 : 0] next_pc;
    output reg [`kDataWidth - 1 : 0] current_pc;

    always @(posedge clk) begin
        if (reset) begin
            current_pc <= `kDataWidth'b0;
        end
        
        else begin
            current_pc <= next_pc;
        end
    end

endmodule


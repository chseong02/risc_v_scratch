`include "constants.v"

module PcFlushControlUnit (
    calculated_pc,
    use_changed_pc,
    not_taken_next_pc,
    is_flush,
    next_pc
);

    input [31:0] calculated_pc;
    input use_changed_pc;
    input [31:0] not_taken_next_pc;
    output reg is_flush;
    output reg [31:0] next_pc;

    always @(*)begin
        next_pc = not_taken_next_pc;
        is_flush = 0;
        if(use_changed_pc && (calculated_pc != not_taken_next_pc - 12)) begin
            is_flush = 1;
            next_pc = calculated_pc;
        end
    end
endmodule

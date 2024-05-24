module BranchHistoryShiftRegister (
    input reset, 
    input clk, 
    input is_taken,
    input is_jump_or_branch,
    output reg [4:0] state_out
);
    reg [4:0] state;

    always @(*) begin
        state_out = state;
    end
    always @(posedge clk) begin
        if(reset) begin
            state <= 5'b00000;
        end
        else if(is_jump_or_branch) begin
            state<= {is_taken,state[4:1]};
        end
    end
endmodule

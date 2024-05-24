module BranchTargetBuffer (
    input reset, 
    input clk, 
    input [4:0] read_index,
    input [4:0] update_index,
    input [24:0] update_tag,
    input [31:0] update_target_pc,
    input update_is_valid,
    input update_is_jump_or_branch,
    output reg is_valid,
    output reg [24:0] tag,
    output reg [31:0] target_pc
);

    reg [24:0] tag_table [0:31];
    reg valid_bit_table [0:31];
    reg [31:0] branch_target_buffer_table [0:31];

    integer i;

    always @(*) begin
        tag = tag_table[read_index];
        target_pc = branch_target_buffer_table[read_index];
        is_valid = valid_bit_table[read_index];
    end

    always @(posedge clk) begin
        if(reset) begin
            for(i = 0 ; i<32; i = i+1)
                tag_table[i] <= 25'b0;
                valid_bit_table[i] <= 1'b0;
                branch_target_buffer_table[i] <= 32'b0;
        end
        else begin
            if(update_is_jump_or_branch) begin
                tag_table [update_index] <= update_tag;
                valid_bit_table[update_index] <= 1;
                branch_target_buffer_table[update_index] <= update_target_pc;
            end
        end
    end
endmodule

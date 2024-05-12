module BranchPredictionCounter (
    input branch_taken,
    input [1:0] input_counter,
    input is_jump_or_branch, // is_jal || is_jalr || is_branch
    output reg [1:0] output_counter
);

    always @(*) begin
        output_counter = input_counter;
        if(is_jump_or_branch) begin
            case(input_counter)
                2'b11:
                    if(branch_taken) output_counter = 2'b11;
                    else output_counter =  2'b10;
            
                2'b10: 
                    if(branch_taken) output_counter = 2'b11;
                    else output_counter =  2'b01;
                
                2'b01: 
                    if(branch_taken) output_counter = 2'b10;
                    else output_counter =  2'b00;
            
                2'b00: 
                    if(branch_taken) output_counter = 2'b01;
                    else output_counter =  2'b00;
                
            endcase
        end
    end
endmodule

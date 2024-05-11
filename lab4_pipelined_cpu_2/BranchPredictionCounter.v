module BranchPredictionCounter (
    input branch_taken,
    input [2:0] input_counter,
    input is_jump_branch, // is_jal || is_jalr || is_branch
    output reg [2:0] output_counter
);

    always @(posedge clk) begin
        if(is_jump_branch){
            case(input_counter)
                2'b11: begin
                    if(branch_taken) input_counter <= 2'b11;
                    else input_counter <=  2'b10;
                end
                2'b10: begin
                    if(branch_taken) input_counter <= 2'b11;
                    else input_counter <=  2'b01;
                end
                2'b01: begin
                    if(branch_taken) input_counter <= 2'b10;
                    else input_counter <=  2'b00;
                end
                2'b00: begin
                    if(branch_taken) input_counter <= 2'b01;
                    else input_counter <=  2'b00;
                end
            endcase
        }
    end
endmodule
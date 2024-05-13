module PatternHistoryTable (
    input reset, 
    input clk, 
    input [4:0] predict_index,
    input [4:0] real_index,
    input real_is_jump_or_branch,
    input real_is_taken,
    output reg predict_is_taken
);

    reg [1:0] counter_table [0:31];

    integer i;

    always @(*) begin
        predict_is_taken = counter_table[predict_index] == 2'b10 || counter_table[predict_index] == 2'b11;
    end


    always @(posedge clk) begin
        if(reset) begin
            for(i = 0 ; i<32; i = i+1)
                counter_table[i] <= 2'b00;
        end
        else begin
            if(real_is_jump_or_branch) begin
                case(counter_table[real_index])
                    2'b11: begin
                        if(real_is_taken) counter_table[real_index] <= 2'b11;
                        else counter_table[real_index] <= 2'b10;
                    end
                    2'b10: begin
                        if(real_is_taken) counter_table[real_index] <= 2'b11;
                        else counter_table[real_index] <=  2'b01;
                    end
                    2'b01: begin
                        if(real_is_taken) counter_table[real_index] <= 2'b10;
                        else counter_table[real_index] <=  2'b00;
                    end
                    2'b00: begin
                        if(real_is_taken) counter_table[real_index] <= 2'b01;
                        else counter_table[real_index] <=  2'b00;
                    end
                endcase
            end
        end
    end
endmodule

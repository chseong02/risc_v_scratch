module BranchPredictor (
    input reset, 
    input clk, 
    input [31:0] read_addr,
    input [31:0] write_addr,
    input write_is_valid,
    input [31:0] write_predict_pc,
    input [31:0] write_calculated_taken_pc,
    input write_addr_taken,
    input write_is_jump_or_branch,
    output reg [31:0] next_pc,
    output reg is_flush
);

    reg [23:0] tag_table [0:63];
    reg valid_bit_table [0:63];
    reg [1:0] branch_history_table [0:63]; 
    reg [31:0] branch_target_buffer [0:63];
    integer i;

    reg [31:0] write_real_pc;
    reg [5:0] read_btb_index;
    reg [5:0] write_btb_index;
    always @(*) begin
        read_btb_index = read_addr[7:2];
        write_btb_index = write_addr[7:2];

        write_real_pc = write_addr_taken ? write_calculated_taken_pc : (write_addr + 4);
        is_flush = 0;
        if(write_is_valid)begin
            is_flush = write_real_pc != write_predict_pc;
        end

        if(is_flush) begin
            next_pc = write_real_pc;
        end
        else begin
            next_pc = read_addr + 4;
            if(valid_bit_table[read_btb_index]) begin
                if(tag_table[read_btb_index] == read_addr[31:8])begin
                    if(branch_history_table[read_btb_index]>=2'b10)begin
                        next_pc = branch_target_buffer[read_btb_index];
                    end
                end 
            end
        end
    end


    always @(posedge clk) begin
        if(reset) begin
            for(i = 0 ; i<63; i = i+1)
                tag_table[i] <= 0;
                valid_bit_table[i] <=0;
                branch_history_table[i]<=0;
                branch_target_buffer[i]<=0;
        end
        else begin
            if(write_is_jump_or_branch) begin
                tag_table [write_btb_index] <= write_addr[31:8];
                valid_bit_table[write_btb_index] <= 1;
                case(branch_history_table[write_btb_index])
                    2'b11: begin
                        if(write_addr_taken) branch_history_table[write_addr] <= 2'b11;
                        else branch_history_table[write_btb_index] <= 2'b10;
                    end
                    2'b10: begin
                        if(write_addr_taken) branch_history_table[write_addr] <= 2'b11;
                        else branch_history_table[write_btb_index] <=  2'b01;
                    end
                    2'b01: begin
                        if(write_addr_taken) branch_history_table[write_addr] <= 2'b10;
                        else branch_history_table[write_btb_index] <=  2'b00;
                    end
                    2'b00: begin
                        if(write_addr_taken) branch_history_table[write_addr] <= 2'b01;
                        else branch_history_table[write_btb_index] <=  2'b00;
                    end
                endcase
                branch_target_buffer[write_btb_index] <= write_calculated_taken_pc;
            end
        end
    end
endmodule

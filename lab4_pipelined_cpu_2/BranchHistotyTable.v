module BranchHistoryTable (
    input reset, 
    input clk, 
    input is_jump_branch, // is_jal || is_jalr || is_branch
    input [31:0]actual_PC, 
    input [4:0]index, 
    input [24:0]tag,
    input [1:0]update_counter, // 업데이트할 카운터
    output reg is_taken,
    output reg [31:0] predict_PC
);

    reg [59:0]BTB[0:31]; // counter = (59:58) / valid bit = (57) / tag = (56,32) / pc (31,0)
    integer i;

    always @(*) begin
            if((tag == BTB[index][56:32]) && (BTB[index][59:58] == 2'b10 || BTB[index][59:58] == 2'b11)&&(BTB[index][57] == 1)) begin
                predict_PC = BTB[index][31:0];
                is_taken = 1;
            end
            else begin
                predict_PC = PC + 4;
                is_taken = 0;
            end
            
            if(is_jump_branch)begin
                BTB[index][59:58] = update_counter;
                BTB[index][57] = 1; // valid bit
                BTB[index][56:32] = tag;
                BTB[index][31:0] = actual_PC;
            end
    end


    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
            for(i = 0 ; i<32 ;i = i+1)
                BTB[i][57:0] <= 0;
        end
    end
endmodule
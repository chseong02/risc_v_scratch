module BranchHistoryTable (
    input reset, 
    input clk, 
    input old_is_jump_or_branch,
    input current_is_jump_or_branch,
    input [31:0]old_PC, // ex ori pc
    input [31:0]cal_PC, // ex cal pc
    input branch_taken,
    input [31:0]current_PC, // pc
    input [1:0] update_counter,
    output reg [31:0] predict_PC,
    output reg [1:0] counter,
    output reg is_flush
);

    reg [59:0] BTB[0:31]; // counter = (59:58) / valid bit = (57) / tag = (56,32) / pc (31,0)
    integer i;

    always @(*) begin
        is_flush=0;
        if(current_is_jump_or_branch&&(current_PC[31:7] == BTB[current_PC[6:2]][56:32]) && (BTB[current_PC[6:2]][59:58] == 2'b10 || BTB[current_PC[6:2]][59:58] == 2'b11)&&(BTB[current_PC[6:2]][57] == 1)) begin
            predict_PC = BTB[current_PC[6:2]][31:0];
        end
        else begin
            predict_PC = current_PC + 4;
        end

        counter = BTB[old_PC[6:2]][59:58];

        if(old_is_jump_or_branch) begin
            is_flush = ((branch_taken ? cal_PC:(old_PC+4))!=(counter>=2?(BTB[old_PC[6:2]][31:0]):(old_PC+4))) || ((!branch_taken) && (counter<2));
            //is_flush = cal_PC != BTB[old_PC[6:2]][31:0];
            if(is_flush) begin
                predict_PC = branch_taken?cal_PC:(old_PC+4);
            end
        end
    end


    always @(posedge clk) begin
        if(reset) begin
            for(i = 0 ; i<32 ;i = i+1)
                BTB[i][57:0] <= 0;
        end
        else begin
            if(old_is_jump_or_branch)begin
                BTB[old_PC[6:2]][59:58] <= update_counter;
                BTB[old_PC[6:2]][56:32] <= old_PC[31:7];
                BTB[old_PC[6:2]][31:0] <= cal_PC;
                BTB[old_PC[6:2]][57] <= 1;
            end
        end
    end
endmodule

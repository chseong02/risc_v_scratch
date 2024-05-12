module BranchHistoryTable (
    input reset, 
    input clk, 
    input is_jump_branch, // is_jal || is_jalr || is_branch
    input [31:0]old_PC, 
    input [31:0]cal_PC, 
    input [31:0]current_PC, 
    input [1:0] update_counter,
    output reg [31:0] predict_PC,
    output reg [1:0] counter,
    output reg pc_mux_control
);

    reg [59:0]BTB[0:31]; // counter = (59:58) / valid bit = (57) / tag = (56,32) / pc (31,0)
    integer i;

    always @(*) begin
            if((current_PC[31:7] == BTB[current_PC[6:2]][56:32]) && (BTB[current_PC[6:2]][59:58] == 2'b10 || BTB[current_PC[6:2]][59:58] == 2'b11)&&(BTB[current_PC[6:2]][57] == 1)) begin
                predict_PC = BTB[current_PC[6:2]][31:0];
                pc_mux_control = 1;
            end
            else begin
                pc_mux_control = 0;
            end

            counter = BTB[old_PC[6:2]][59:58];
    end


    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
            for(i = 0 ; i<32 ;i = i+1)
                BTB[i][57:0] <= 0;
        end
        else begin
            if(is_jump_branch)begin
                BTB[old_PC[6:2]][59:58] <= update_counter;
                BTB[old_PC[6:2]][31:0] <= old_PC;
            end
        end
    end
endmodule
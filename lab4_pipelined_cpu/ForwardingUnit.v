module ForwardingUnit(
    rs_1,
    rs_2,
    WB_EX_MEM,
    WB_MEM_WB
    forward_A,
    forward_B
    );
    input [4:0] rs_1_EX;
    input [4:0] rs_2_EX;
    input [4:0] rd_MEM;
    input [4:0] rd_WB;
    input RegWrite_MEM;
    input RegWrite_WB;
    output reg [1:0] forward_A;
    output reg [1:0] forward_B;

    always @(*) begin
        if(rs_1_EX != 0 && rs_1_EX == rd_MEM && RegWrite_MEM)
            forward_A = 2'b01; //forward operand from MEM stage
        else if(rs_1_EX != 0 && rs_1_EX == rd_WB && RegWrite_WB)
            forward_A = 2'b10; //forward operand from WB stage
        else
            forward_A = 0;

        if(rs_2_EX != 0 && rs_2_EX == WB_EX_MEM && RegWrite_MEM)
            forward_B = 2'b01;  //forward operand from MEM stage
        else if(rs_2_EX != 0 && rs_2_EX == WB_MEM_WB && RegWrite_WB)
            forward_B = 2'b10;  //forward operand from WB stage
        else
            forward_B = 2'b00;
    end
endmodule
`include "alu_func.v"

module alu #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/
integer i;

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/
always @(*)begin
	OverflowFlag = 0;
	C[data_width-1] = A[data_width-1];

    case (FuncCode)
        4'b0000: C = A + B; // ADD
        4'b0001: C = A - B; // SUB
        4'b0010: C = A;     // ID
        4'b0011: C = ~A;    // NOT
        4'b0100: C = A & B; // AND
        4'b0101: C = A | B; // OR
        4'b0110: C = ~(A & B); // NAND
        4'b0111: C = ~(A | B); // NOR
        4'b1000: C = A ^ B; // XOR
        4'b1001: C = ~(A ^ B); // XNOR
        4'b1010: C = A << 1; // LLS
        4'b1011: C = A >> 1; // LRS
        4'b1100: C = A<<<1; // ALS
        4'b1101:
			for(i = 0; i<data_width-1; i++)begin
				C[i] = A[i+1];
			end // ARS
        4'b1110: C = ~A + 1; // TCP
        4'b1111: C = 16'b0;  // ZERO
    endcase

    if (FuncCode == 4'b0000)begin
		for(i = 0; i < data_width; i++)begin
			if(i == data_width-1)begin
			OverflowFlag = ((~A[i])&(~B[i])&OverflowFlag)|(A[i]&B[i]&(~OverflowFlag));
			end else begin
			OverflowFlag = (A[i]&B[i])|((~A[i])&B[i]&OverflowFlag)|(A[i]&OverflowFlag);
			end
		end
	end

    if (FuncCode == 4'b0001)begin
		OverflowFlag = (~(A[data_width-1])&B[data_width-1]&C[data_width-1])|(A[data_width-1]&~(B[data_width-1])&C[data_width-1]);
	end

end

endmodule


`include "vending_machine_def.v"

	

module change_return_trigger_point(clk,reset_n,i_trigger_return,return_trigger_point);
	input clk;
	input reset_n;
	input i_trigger_return;
	output reg [`kTotalBits-1:0] return_trigger_point;

	initial begin
		return_trigger_point = 0;
	end

	always @(posedge clk) begin
		if(!reset_n)begin
			return_trigger_point <= 0;
		end
		else if(i_trigger_return)begin
			return_trigger_point <= return_trigger_point + 1;
		end
		// initialize to 0, when i_trigger_retun are not continuous 1
		else begin
			return_trigger_point <= 0;
		end
	end
endmodule 

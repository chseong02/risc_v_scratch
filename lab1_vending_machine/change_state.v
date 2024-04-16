`include "vending_machine_def.v"


module change_state(clk,reset_n,wait_time_nxt,return_total,current_total_nxt,
wait_time,current_total);

	input clk;
	input reset_n;
	input [31:0] wait_time_nxt;
	input [`kTotalBits-1:0] return_total;
	input [`kTotalBits-1:0] current_total_nxt;
	output reg [31:0] wait_time;
	output reg [`kTotalBits-1:0] current_total;


	
	// initiate values
	initial begin
		wait_time = 0;
		current_total = 0;
	end

	
	// Sequential circuit to reset or update the states
	always @(posedge clk ) begin
		if (!reset_n) begin
			// reset
			wait_time <= 0;
			current_total <= 0;
		end
		else begin
			// input next state to current state
			wait_time <= wait_time_nxt;
			current_total <= current_total_nxt - return_total;
		end
	end
endmodule 

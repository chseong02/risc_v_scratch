`include "vending_machine_def.v"

	

module check_time_and_coin(coin_value,wait_time,input_total,
output_total,current_total_nxt,return_trigger_point,o_return_coin,wait_time_nxt,return_total);
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [31:0] wait_time;
	input [`kTotalBits-1:0] input_total, output_total,current_total_nxt,return_trigger_point;
	output reg [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time_nxt;
	output reg [`kTotalBits-1:0] return_total;
	integer i;

	// initiate values
	initial begin
		o_return_coin = 0;
	end

	// determine wait_time_nxt by input, item selection
	always @(*) begin
		if(input_total!=0||output_total!=0) begin
			wait_time_nxt = `kWaitTime+1;
		end
		else if(wait_time!=0)begin
			wait_time_nxt = wait_time - 1;
		end
		else begin
			wait_time_nxt = wait_time;
		end
	end

	// determine o_return_coin, return_total by wait_time, return_trigger_point
	always @(*) begin
		return_total = 0;
		o_return_coin = 0;
	
		if(return_trigger_point >= 3 || (wait_time <= 0 && wait_time_nxt <= 0)) begin
			// starting with the big unit of coin
			for(i=`kNumCoins-1;i>=0; i--)begin
				if(coin_value[i]<=(current_total_nxt-return_total)) begin
					o_return_coin[i] = 1;
					return_total = return_total+coin_value[i];
				end
			end
		end
	end
endmodule 

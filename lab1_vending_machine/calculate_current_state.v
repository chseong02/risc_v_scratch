
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
o_available_item,o_output_item,input_total, output_total,current_total_nxt);


	
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg [`kTotalBits-1:0] input_total, output_total,current_total_nxt;
	integer i;	

	// Combinational logic for the next states
	always @(*) begin
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.


		// reflect input coin at current_total
		current_total_nxt =  current_total;
		input_total = 0;
		for(i=0; i<`kNumCoins; i++) begin
			if(i_input_coin[i])begin
				input_total = input_total + coin_value[i];
			end
		end
		current_total_nxt = current_total_nxt + input_total;

		// determine o_available_item
		o_available_item = 0;
		for(i=0; i<`kNumItems; i++) begin
			if(current_total_nxt>=item_price[i])begin
				o_available_item[i] = 1;
			end
		end

		// determine o_output_item, output_total, final current_total_nxt
		o_output_item = 0;
		output_total = 0;
		for(i=0; i<`kNumItems; i++) begin
			if(i_select_item[i]==1&&current_total_nxt>=item_price[i])begin
				o_output_item[i]=1;
				output_total = output_total + item_price[i];
				current_total_nxt = current_total_nxt - item_price[i];
			end
		end
	end
endmodule 

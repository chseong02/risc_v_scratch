`include "CLOG2.v"

module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 8,
               parameter NUM_WAYS = 2) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_rw,
    input [31:0] din,

    output reg is_ready,
    output reg is_output_valid,
    output reg [31:0] dout,
    output reg is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  wire[LINE_SIZE * 8 - 1:0] mem_din;
  wire[LINE_SIZE * 8 - 1:0] mem_dout;
  wire mem_is_output_valid;
  // Reg declarations
  reg [(31-(`CLOG2(NUM_SETS))-(`CLOG2(LINE_SIZE))):0] tag_table [0:NUM_SETS-1][0:NUM_WAYS-1];
  reg valid_bit_table [0:NUM_SETS-1][0:NUM_WAYS-1];
  reg [8*LINE_SIZE-1:0] data_table [0:NUM_SETS-1][0:NUM_WAYS-1];
  reg dirty_table [0:NUM_SETS-1][0:NUM_WAYS-1];
  reg [((`CLOG2(NUM_WAYS))-1):0] recent_use_bit_table [0:NUM_SETS-1];
  // You might need registers to keep the status.
  integer i;
  integer j;

  reg is_loading;
  reg [(31-(`CLOG2(NUM_SETS))-(`CLOG2(LINE_SIZE))):0] addr_tag;
  reg [(`CLOG2(NUM_SETS))-1:0] addr_idx;
  reg [(`CLOG2(LINE_SIZE/4))-1:0] addr_bo;
  reg [1:0] addr_g;

  reg [((`CLOG2(NUM_WAYS))-1):0] replace_target_way;

  reg is_more_delay;
  reg is_internal_hit;
  reg is_have_been_miss;
  reg do_not_need_replace;
  reg is_dirty;
  reg [((`CLOG2(NUM_WAYS))-1):0] next_largest_way;
  
  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(is_input_valid && !is_loading && !is_internal_hit),
    .addr(!is_dirty ? (({tag_table[addr_idx][replace_target_way],addr[((`CLOG2(NUM_SETS))+(`CLOG2(LINE_SIZE))-1):0]})>>(`CLOG2(LINE_SIZE))) :(addr>>(`CLOG2(LINE_SIZE)))),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(!is_dirty),
    .mem_write(is_dirty),
    .din(is_dirty?data_table[addr_idx][replace_target_way]:mem_din),

    // is output from the data memory valid?
    .is_output_valid(mem_is_output_valid),
    .dout(mem_dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );



  always @(*) begin
    addr_tag =  addr[31:((`CLOG2(NUM_SETS))+(`CLOG2(LINE_SIZE)))];
    addr_idx = addr[((`CLOG2(NUM_SETS))+(`CLOG2(LINE_SIZE))-1):(`CLOG2(LINE_SIZE))];
    addr_bo = addr[((`CLOG2(LINE_SIZE))-1):2];
    addr_g = addr[1:0];
    replace_target_way = ~recent_use_bit_table[addr_idx];
    do_not_need_replace = 1'b0;
    is_dirty = 1'b0;
    is_internal_hit = 1'b0;
    is_loading = !(is_data_mem_ready);
    dout = 32'b0;
    is_output_valid = 1'b0;
    if(is_input_valid && !is_loading) begin
      
      for(i=0; i<NUM_WAYS; i=i+1) begin
        if(addr_tag == tag_table[addr_idx][i] && valid_bit_table[addr_idx][i]) begin
          is_internal_hit = 1'b1;
          is_output_valid = 1'b1;
          // read
          if(mem_rw == 1'b0) begin
            dout = data_table[addr_idx][i][((32'(addr_bo)*4+32'(addr_g))*8)+:32];
          end
        end
      end
      if(!is_internal_hit)begin
        for(i=0; i<NUM_WAYS; i=i+1) begin
          if(!valid_bit_table[addr_idx][i]) begin
            do_not_need_replace = 1'b1;
          end
        end
      end
    end
    is_hit = is_internal_hit && !is_have_been_miss;
    if(!do_not_need_replace&&dirty_table[addr_idx][replace_target_way])begin
        is_dirty= 1'b1;
    end
  end

  always @(posedge clk) begin
    if(reset) begin
      is_have_been_miss <= 1'b0;
      is_ready <= 1'b1;
      next_largest_way <= 1'b0;
      for(i=0; i<NUM_SETS; i=i+1) begin
        for(j=0; j<NUM_WAYS; j=j+1) begin
          tag_table[i][j] <= (32-(`CLOG2(NUM_SETS))-(`CLOG2(LINE_SIZE)))'(0);
          data_table[i][j] <= (8*LINE_SIZE)'(0);
          valid_bit_table[i][j] <= 1'b0;
          dirty_table[i][j] <= 1'b0;
        end
        recent_use_bit_table[i] <= (`CLOG2(NUM_WAYS))'(0);
      end
    end
    else if(!is_input_valid) begin
      is_ready <= 1'b1;
      is_have_been_miss<=1'b0;
    end
    else if(is_internal_hit && is_input_valid) begin
      for(i=0; i<NUM_WAYS; i=i+1) begin
        if(addr_tag == tag_table[addr_idx][i] && valid_bit_table[addr_idx][i]) begin
          recent_use_bit_table[addr_idx] <= (`CLOG2(NUM_WAYS))'(i);
        end
      end
      is_have_been_miss<=1'b0;
      is_ready <= 1'b1;
    end
    //miss
    else if(is_input_valid && !is_internal_hit && !is_loading)begin
      is_have_been_miss <= 1'b1;
      is_ready <= 1'b0;

      //dirty
      if(is_dirty&&dirty_table[addr_idx][replace_target_way])begin
        dirty_table[addr_idx][replace_target_way] <= 1'b0;
        valid_bit_table[addr_idx][replace_target_way] <= 1'b0;
      end

      //get data from dm
      else if(is_have_been_miss&&(mem_is_output_valid)) begin
        //빈공간 있을 때 + dirty 처리 이후
        if(do_not_need_replace)begin
          for(i=0; i<NUM_WAYS; i=i+1) begin
            if(!valid_bit_table[addr_idx][i]&&i<=next_largest_way) begin
              next_largest_way <= ((NUM_WAYS-1) >next_largest_way)?(next_largest_way+1) : (`CLOG2(NUM_WAYS))'(NUM_WAYS-1);
              recent_use_bit_table[addr_idx] <= (`CLOG2(NUM_WAYS))'(i);
              data_table[addr_idx][i]<=mem_dout;
              valid_bit_table[addr_idx][i]<=1'b1;
              tag_table[addr_idx][i]<=addr_tag;
            end
          end
        end
        else begin
          recent_use_bit_table[addr_idx] <= (`CLOG2(NUM_WAYS))'(replace_target_way);
          data_table[addr_idx][replace_target_way]<=mem_dout;
          valid_bit_table[addr_idx][replace_target_way]<=1'b1;
          tag_table[addr_idx][replace_target_way]<=addr_tag;
        end
      end
    end
    //write
    if(!reset&&is_input_valid && is_internal_hit)begin
      for(i=0; i<NUM_WAYS; i=i+1) begin
        if(addr_tag == tag_table[addr_idx][i] && valid_bit_table[addr_idx][i]) begin
          if(mem_rw)begin
            data_table[addr_idx][i][((32'(addr_bo)*4+32'(addr_g))*8)+:32]<=din;
            dirty_table[addr_idx][i]<=1'd1;
          end
        end
      end
    end
  end
endmodule

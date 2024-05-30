`include "CLOG2.v"

module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 16,
               parameter NUM_WAYS = 1) (
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
  wire[LINE_SIZE * 8 - 1:0] mem_dout;
  wire mem_is_output_valid;

  // Reg declarations
  reg [(31-(`CLOG2(NUM_SETS))-(`CLOG2(LINE_SIZE))):0] tag_table [0:NUM_SETS-1];
  reg valid_bit_table [0:NUM_SETS-1];
  reg [8*LINE_SIZE-1:0] data_table [0:NUM_SETS-1];
  reg dirty_table [0:NUM_SETS-1];
  reg is_dirty;
  reg is_request_to_mem;
  reg [31:0] request_addr;
  // You might need registers to keep the status.
  reg [(31-(`CLOG2(NUM_SETS))-(`CLOG2(LINE_SIZE))):0] addr_tag;
  reg [(`CLOG2(NUM_SETS))-1:0] addr_idx;
  reg [(`CLOG2(LINE_SIZE/4))-1:0] addr_bo;
  reg [1:0] addr_g;

  reg [2:0] status;
  reg [NUM_WAYS:0] temp;
  integer i;

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(is_request_to_mem),
    .addr(request_addr >> (`CLOG2(LINE_SIZE))),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read((status==3'd1||(status==3'd0&&!is_dirty))),
    .mem_write(status==3'd0&&is_dirty),
    .din(data_table[addr_idx]),

    // is output from the data memory valid?
    .is_output_valid(mem_is_output_valid),
    .dout(mem_dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );



  always @(*) begin
    //initialize
    // 페이즈랑 멤 레디 여부
    is_ready = 1'b0;
    dout = 32'b0;
    is_output_valid = 1'b0;
    is_hit = 1'b0;
    is_request_to_mem = 1'b0;
    request_addr= 32'b0;

    //addr param
    addr_tag =  addr[31:((`CLOG2(NUM_SETS))+(`CLOG2(LINE_SIZE)))];
    addr_idx = addr[((`CLOG2(NUM_SETS))+(`CLOG2(LINE_SIZE))-1):(`CLOG2(LINE_SIZE))];
    addr_bo = addr[((`CLOG2(LINE_SIZE))-1):2];
    addr_g = addr[1:0];
    is_dirty = dirty_table[addr_idx];
    
    
    if(is_input_valid) begin
      if(addr_tag == tag_table[addr_idx] && valid_bit_table[addr_idx]) begin
        if(status==3'd0)begin
          is_hit = 1'b1;
        end
        // read hit 
        if(mem_rw == 1'b0) begin
          is_output_valid = 1'b1;
          dout = data_table[addr_idx][(addr_bo*32)+:32];
          //dout = data_table[addr_idx][((32'(addr_bo)*4+32'(addr_g))*8)+:32];
        end
      end
      // miss
      else begin
        is_request_to_mem = !is_hit || status== 3'd1;
        // read miss
        if(status==3'd0&&is_dirty) begin
          request_addr = {tag_table[addr_idx],addr[((`CLOG2(NUM_SETS))+(`CLOG2(LINE_SIZE))-1):0]};
        end
        else if(status==3'd0&&!is_dirty) begin
          request_addr = addr;
        end
        else if(status==3'd1)begin
          request_addr = addr;
        end
      end
    end
    is_ready = !is_input_valid || (status == 3'd3) || is_hit;
  end

  // status calculate
  always @(posedge clk) begin
    if(!reset && is_input_valid)begin
      case(status)
        3'd0:begin
          if(is_hit)begin
            status <= 3'd0;
          end
          // miss
          else begin
            //miss_read/write dirty
            if(is_dirty)begin
              status <= 3'd1;
            end
            else begin
              status <= 3'd2;
            end
          end
        end
        3'd1:begin
          if(is_data_mem_ready)begin
            status <=3'd2;
          end
        end
        3'd2:begin
          if(is_data_mem_ready)begin
            status <=3'd3;
          end
        end
        3'd3:begin
          status<=3'd0;
        end
        default: status<=3'd0;
      endcase
    end
  end


  always @(posedge clk) begin
    if(reset) begin
      status <= 3'd0;
      for(i=0; i<NUM_SETS; i=i+1) begin
        tag_table[i] <= (32-(`CLOG2(NUM_SETS))-(`CLOG2(LINE_SIZE)))'(0);
        data_table[i]<= (8*LINE_SIZE)'(0);
        valid_bit_table[i]<= 1'b0;
        dirty_table[i] <= 1'b0;
      end
    end
    else if(is_input_valid) begin
      // write hit
      if(is_hit && mem_rw)begin
        //data_table[addr_idx][((32'(addr_bo)*4+32'(addr_g))*8)+:32]<=din;
        data_table[addr_idx][(addr_bo*32)+:32]<=din;
        dirty_table[addr_idx]<=1'd1;
      end

      if(is_data_mem_ready) begin
        if(status ==3'd1)begin
          valid_bit_table[addr_idx]<=1'b0;
          dirty_table[addr_idx]<=1'b0;
        end
        else if(status==3'd2)begin
          valid_bit_table[addr_idx]<=1'b1;
          dirty_table[addr_idx]<=1'b0;
          tag_table[addr_idx]<=addr_tag;
          data_table[addr_idx]<=mem_dout;
        end
        else if(status==3'd3)begin
          if(mem_rw)begin
            data_table[addr_idx][(addr_bo*32)+:32]<=din;
            dirty_table[addr_idx]<=1'd1;
          end
        end
      end
    end
  end
endmodule

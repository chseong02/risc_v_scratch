module NextPcSelecter (
    input [24:0] tag,
    input [24:0] btb_tag,
    input btb_is_valid,
    input predict_is_taken,
    input [31:0] btb_target_pc,
    input [31:0] now_pc,
    input [31:0] ex_predict_pc,
    input [31:0] ex_inst_pc,
    input [31:0] ex_taken_pc,
    input ex_is_taken,
    input ex_is_valid,
    output reg [31:0] next_pc,
    output reg is_flush
);

    always @(*) begin
        is_flush = ex_is_valid && (ex_is_taken ? ex_taken_pc : (ex_inst_pc+4)) != ex_predict_pc;
        if(is_flush)begin
            next_pc = (ex_is_taken ? ex_taken_pc : (ex_inst_pc+4));
        end
        else begin
            next_pc = now_pc + 4;
            if(tag == btb_tag && btb_is_valid && predict_is_taken) begin
                next_pc = btb_target_pc;
            end
        end
    end
endmodule

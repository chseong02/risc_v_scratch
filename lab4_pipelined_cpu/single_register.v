module single_register(
    reset,
    clk,
    in,
    out
    );
    input reset;
    input clk;
    input [`kDataWidth - 1 : 0] in;
    output reg [`kDataWidth - 1 : 0] out;

    always @(posedge clk) begin
        if (reset) begin
            out <= 32'b0;
        end

        else begin
            out <= in;
        end
    end
endmodule

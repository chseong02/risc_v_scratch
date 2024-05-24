module XorModule #(parameter data_width) (
    in_0, // input
    in_1, // input
    out   // output
);

    input [data_width-1:0] in_0;
    input [data_width-1:0] in_1;
    output reg [data_width-1:0] out;

    always @(*)begin
        out = in_0 ^ in_1;
    end
endmodule

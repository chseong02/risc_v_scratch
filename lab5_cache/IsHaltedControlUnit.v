module IsHaltedControlUnit(
    is_ecall,
    x17_data,
    is_halted
);
    input is_ecall;
    input [31:0] x17_data;
    output reg is_halted;

    always @(*) begin
        is_halted = is_ecall && x17_data == 32'd10;
    end
endmodule

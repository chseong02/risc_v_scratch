module HaltUnit(
    is_ecall,
    is_x17_10,
    is_halted
);
    input is_ecall;
    input is_x17_10;
    output reg is_halted;

    always @(*) begin
        is_halted = is_ecall && is_x17_10;
    end
endmodule

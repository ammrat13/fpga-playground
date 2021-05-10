/**
    mod_n_counter.v

    A counter that increments modulo its parameter `N`. It can also be reset.
*/

module mod_n_counter #(
    parameter N = 256
) (
    input wire clk,
    input wire write_en,
    input wire rst,
    output wire overflow,
    output reg [$clog2(N)-1:0] val = 0
);

    assign overflow = val == N-1;

    always @(posedge clk) begin
        if(rst) begin
            val <= 0;
        end else if(write_en) begin
            if(val == N-1) begin
                val <= 0;
            end else begin
                val <= val + 1;
            end
        end
    end

endmodule

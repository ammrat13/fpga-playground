/**
    mod_n_counter.v

    A counter that increments modulo its parameter `N`. It provides the
    remainder and the quotient. It can also be reset.

    Note that `MAX` is the maximum number of ticks, not the maximum value it can
    reach in total.
*/

module mod_n_counter #(
    parameter N = 1,
    parameter MAX = N
) (
    input wire clk,
    input wire write_en,
    input wire rst,
    output wire will_ov,
    output reg [$clog2(N)-1 : 0] r = 0,
    output reg [$clog2(MAX) - $clog2(N) : 0] q = 0
);

    assign will_ov = r == N-1;

    always @(posedge clk) begin
        if(rst) begin
            r <= 0;
            q <= 0;
        end else if(write_en) begin
            if(r == N-1) begin
                r <= 0;
                q <= q + 1;
            end else begin
                r <= r + 1;
            end
        end
    end

endmodule

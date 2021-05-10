/**
    cpu_reset.v

    This module provides simple reset logic for the CPU. It simply drives the
    reset wire low for one clock cycle, then keeps it high.
*/

module cpu_reset (
    input wire clk,
    output reg reset_n
);

    reg reset_done = 1'b0;

    always @(posedge clk) begin
        reset_n <= reset_done;
        reset_done <= 1'b1;
    end

endmodule

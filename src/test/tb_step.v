/**
    tb_step.v

    A very simple test bench. It just steps the clock a specified number of
    times, then stops. It's useful for interactive testing.
*/

// Timescale stolen from DE0-CV toplevel file
// Shouldn't really matter though
`timescale 1ns / 100ps


module tb_step ();

    localparam NUM_CYCLES = 100;
    reg clk = 1'b0;

    soc soc (
        .clk(clk) )
    ;

    integer i;
    initial begin
        for(i = 0; i < NUM_CYCLES; i = i + 1) begin
            clk = 1'b1;
            #1;
            clk = 1'b0;
            #1;
        end
    end

endmodule

/**
    top_de0cv.v

    The top level module for the DE0-CV board. It reduces the clock to 25MHz and
    instantiates the SoC.

    All the input pins were generated by Quartus, then cleaned up.
*/

module top_de0cv (
    input RESET_N,

    input CLOCK_50,
    input CLOCK2_50,
    input CLOCK3_50,
    inout CLOCK4_50,

    output [12:0] DRAM_ADDR,
    output  [1:0] DRAM_BA,
    output        DRAM_CAS_N,
    output        DRAM_CKE,
    output        DRAM_CLK,
    output        DRAM_CS_N,
    inout  [15:0] DRAM_DQ,
    output        DRAM_LDQM,
    output        DRAM_RAS_N,
    output        DRAM_UDQM,
    output        DRAM_WE_N,

    inout [35:0] GPIO_0,
    inout [35:0] GPIO_1,

    inout PS2_CLK,
    inout PS2_CLK2,
    inout PS2_DAT,
    inout PS2_DAT2,

    output       SD_CLK,
    inout        SD_CMD,
    inout  [3:0] SD_DATA,

    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output       VGA_HS,
    output       VGA_VS,

    output [6:0] HEX0,
    output [6:0] HEX2,
    output [6:0] HEX1,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,

    input [3:0] KEY,

    output [9:0] LEDR,

    input [9:0] SW
);

    wire clock_25;
    pll_25mhz pll (
        .refclk(CLOCK_50),
        .outclk_0(clock_25),
        .rst(1'b0)
    );

    soc soc (
        .clk(clock_25),
        .clk_25(clock_25),
        .sevenseg({HEX5, HEX4, HEX3, HEX2, HEX1, HEX0}),
        .vga_colors({VGA_R, VGA_G, VGA_B}),
        .vga_hs(VGA_HS),
        .vga_vs(VGA_VS)
    );

    assign LEDR = SW;

endmodule

/**
    soc.v

    The true top level file for the system. It has the CPU, RAM, and some MMIO
    registers.

    This system has a few clocks. The first can be of any frequency. The others
    must have certain fixed frequencies. They may be the same clock.
*/

module soc (
    input wire clk,
    input wire clk_25,

    output wire [11:0] vga_colors,
    output wire        vga_hs,
    output wire        vga_vs,

    input wire [31:0] keys,

    output wire [55:0] sevenseg
);

    wire reset_n;

    wire        mem_bus_valid;
    wire        mem_bus_ready;
    wire [31:0] mem_bus_addr;
    wire [31:0] mem_bus_wdata;
    wire  [3:0] mem_bus_wstrb;
    wire [31:0] mem_bus_rdata;


    picorv32 #(
        .ENABLE_COUNTERS(0),
        .CATCH_MISALIGN(0),
        .CATCH_ILLINSN(0),
        .REGS_INIT_ZERO(1)
    ) cpu (
        .clk(clk),
        .resetn(reset_n),
        .mem_valid(mem_bus_valid),
        .mem_ready(mem_bus_ready),
        .mem_addr(mem_bus_addr),
        .mem_wdata(mem_bus_wdata),
        .mem_wstrb(mem_bus_wstrb),
        .mem_rdata(mem_bus_rdata)
    );

    cpu_reset rst (
        .clk(clk),
        .reset_n(reset_n)
    );


    wire bram_valid;
    wire bram_ready;
    wire [31:0] bram_rdata;

    wire vga_valid;
    wire vga_ready;
    wire [31:0] vga_rdata;

    wire sevenseg_reg_valid;
    wire sevenseg_reg_ready;
    wire [31:0] sevenseg_reg_rdata;

    wire keys_valid;
    wire keys_ready;
    wire [31:0] keys_rdata;

    arbiter #(
        .N_INPUTS(4),
        .ADDR_RANGES({
            32'h00000000, 32'h0000ffff,
            32'h00010000, 32'h00020000,
            32'hfffffff8, 32'hfffffffb,
            32'hfffffffc, 32'hffffffff
        })
    ) arb (
        .rv32_valid(mem_bus_valid),
        .rv32_ready(mem_bus_ready),
        .rv32_addr(mem_bus_addr),
        .rv32_rdata(mem_bus_rdata),
        .valids({bram_valid, vga_valid, keys_valid, sevenseg_reg_valid}),
        .readys({bram_ready, vga_ready, keys_ready, sevenseg_reg_ready}),
        .rdatas({bram_rdata, vga_rdata, keys_rdata, sevenseg_reg_rdata})
    );

    rv32_bram #(
        .ADDR_WIDTH(14),
        .INIT_FILE("mem/program_ram/program.mem")
    ) mem (
        .clk(clk),
        .rv32_valid(bram_valid),
        .rv32_ready(bram_ready),
        .rv32_addr(mem_bus_addr),
        .rv32_wdata(mem_bus_wdata),
        .rv32_wstrb(mem_bus_wstrb),
        .rv32_rdata(bram_rdata)
    );

    rv32_vga #(
        .INIT("mem/char_rom/rom.mem"),
        .CHAR_COLS(8),
        .CHAR_ROWS(12)
    ) vga (
        .clk(clk),
        .clk_25(clk_25),
        .rv32_valid(vga_valid),
        .rv32_ready(vga_ready),
        .rv32_addr(mem_bus_addr),
        .rv32_wdata(mem_bus_wdata),
        .rv32_wstrb(mem_bus_wstrb),
        .vga_colors(vga_colors),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

    rv32_nop_read ks (
        .in_data(keys),
        .rv32_ready(keys_ready),
        .rv32_rdata(keys_rdata)
    );

    rv32_sevenseg_reg ssr (
        .clk(clk),
        .rv32_valid(sevenseg_reg_valid),
        .rv32_ready(sevenseg_reg_ready),
        .rv32_wdata(mem_bus_wdata),
        .rv32_wstrb(mem_bus_wstrb),
        .sevenseg(sevenseg)
    );

endmodule

/**
    soc.v

    The true top level file for the system. It has the CPU, RAM, and some MMIO
    registers.
*/

module soc (
    input wire clk,

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

    wire sevenseg_reg_valid;
    wire sevenseg_reg_ready;

    arbiter arb (
        .rv32_valid(mem_bus_valid),
        .rv32_ready(mem_bus_ready),
        .rv32_addr(mem_bus_addr),
        .bram_valid(bram_valid),
        .bram_ready(bram_ready),
        .sevenseg_reg_valid(sevenseg_reg_valid),
        .sevenseg_reg_ready(sevenseg_reg_ready)
    );

    rv32_bram #(
        .ADDR_WIDTH(10),
        .INIT_FILE("mem/bram_init.mem")
    ) mem (
        .clk(clk),
        .rv32_valid(bram_valid),
        .rv32_ready(bram_ready),
        .rv32_addr(mem_bus_addr),
        .rv32_wdata(mem_bus_wdata),
        .rv32_wstrb(mem_bus_wstrb),
        .rv32_rdata(mem_bus_rdata)
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

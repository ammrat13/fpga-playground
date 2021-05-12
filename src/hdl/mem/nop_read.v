/**
    nop_read.v

    A simple adapter between some bits on the SoC and the picoRV32 bus.
*/

module rv32_nop_read (
    input wire [31:0] in_data,

    output wire rv32_ready,
    output wire [31:0] rv32_rdata
);

    assign rv32_rdata = in_data;
    assign rv32_ready = 1'b1;

endmodule

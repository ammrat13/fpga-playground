/**
    arbiter.v

    A module implementing the arbitration logic for MMIO.
*/

module arbiter (
    input wire rv32_valid,
    output wire rv32_ready,
    input wire [31:0] rv32_addr,

    output wire bram_valid,
    input wire bram_ready,

    output wire sevenseg_reg_valid,
    input wire sevenseg_reg_ready )
;

    wire bram_active         = rv32_addr <= 32'h0000ffff;
    wire sevenseg_reg_active = rv32_addr >= 32'hfffffffc;

    assign bram_valid         = bram_active ? rv32_valid : 1'b0;
    assign sevenseg_reg_valid = sevenseg_reg_active ? rv32_valid : 1'b0;

    assign rv32_ready = bram_active ? bram_ready :
                        sevenseg_reg_active ? sevenseg_reg_ready :
                        1'b0;

endmodule

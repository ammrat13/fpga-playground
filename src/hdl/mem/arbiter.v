/**
    arbiter.v

    A module implementing the arbitration logic for MMIO.
*/

module arbiter #(
    parameter N_INPUTS = 1,
    parameter [N_INPUTS*64 - 1 : 0] ADDR_RANGES = {
        32'h00000000, 32'hffffffff
    }
) (
    input wire rv32_valid,
    output wire rv32_ready,
    input wire [31:0] rv32_addr,

    output wire [N_INPUTS-1 : 0] valids,
    input wire  [N_INPUTS-1 : 0] readys
);

    wire [N_INPUTS-1 : 0] actives;

    assign rv32_ready = (actives & readys) != 0;

    generate
        genvar i;
        for(i = 0; i < N_INPUTS; i = i + 1) begin : gen_loop
            localparam off = 64 * (i+1);
            localparam addr_lo = ADDR_RANGES[off- 1 : off-32];
            localparam addr_hi = ADDR_RANGES[off-33 : off-64];

            assign actives[i] = addr_lo <= rv32_addr && rv32_addr <= addr_hi;
            assign valids[i] = actives[i] ? rv32_valid : 1'b0;
        end
    endgenerate
endmodule

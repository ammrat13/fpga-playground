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
    input wire  rv32_valid,
    output wire rv32_ready,
    input wire  [31:0] rv32_addr,
    output wire [31:0] rv32_rdata,

    output wire [N_INPUTS-1 : 0] valids,
    input wire  [N_INPUTS-1 : 0] readys,
    input wire  [32*N_INPUTS-1 : 0] rdatas
);

    wire [N_INPUTS-1 : 0] actives;

    assign rv32_ready = (actives & readys) != 0;
    assign rv32_rdata = (actives == 0) ? 32'h00000000 : 32'hzzzzzzzz;

    generate
        genvar i;
        for(i = 0; i < N_INPUTS; i = i + 1) begin : gen_loop
            localparam addr_lo = ADDR_RANGES[64*i+63 : 64*i+32];
            localparam addr_hi = ADDR_RANGES[64*i+31 : 64*i];

            assign actives[i] = addr_lo <= rv32_addr && rv32_addr <= addr_hi;
            assign valids[i] = actives[i] ? rv32_valid : 1'b0;

            assign rv32_rdata = actives[i] ? rdatas[32*i+31 : 32*i] : 32'hzzzzzzzz;
        end
    endgenerate
endmodule

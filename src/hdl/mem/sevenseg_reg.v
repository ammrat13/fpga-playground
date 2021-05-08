/**
    sevenseg_reg.v

    This module is an MMIO interface for a hexadecimal display. It also provides
    a module for the PicoRV32 bus.
*/


module sevenseg_reg_single (
    input wire clk,
    input wire write_en,
    input wire [3:0] data,
    output reg [6:0] sevenseg = 7'b1111111 )
;

    wire [6:0] res;
    bin_2_sevenseg converter (
        .bin(data),
        .sevenseg(res) )
    ;

    always @(posedge clk) begin
        if(write_en) begin
            sevenseg <= res;
        end
    end

endmodule


module sevenseg_reg #(
    parameter HEXTETS = 8 )
(
    input wire clk,
    input wire [HEXTETS-1:0] write_en,
    input wire [4*HEXTETS-1:0] data,
    output wire [7*HEXTETS-1:0] sevenseg )
;

    genvar i;
    generate
        for(i = 0; i < HEXTETS; i = i + 1) begin : regs
            sevenseg_reg_single r (
                .clk(clk),
                .write_en(write_en[i]),
                .data(data[4*i+3 : 4*i]),
                .sevenseg(sevenseg[7*i+6 : 7*i]) )
            ;
        end
    endgenerate

endmodule


module rv32_sevenseg_reg (
    input wire clk,
    input wire [3:0] write_en,
    input wire [31:0] data,
    output wire [55:0] sevenseg )
;

    sevenseg_reg #(
        .HEXTETS(8) )
    r (
        .clk(clk),
        .write_en({
            {2{write_en[3]}},
            {2{write_en[2]}},
            {2{write_en[1]}},
            {2{write_en[0]}}}),
        .data(data),
        .sevenseg(sevenseg) )
    ;

endmodule

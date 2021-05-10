/**
    bin_2_sevenseg.v

    A utility module for converting a 4-bit input to a 7-bit output for seven
    segment displays. Its all combinational logic!
*/

module bin_2_sevenseg (
    input wire  [3:0] bin,
    output wire [6:0] sevenseg
);


    assign sevenseg =   (bin == 4'h0) ? 7'b1000000 :
                        (bin == 4'h1) ? 7'b1111001 :
                        (bin == 4'h2) ? 7'b0100100 :
                        (bin == 4'h3) ? 7'b0110000 :
                        (bin == 4'h4) ? 7'b0011001 :
                        (bin == 4'h5) ? 7'b0010010 :
                        (bin == 4'h6) ? 7'b0000010 :
                        (bin == 4'h7) ? 7'b1111000 :
                        (bin == 4'h8) ? 7'b0000000 :
                        (bin == 4'h9) ? 7'b0011000 :
                        (bin == 4'ha) ? 7'b0001000 :
                        (bin == 4'hb) ? 7'b0000011 :
                        (bin == 4'hc) ? 7'b1000110 :
                        (bin == 4'hd) ? 7'b0100001 :
                        (bin == 4'he) ? 7'b0000110 :
                        (bin == 4'hf) ? 7'b0001110 :
                        7'b1111111;


endmodule

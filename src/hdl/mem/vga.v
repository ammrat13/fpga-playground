/**
    vga.v

    A VGA display controller. It uses a 640x480 resolution and requires a 25MHz
    clock. It displays the character in the character buffer generated.
*/

module vga #(
    parameter INIT = "",
    parameter CHAR_ROWS = 12,
    parameter CHAR_COLS = 8
) (
    input wire clk_25,
    output wire [11:0] vga_colors,
    output wire        vga_hs,
    output wire        vga_vs
);

    reg       char_rom [256*CHAR_ROWS*CHAR_COLS - 1 : 0];
    reg [7:0] char_buf [(640*480) / (CHAR_ROWS*CHAR_COLS) - 1 : 0];


    wire col_ov;
    wire row_ov;
    wire [9:0] col;
    wire [9:0] row;

    wire [$clog2(640/CHAR_COLS) - 1 : 0] char_idx_col;
    wire         [$clog2(CHAR_COLS) : 0] char_sub_col;
    wire [$clog2(480/CHAR_ROWS) - 1 : 0] char_idx_row;
    wire         [$clog2(CHAR_ROWS) : 0] char_sub_row;

    mod_n_counter #(
        .N(800)
    ) col_count (
        .clk(clk_25),
        .write_en(1'b1),
        .rst(1'b0),
        .will_ov(col_ov),
        .r(col)
    );
    mod_n_counter #(
        .N(525)
    ) row_count (
        .clk(clk_25),
        .write_en(col_ov),
        .rst(1'b0),
        .will_ov(row_ov),
        .r(row)
    );

    mod_n_counter #(
        .N(CHAR_COLS),
        .MAX(640)
    ) char_col_count (
        .clk(clk_25),
        .write_en(1'b1),
        .rst(col_ov),
        .r(char_sub_col),
        .q(char_idx_col)
    );
    mod_n_counter #(
        .N(CHAR_ROWS),
        .MAX(480)
    ) char_row_count (
        .clk(clk_25),
        .write_en(col_ov),
        .rst(row_ov),
        .r(char_sub_row),
        .q(char_idx_row)
    );


    wire [12:0] char_num = char_idx_row * (640/CHAR_COLS) + char_idx_col;
    wire in_hblank = col >= 10'd640;
    wire in_vblank = row >= 10'd480;

    assign vga_hs = col < 10'd656 || 10'd752 <= col;
    assign vga_vs = row < 10'd490 || 10'd492 <= row;
    assign vga_colors = 12'hfff & {12{
                            (!in_hblank && !in_vblank) &&
                            char_rom[
                                char_buf[char_num]*CHAR_ROWS*CHAR_COLS
                                + char_sub_row*CHAR_COLS
                                + char_sub_col
                            ]
                        }};


    initial begin : initialize_chars
        integer i;
        for(i = 0; i < (640*480)/(CHAR_ROWS*CHAR_COLS); i = i + 1) begin
            char_buf[i] = 8'h00;
        end
        if(INIT != "") begin
            $readmemb(INIT, char_rom);
        end
    end
endmodule

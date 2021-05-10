/**
    vga.v

    A VGA display controller. It uses a 640x480 resolution and requires a 25MHz
    clock. Right now, it just displays a fixed color.
*/

module vga (
    input wire clk_25,

    output wire [11:0] vga_colors,
    output wire        vga_hs,
    output wire        vga_vs
);

    reg       char_rom [256*8*6-1:0];
    reg [7:0] char_buf [(640*480)/(8*6)-1:0];


    wire col_ov;
    wire row_ov;

    wire [9:0] col;
    mod_n_counter #(
        .N(800)
    ) col_count (
        .clk(clk_25),
        .write_en(1'b1),
        .rst(1'b0),
        .overflow(col_ov),
        .val(col)
    );

    wire [2:0] char_col;
    mod_n_counter #(
        .N(6)
    ) char_col_count (
        .clk(clk_25),
        .write_en(1'b1),
        .rst(col_ov),
        .val(char_col)
    );

    wire [9:0] row;
    mod_n_counter #(
        .N(525)
    ) row_count (
        .clk(clk_25),
        .write_en(col_ov),
        .rst(1'b0),
        .overflow(row_ov),
        .val(row)
    );

    wire [2:0] char_row;
    mod_n_counter #(
        .N(8)
    ) char_row_count (
        .clk(clk_25),
        .write_en(col_ov),
        .rst(row_ov),
        .val(char_row)
    );

    wire [12:0] char_num = (row/8)*(640/6) + (col/6);


    wire in_hblank = col >= 10'd636;
    wire in_vblank = row >= 10'd480;
    assign vga_hs = col < 10'd656 || 10'd752 <= col;
    assign vga_vs = row < 10'd490 || 10'd492 <= row;

    assign vga_colors = 12'hfff & {12{
                            (!in_hblank && !in_vblank) &&
                            char_rom[char_buf[char_num]*8*6 + char_row*6 + char_col]
                        }};


    integer i;
    initial begin
        $readmemb("mem/char_rom/rom.mem", char_rom);
        for(i = 0; i < (640*480)/(8*6); i = i + 1) begin
            char_buf[i] = i;
        end
    end
endmodule

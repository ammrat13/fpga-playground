/**
    vga.v

    A VGA display controller. It uses a 640x480 resolution and requires a 25MHz
    clock. It displays the character in the character buffer.

    There's also an adapter for the picoRV32 bus, though it only supports byte
    writes.
*/



module vga #(
    parameter INIT = "",
    parameter CHAR_ROWS = 12,
    parameter CHAR_COLS = 8
) (
    input wire clk_25,
    input wire clk_write,
    input wire                                                   write_en,
    input wire [$clog2((640*480)/(CHAR_ROWS*CHAR_COLS)) - 1 : 0] addr,
    input wire                                           [6 : 0] data,
    output wire [11:0] vga_colors,
    output wire        vga_hs,
    output wire        vga_vs
);


    reg       char_rom [128*CHAR_ROWS*CHAR_COLS - 1 : 0];
    reg [6:0] char_buf [(640*480) / (CHAR_ROWS*CHAR_COLS) - 1 : 0];


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
            char_buf[i] = 7'h00;
        end
        if(INIT != "") begin
            $readmemb(INIT, char_rom);
        end
    end


    always @(posedge clk_write) begin
        if(write_en) begin
            char_buf[addr] <= data;
        end
    end

endmodule



module rv32_vga #(
    parameter INIT = "",
    parameter CHAR_ROWS = 12,
    parameter CHAR_COLS = 8
) (
    input wire clk,
    input wire clk_25,
    input wire  rv32_valid,
    output wire rv32_ready,
    input wire [31:0] rv32_addr,
    input wire [31:0] rv32_wdata,
    input wire  [3:0] rv32_wstrb,
    output wire [11:0] vga_colors,
    output wire        vga_hs,
    output wire        vga_vs
);

    assign rv32_ready = 1'b1;

    wire [1:0] offset = (rv32_wstrb == 4'b0001) ? 2'h0 :
                        (rv32_wstrb == 4'b0010) ? 2'h1 :
                        (rv32_wstrb == 4'b0100) ? 2'h2 :
                        (rv32_wstrb == 4'b1000) ? 2'h3 :
                        2'h0;
    wire [6:0] real_wdata = (rv32_wstrb == 4'b0001) ? rv32_wdata[ 6: 0] :
                            (rv32_wstrb == 4'b0010) ? rv32_wdata[14: 8] :
                            (rv32_wstrb == 4'b0100) ? rv32_wdata[22:16] :
                            (rv32_wstrb == 4'b1000) ? rv32_wdata[30:24] :
                            7'h0;

    vga #(
        .INIT(INIT),
        .CHAR_ROWS(CHAR_ROWS),
        .CHAR_COLS(CHAR_COLS)
    ) vga (
        .clk_25(clk_25),
        .clk_write(clk),
        .write_en(rv32_valid),
        .addr(rv32_addr + offset),
        .data(real_wdata),
        .vga_colors(vga_colors),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

endmodule

/**
    vga.v

    A VGA display controller. It uses a 640x480 resolution and requires a 25MHz
    clock. It displays the character in the character buffer.

    There's also an adapter for the picoRV32 bus, though it only supports byte
    writes.
*/



module char_buf #(
    parameter CHAR_ROWS = 12,
    parameter CHAR_COLS = 8,
    parameter CHAR_ADDR_WIDTH = $clog2((640*480)/(CHAR_ROWS*CHAR_COLS))
) (
    input wire clk_write,
    input wire clk_25,
    input wire write_en,
    input wire [CHAR_ADDR_WIDTH-1 : 0] waddr,
    input wire                 [6 : 0] wdata,
    input wire [CHAR_ADDR_WIDTH-1 : 0] raddr,
    output reg                 [6 : 0] rdata,
    output reg write_done
);

    reg [6:0] cbuf [2**CHAR_ADDR_WIDTH-1 : 0];

    always @(posedge clk_write) begin
        if(write_en) begin
            cbuf[waddr] <= wdata;
            if(!write_done) begin
                write_done <= 1'b1;
            end else begin
                write_done <= 1'b0;
            end
        end else begin
            write_done <= 1'b0;
        end
    end
    always @(posedge clk_25) begin
        rdata <= cbuf[raddr];
    end

    initial begin : initialize_char_buf
        integer i;
        for(i = 0; i < 2**CHAR_ADDR_WIDTH-1; i = i + 1) begin
            cbuf[i] = 7'h00;
        end
    end
endmodule



module vga #(
    parameter INIT = "",
    parameter CHAR_ROWS = 12,
    parameter CHAR_COLS = 8,
    parameter CHAR_ADDR_WIDTH = $clog2((640*480)/(CHAR_ROWS*CHAR_COLS))
) (
    input wire clk_25,

    output wire [CHAR_ADDR_WIDTH-1 : 0] char_num,
    input wire                  [6 : 0] char_val,

    output wire [11:0] vga_colors,
    output wire        vga_hs,
    output wire        vga_vs
);


    reg char_rom [128*CHAR_ROWS*CHAR_COLS - 1 : 0];
    initial begin : initialize_chars
        if(INIT != "") begin
            $readmemb(INIT, char_rom);
        end
    end


    wire [9:0] col;
    wire [9:0] row;
    wire [$clog2(640/CHAR_COLS) - 1 : 0] char_idx_col;
    wire     [$clog2(CHAR_COLS) - 1 : 0] char_sub_col;
    wire [$clog2(480/CHAR_ROWS) - 1 : 0] char_idx_row;
    wire     [$clog2(CHAR_ROWS) - 1 : 0] char_sub_row;

    wire col_ov;
    wire row_ov;

    assign char_num = char_idx_row * (640/CHAR_COLS) + char_idx_col;

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


    reg [9:0] col_delay;
    reg [9:0] row_delay;
    reg [$clog2(CHAR_COLS) - 1 : 0] char_sub_col_delay;
    reg [$clog2(CHAR_ROWS) - 1 : 0] char_sub_row_delay;

    wire in_hblank = col_delay >= 10'd640;
    wire in_vblank = row_delay >= 10'd480;
    always @(posedge clk_25) begin
        col_delay <= col;
        row_delay <= row;
        char_sub_col_delay <= char_sub_col;
        char_sub_row_delay <= char_sub_row;
    end

    assign vga_hs = col_delay < 10'd656 || 10'd752 <= col_delay;
    assign vga_vs = row_delay < 10'd490 || 10'd492 <= row_delay;
    assign vga_colors = 12'hfff & {12{
                            (!in_hblank && !in_vblank) &&
                            char_rom[
                                char_val*CHAR_ROWS*CHAR_COLS
                                + char_sub_row_delay*CHAR_COLS
                                + char_sub_col_delay
                            ]
                        }};
endmodule



module rv32_vga #(
    parameter INIT = "",
    parameter CHAR_ROWS = 12,
    parameter CHAR_COLS = 8,
    parameter CHAR_ADDR_WIDTH = $clog2((640*480)/(CHAR_ROWS*CHAR_COLS))
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

    wire [CHAR_ADDR_WIDTH-1 : 0] cbuf_addr;
    wire                 [6 : 0] cbuf_data;

    char_buf #(
        .CHAR_ROWS(CHAR_ROWS),
        .CHAR_COLS(CHAR_COLS)
    ) cbuf (
        .clk_write(clk),
        .clk_25(clk_25),
        .write_en(rv32_valid),
        .waddr(rv32_addr + offset),
        .wdata(real_wdata),
        .raddr(cbuf_addr),
        .rdata(cbuf_data),
        .write_done(rv32_ready)
    );

    vga #(
        .INIT(INIT),
        .CHAR_ROWS(CHAR_ROWS),
        .CHAR_COLS(CHAR_COLS)
    ) vga (
        .clk_25(clk_25),
        .char_num(cbuf_addr),
        .char_val(cbuf_data),
        .vga_colors(vga_colors),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

endmodule

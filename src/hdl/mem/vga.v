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

    reg [9:0] row = 10'd0;
    reg [9:0] col = 10'd0;
    always @(posedge clk_25) begin
        if(col == 10'd799) begin
            col <= 10'd0;
            if(row == 10'd524) begin
                row <= 10'd0;
            end else begin
                row <= row + 1;
            end
        end else begin
            col <= col + 1;
        end
    end

    wire in_hblank = col >= 640;
    wire in_vblank = row >= 480;
    assign vga_hs = col < 656 || 752 <= col;
    assign vga_vs = row < 490 || 492 <= row;

    assign vga_colors = 12'hfff & {12{!in_hblank && !in_vblank}};

endmodule

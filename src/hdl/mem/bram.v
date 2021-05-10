/**
    bram.v

    A basic BRAM module with configurable address and data widths. Rising edge
    triggered.

    It also has an adapter for the RV32 native interface.
*/


module bram #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH =  8,
    parameter INIT_FILE = ""
) (
    input wire clk,
    input wire write_en,

    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

    initial begin
        if(INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    always @(posedge clk) begin
        if(write_en) begin
            mem[addr] <= data_in;
        end
        data_out <= mem[addr];
    end

endmodule


module rv32_bram #(
    parameter ADDR_WIDTH = 10,
    parameter INIT_FILE = ""
) (
    input wire clk,

    input wire rv32_valid,
    output reg rv32_ready,

    input wire  [31:0] rv32_addr,
    input wire  [31:0] rv32_wdata,
    input wire   [3:0] rv32_wstrb,
    output wire [31:0] rv32_rdata
);

    localparam STATE_BUFFER  = 2'h0;
    localparam STATE_WAITING = 2'h1;
    localparam STATE_READING = 2'h2;
    localparam STATE_WRITING = 2'h3;
    reg [1:0] state = STATE_WAITING;

    reg         write_en;
    wire [31:0] data_in;
    wire [31:0] data_out;
    assign rv32_rdata = data_out;
    assign data_in = {  rv32_wstrb[3] ? rv32_wdata[31:24] : data_out[31:24],
                        rv32_wstrb[2] ? rv32_wdata[23:16] : data_out[23:16],
                        rv32_wstrb[1] ? rv32_wdata[15: 8] : data_out[15: 8],
                        rv32_wstrb[0] ? rv32_wdata[ 7: 0] : data_out[ 7: 0] };

    bram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(32),
        .INIT_FILE(INIT_FILE)
    ) mem (
        .clk(clk),
        .write_en(write_en),
        .addr(rv32_addr[ADDR_WIDTH+1:2]),
        .data_in(data_in),
        .data_out(data_out)
    );

    always @(posedge clk) begin
        case(state)

            STATE_BUFFER: begin
                write_en <= 1'b0;
                rv32_ready <= 1'b0;
                state <= STATE_WAITING;
            end

            STATE_WAITING: begin
                write_en <= 1'b0;
                rv32_ready <= 1'b0;
                if(rv32_valid) begin
                    state <= STATE_READING;
                end else begin
                    state <= STATE_WAITING;
                end
            end

            STATE_READING: begin
                write_en <= 1'b0;
                if(rv32_wstrb == 0) begin
                    rv32_ready <= 1'b1;
                    state <= STATE_BUFFER;
                end else begin
                    rv32_ready <= 1'b0;
                    state <= STATE_WRITING;
                end
            end

            STATE_WRITING: begin
                write_en <= 1'b1;
                rv32_ready <= 1'b1;
                state <= STATE_BUFFER;
            end

        endcase
    end

endmodule

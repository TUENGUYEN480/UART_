module FIFO_sync #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire rst,
    input  wire clk,
    // write
    input  wire wr_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire full,
    // read
    input  wire rd_en,
    output wire empty,
    output wire [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] fifo_memory [0:(1 << ADDR_WIDTH) - 1];
    reg [DATA_WIDTH-1:0] data_out_reg;

    wire [ADDR_WIDTH-1:0] wr_addr;
    wire [ADDR_WIDTH-1:0] rd_addr;
    wire [ADDR_WIDTH:0] wr_ptr;
    wire [ADDR_WIDTH:0] rd_ptr;

    write_FIFO #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_write_domain (
        .rst    (rst),
        .clk    (clk),
        .wr_en  (wr_en),
        .wr_ptr (wr_ptr),
        .wr_addr(wr_addr),
        .rd_ptr (rd_ptr),
        .full   (full)
    );

    read_FIFO #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_read_domain (
        .rst    (rst),
        .clk    (clk),
        .rd_en  (rd_en),
        .rd_ptr (rd_ptr),
        .rd_addr(rd_addr),
        .wr_ptr (wr_ptr),
        .empty  (empty)
    );

    always @(posedge clk or negedge rst) begin
        if (!rst)
            data_out_reg <= {DATA_WIDTH{1'b0}};
        else begin
            if (wr_en && !full)
                fifo_memory[wr_addr] <= data_in;
            if (rd_en && !empty)
                data_out_reg <= fifo_memory[rd_addr];
        end
    end

    assign data_out = data_out_reg;

endmodule

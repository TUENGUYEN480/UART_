module write_FIFO #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input wire rst,
    input wire clk,
    input wire wr_en,
    input wire [ADDR_WIDTH:0] rd_ptr,
    output wire [ADDR_WIDTH:0] wr_ptr,
    output wire [ADDR_WIDTH-1:0] wr_addr,
    output wire full
);

    reg [ADDR_WIDTH:0] wr_ptr_reg, wr_ptr_next;

    // Sequential logic
    always @(posedge clk or negedge rst) begin 
        if (!rst) 
            wr_ptr_reg <= 0;
        else 
            wr_ptr_reg <= wr_ptr_next;
    end

    // Next state logic
    always @* begin
        if (wr_en && !full)
            wr_ptr_next = wr_ptr_reg + 1'b1;
        else
            wr_ptr_next = wr_ptr_reg;
    end

    // Full detection
    assign full = ((wr_ptr_reg[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
                   (wr_ptr_reg[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]));

    // Outputs
    assign wr_addr = wr_ptr_reg[ADDR_WIDTH-1:0];
    assign wr_ptr  = wr_ptr_reg;

endmodule

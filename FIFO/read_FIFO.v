module read_FIFO #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input wire rst,
    input wire clk,
    input wire rd_en,
    input wire [ADDR_WIDTH:0] wr_ptr,
    output wire [ADDR_WIDTH:0] rd_ptr,
    output wire [ADDR_WIDTH-1:0] rd_addr,
    output wire empty 
);

    reg [ADDR_WIDTH:0] rd_ptr_reg, rd_ptr_next;

    // Sequential logic
    always @(posedge clk or negedge rst) begin
        if (!rst)
            rd_ptr_reg <= 0;
        else
            rd_ptr_reg <= rd_ptr_next;
    end

    // Next state logic
    always @* begin
        if (rd_en && !empty)
            rd_ptr_next = rd_ptr_reg + 1'b1;
        else
            rd_ptr_next = rd_ptr_reg;
    end

    // Empty detection
    assign empty = (rd_ptr_reg == wr_ptr);

    // Outputs
    assign rd_ptr  = rd_ptr_reg;
    assign rd_addr = rd_ptr_reg[ADDR_WIDTH-1:0];

endmodule

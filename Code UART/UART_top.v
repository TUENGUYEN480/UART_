module UART_top #( 
    parameter DATA_BITS   = 8,
    parameter OVER_SAMPLE = 16,
    parameter CLK_FPGA = 50000000,
    parameter BAUDRATE =9600,
    parameter ADDR_WIDTH = 2
)
(
    input wire clk, // 50M
    input wire rst,
    input wire rd_uart , wr_uart , rx, 
    input wire [7:0] w_data, 
    output wire tx_full, rx_empty, tx, 
    output wire [7:0] r_data
);

    wire [7:0] data_i_uart, data_o_uart;
    wire tx_en, tx_empty,  tx_not_empty;
    wire stick, tx_done_o, rx_done_o;

    assign tx_not_empty = ~ tx_empty ;
        
Baudrate_Generater  #(
    .CLK_FPGA(CLK_FPGA),
    .BAUDRATE(BAUDRATE)
) Baudrate_Generater_unit
(
    .clk   (clk),
    .rst   (rst),
    .stick (stick)
);

FIFO_sync #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_BITS)
) FIFO_TX_unit_ins (
    .clk        (clk),
    .rst        (rst),
    .wr_en      (wr_uart),   // chua
    .data_in    (w_data),
    .full       (tx_full),   
    .rd_en      (tx_done_o),
    .empty      (tx_empty),
    .data_out   (data_i_uart)
);

TX_UART #(
    .DATA_BITS  (DATA_BITS)  ,
    .OVER_SAMPLE(OVER_SAMPLE) 
)TX_UART_ins (
    .clk        (clk),
    .rst        (rst),
    .tx_en_i    (tx_not_empty),
	.stick      (stick),
    .data_i     (data_i_uart),
    .tx_o       (tx),
    .tx_done_o  (tx_done_o)
);

RX_UART #(
    .DATA_BITS  (DATA_BITS)  ,
    .OVER_SAMPLE(OVER_SAMPLE) 
) RX_UART_ins(
    .clk        (clk),
    .rst        (rst),
    .rx_i       (rx),
	.stick      (stick),
    .data_o     (data_o_uart), // luu y
    .rx_done_o  (rx_done_o)
);

FIFO_sync#(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_BITS)
) FIFO_RX_unit_ins (  
    .clk        (clk),
    .rst        (rst),
    .wr_en      (rx_done_o),   
    .data_in    (data_o_uart),
    .full       (),   
    .rd_en      (rd_uart),
    .empty      (rx_empty),
    .data_out   (r_data)
);

endmodule 


module Baudrate_Generater #(
    parameter CLK_FPGA = 50000000,
    parameter BAUDRATE =9600
)
(
    input  wire clk,
    input  wire rst,
    output wire stick
);
    reg [8:0] count;
    reg [8:0] count_next;
	reg stick_reg;
    localparam integer baudrate_div = CLK_FPGA / (BAUDRATE * 16) - 1;

always@* begin 
    if(count == baudrate_div) begin 
        count_next = 0;
        stick_reg = 1'b1;
    end else begin 
        count_next = count+1;
        stick_reg = 1'b0;
    end 
end

assign stick = stick_reg;
always@(posedge clk) begin 
    if(!rst)  count <= 9'd0; 
    else      count <= count_next;
end 
endmodule 
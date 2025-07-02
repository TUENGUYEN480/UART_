module RX_UART #( 
parameter DATA_BITS   = 8,
parameter OVER_SAMPLE = 16
)
(
    input wire clk, // 50M
    input wire rst,
    input wire rx_i,
	input wire stick,
    output reg [DATA_BITS-1:0]data_o, // luu y
    output reg rx_done_o
);
//-----------------------------------
reg [4:0] state      , state_next;          // trang thai 
reg [2:0] rd_bit_reg , rd_bit_next;         // so bit hien tai
reg [3:0] stick_reg  , stick_next;          // dem so lan lay mau
reg [DATA_BITS-1:0] data_o_reg,data_o_next; // data
reg rx_done_o_next; 
//------------------------------------

localparam IDLE  = 5'b00001 ;
localparam START = 5'b00010 ;
localparam READ  = 5'b00100 ;
localparam PARITY  = 5'b01000 ;
localparam STOP  = 5'b10000 ;
//------------------------------------

//------------------------------------
//kiểm tra cạnh xuống 
reg rx_0, rx_1, rx_2, rx_3;
wire flag_start;
    assign flag_start = rx_3 & rx_2 & (~rx_1) &(~rx_0);
    always @(posedge clk) begin 
        if (!rst) begin
            rx_0 <=1 ;
            rx_1 <=1 ;
            rx_2 <=1 ;
            rx_3 <=1 ;
        end else begin 
            rx_0 <= rx_i;
            rx_1 <= rx_0;
            rx_2 <= rx_1;
            rx_3 <= rx_2;  
        end 
    end 
//-------------------------------------
//FSMD
    always @( posedge clk or negedge rst) begin
        if (!rst) begin 
            state <= IDLE; 
            stick_reg  <= 0; 
            rd_bit_reg <= 0; 
            data_o_reg <= 0;
            rx_done_o  <= 0;
            
        end else begin 
            state      <= state_next ; 
            stick_reg  <= stick_next ; 
            rd_bit_reg <= rd_bit_next; 
            data_o_reg <= data_o_next; 
            rx_done_o  <= rx_done_o_next;
        end
end 
//FSM next-state logic 
    always @* begin 
        state_next  = state;
        stick_next  = stick_reg;
        rd_bit_next = rd_bit_reg;
        data_o_next = data_o_reg;
        rx_done_o_next = 0;
        case (state)
            IDLE: begin
                if (flag_start) begin 
                    state_next = START;
                    stick_next = 1'b0;
                end 
            end 
            START: begin 
                if (stick) begin 
                    if(stick_reg==7) begin
                        if (rx_i==0) begin
                            state_next  = READ;
                            stick_next  = 0;
                            rd_bit_next = 0;
                        end else begin 
                            state_next = IDLE;
                            stick_next = 0;
                        end
                    end else begin
                         stick_next= stick_reg + 1;
                         state_next = START;
                    end          
                end
            end 
            READ: begin 
                if (stick) begin 
                    if (stick_reg == OVER_SAMPLE-1) begin
                        data_o_next[rd_bit_reg] = rx_i;
                        if (rd_bit_reg == DATA_BITS-1) begin
                            state_next = PARITY;
                        end else begin 
                            rd_bit_next = rd_bit_reg + 1;
                            state_next = READ;
                        end  
                    end else begin
                         stick_next= stick_reg + 1'b1;
                         state_next = READ;
                    end
                end
            end
            PARITY: begin 
                if (stick) begin 
                    if (stick_reg == OVER_SAMPLE-1) begin
                        if (^data_o_reg == rx_i) begin
                            state_next = STOP; 
                         end else begin
                            state_next = IDLE; // Parity lỗi
                        end
                    end else begin
                         stick_next= stick_reg + 1'b1;
                         state_next = PARITY;
                    end
                end
            end 
            STOP: begin 
                if (stick) begin 
                    if (stick_reg == OVER_SAMPLE-1) begin
                        if (rx_i==1) begin 
                             rx_done_o_next = 1;
                             data_o = data_o_reg;
                        end else begin         
                            rx_done_o_next = 0;
                        end
                    state_next = IDLE;
                     end else begin
                         stick_next= stick_reg + 1'b1;
                         state_next = STOP;
                    end
                end
            end
            default: state_next = IDLE;
        endcase
    end 
endmodule 
 
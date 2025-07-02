module TX_UART #( 
parameter DATA_BITS   = 8,
parameter OVER_SAMPLE = 16
)
(
    input wire clk, // 50M
    input wire rst,
    input wire tx_en_i,
	input wire stick,
    input wire [DATA_BITS-1:0]data_i, // luu y
    output wire tx_o,
    output reg tx_done_o
);
//-----------------------------------
reg [4:0] state      , state_next;          // trang thai 
reg [2:0] wr_bit_reg , wr_bit_next;         // so bit hien tai
reg [3:0] stick_reg  , stick_next;          // dem so lan lay mau
reg [DATA_BITS-1:0] data_i_reg, data_i_next; // data
reg tx_reg , tx_next ; 
reg tx_done_o_next;
reg parity, parity_next;
//------------------------------------

localparam IDLE   = 5'b00001;
localparam START  = 5'b00010;
localparam WRITE  = 5'b00100;
localparam PARITY = 5'b01000;
localparam STOP   = 5'b10000;

//------------------------------------
//FSMD
    assign tx_o = tx_reg;
    always @( posedge clk or negedge rst) begin
        if (!rst) begin 
            state <= IDLE; 
            stick_reg  <= 0; 
            wr_bit_reg <= 0; 
            data_i_reg <= 0;
            tx_done_o  <= 0;
            tx_reg     <= 1;
            parity     <= 0;      
        end else begin 
            state      <= state_next ; 
            stick_reg  <= stick_next ; 
            wr_bit_reg <= wr_bit_next; 
            data_i_reg <= data_i_next; 
            tx_done_o  <= tx_done_o_next;
            tx_reg    <= tx_next;
            parity     <= parity_next;
        end
    end 
////FSM next-state logic 
    always @* begin 
        state_next  = state;
        stick_next  = stick_reg;
        wr_bit_next = wr_bit_reg;
        data_i_next = data_i_reg;
        tx_next = tx_reg;
        parity_next    = parity;
        tx_done_o_next = 0;

        case (state)
            IDLE: begin 
                 if (tx_en_i) begin 
                    data_i_next= data_i;
                    parity_next  = ^data_i_reg;
                    state_next = START;
                    stick_next = 1'b0;
                 end else begin 
                    state_next = IDLE;
                 end 
            end 

            START: begin 
                tx_next = 0;
                if (stick) begin 
                    if(stick_reg== OVER_SAMPLE -1) begin
                            state_next  = WRITE;
                            stick_next  = 0;
                            wr_bit_next = 0;
                    end else begin
                         stick_next= stick_reg + 1;
                         state_next = state;
                    end          
                end else begin
                        state_next = state;
                end
            end
            
            WRITE: begin 
                tx_next = data_i_reg[0];
                if (stick) begin 
                    if(stick_reg== OVER_SAMPLE -1) begin
                        stick_next  = 0;
                        data_i_next = data_i_reg >> 1;
                        if (wr_bit_reg == DATA_BITS-1) begin
                             state_next = PARITY;
                             wr_bit_next = 0;
                        end else begin 
                            wr_bit_next = wr_bit_reg + 1;
                        end
                    end else begin 
                        stick_next = stick_reg + 1;
                    end 
                end else state_next = state;
            end 

            PARITY:begin
                tx_next = parity;
                 if (stick) begin 
                    if(stick_reg== OVER_SAMPLE -1) begin
                        stick_next  = 0;
                        state_next  = STOP;
                    end else begin 
                        stick_next = stick_reg + 1;
                    end 
                    end else state_next = state;
            end 

            STOP: begin 
                tx_next = 1'b1;
                if (stick) begin 
                    if(stick_reg== OVER_SAMPLE -1) begin
                        stick_next  = 0;
                        tx_done_o_next = 1;
                        state_next  = IDLE;
                    end else begin 
                        stick_next = stick_reg + 1;
                    end 
                    end else state_next = state;
            end 
        endcase 
    end 
endmodule 









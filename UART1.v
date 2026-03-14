module uart #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD = 9600
)(
    input clk,
    input rst,
    input t_start,
    input [7:0] t_data,
    output reg t_line,
    output reg t_busy
);

parameter CLK_PER_BIT = CLK_FREQ / BAUD;

reg [2:0] state;
localparam IDLE = 3'b000, START = 3'b001, DATA = 3'b010, STOP = 3'b011;

reg [15:0] clk_count;
reg [7:0] data_copy;
reg [2:0] bit_index;

always@(posedge clk or posedge rst)begin
    if(rst)begin
        state<=IDLE;
        bit_index<=0;
        data_copy<=0;
        clk_count<=0;
        t_line<=1'b1;
        t_busy<=0;
    end
    else begin
        case(state)
        IDLE : begin
            t_line<=1'b1;
            t_busy<=0;
            clk_count<=0;
            bit_index<=0;

            if(t_start == 1)begin
                state<=START;
                t_busy<=1;
                data_copy<=t_data;
            end
        end
        START : begin
            t_line<=0; // start bit
            
            if(clk_count < CLK_PER_BIT-1)begin
                clk_count<=clk_count+1;
            end
            else begin
                clk_count<=0;
                state<=DATA;
            end
        end
        DATA : begin
            t_line<=t_data[bit_index];

            if(clk_count < CLK_PER_BIT-1)begin
                clk_count<=clk_count+1;
            end
            else begin
                clk_count<=0;
            end

            if(bit_index < 7)begin
                bit_index<=bit_index+1;
            end
            else begin
                bit_index<=0;
                state<=STOP;
            end
        end
        STOP : begin
            t_line<=1; // stop bit
            if(clk_count < CLK_PER_BIT-1)begin
                clk_count<=clk_count+1;
            end
            else begin
                clk_count<=0;
                state<=IDLE;
            end
        end
        default : state<=IDLE;
        endcase
    end
end



endmodule
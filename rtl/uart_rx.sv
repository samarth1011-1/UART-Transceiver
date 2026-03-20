module uart_rx #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000
)(
    input logic clk,
    input logic rst,
    input logic r_line, // receive channel 
    output logic [7:0] r_data // 8-bit received data
);

localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;

logic [1:0] state; // used to keep track of state
localparam IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11; // all the states

logic [15:0] clk_count; // internal clock - counts upto CLK_PER_BIT - 1
logic [2:0]  bit_index; // to keep track of data bits
logic [7:0]  shift_reg; // 8-bit shift register 

always_ff @(posedge clk or posedge rst)begin
    if(rst)begin
        state<=IDLE;
        bit_index<=0;
        r_data<=8'b0;
        clk_count<=0;
    end
    else begin
        case(state)
        IDLE : begin
            bit_index<=0;
            clk_count<=0;
            if(r_line == 0)begin
                state<=START;
            end
        end
        START : begin
            if(clk_count < (CLK_PER_BIT/2)-1)begin // wait for half clock period to sample
                clk_count<=clk_count+1;
            end
            else begin
                clk_count<=0;
                if(r_line == 0) state<=DATA; // check if r_line is still LOW
                else state<=IDLE; // revert back if not
            end
        end
        DATA : begin           
            if(clk_count < CLK_PER_BIT-1)begin
                clk_count<=clk_count+1;
            end
            else begin
                shift_reg[bit_index] <= r_line;
                clk_count<=0;
                if(bit_index < 7) bit_index<=bit_index+1;
                else begin
                    bit_index<=0;
                    state<=STOP;
                end
            end
        end
        STOP : begin
            if(clk_count < CLK_PER_BIT-1)begin
                clk_count<=clk_count+1;
            end
            else begin
                clk_count<=0;
                r_data<=shift_reg;
                state<=IDLE;
            end
        end
        default : state<=IDLE;
        endcase
    end
end
endmodule
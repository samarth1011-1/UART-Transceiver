module uart_top#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input logic top_clk,
    input logic top_rst,
    input logic tx_start,
    input logic [7:0] input_data,
    output logic [7:0] received_data
);

logic tx_line, tx_busy;


uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) UUT(
    .clk(top_clk),
    .rst(top_rst),
    .t_start(tx_start),
    .t_data(input_data),
    .t_line(tx_line),
    .t_busy(tx_busy)
);

uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) DUT(
    .clk(top_clk),
    .rst(top_rst),
    .r_line(tx_line),
    .r_data(received_data)
);


endmodule
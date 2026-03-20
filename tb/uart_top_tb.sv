`timescale 1ns/1ps

module uart_top_tb;

localparam CLK_FREQ = 50000000;
localparam BAUD_RATE = 9600;
localparam CLK_PERIOD = 20;
localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
localparam BIT_NS = CLK_PER_BIT * CLK_PERIOD;
localparam FRAME_NS = 10 * BIT_NS;
localparam NUM_TESTS = 8;

logic clk, rst, start;
logic [7:0] inputdata;
logic [7:0] outputdata;

logic [7:0] test_data  [NUM_TESTS] = '{
    8'hAA, 8'h55, 8'hFF, 8'h00,
    8'h0A, 8'hA5, 8'h01, 8'h80
};
string test_labels [NUM_TESTS] = '{"alternating 10", "alternating 01","all ones",
"all zeros","lower nibble","mixed","LSB only","MSB only"};

uart_top #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) DUT (
    .top_clk(clk),
    .top_rst(rst),
    .input_data(inputdata),
    .received_data(outputdata),
    .tx_start(start)
);

initial clk = 0;
always #(CLK_PERIOD/2) clk = ~clk;

int passed_test = 0;
int failed_test = 0;

initial begin
    #(20 * FRAME_NS);
    $fatal(1, "TIMEOUT -- simulation hung at %0t", $time);
end

task automatic drive_frame(input [7:0] exp_data);
    inputdata<= exp_data;
    start<= 1;
    #(CLK_PERIOD * 2);
    start <=0;
    #(FRAME_NS);
    #(BIT_NS * 2);
endtask

task automatic check_data(input [7:0] expected_data, input string label);
    drive_frame(expected_data);
    assert (outputdata == expected_data) begin
        $display("PASS | %-15s | Sent=0x%0h | Received=0x%0h",label, expected_data, outputdata);
        passed_test++;
    end else begin
        $error("FAIL | %-15s | Sent=0x%0h | Received=0x%0h",label, expected_data, outputdata);
        failed_test++;
    end
endtask

initial begin
    $dumpfile("uart_top.vcd");
    $dumpvars(0, uart_top_tb);

    rst = 1;
    start = 0;
    inputdata = 0;
    #(CLK_PERIOD * 10);
    rst = 0;
    #(CLK_PERIOD * 20);

    for (int i = 0; i < NUM_TESTS; i++)check_data(test_data[i], test_labels[i]);

    $display("-----------------------------------------------------------");
    $display("PASSED : %0d / %0d", passed_test, passed_test + failed_test);
    $display("FAILED : %0d / %0d", failed_test, passed_test + failed_test);
    $display("-----------------------------------------------------------");

    if (failed_test == 0) $display("ALL TESTS PASSED");
    else $fatal(1, "%0d TESTS FAILED", failed_test);

    $finish;
end

endmodule
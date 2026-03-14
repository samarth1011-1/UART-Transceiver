`timescale 1ns / 1ps

module uart_tb;

reg clk;
reg rst;
reg t_start;
reg [7:0] t_data;
wire t_line;
wire t_busy;

uart #(
    .CLK_FREQ(1000000),  
    .BAUD(9600)       
) dut (
    .clk(clk),
    .rst(rst),
    .t_start(t_start),
    .t_data(t_data),
    .t_line(t_line),
    .t_busy(t_busy)
);

always #500 clk = ~clk;

initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0, uart_tb);
    
    clk = 0;
    rst = 1;
    t_start = 0;
    t_data = 8'h00;
    
    #2000 rst = 0;
    
    #5000;
    t_data = 8'hAA;
    t_start = 1;
    #1000 t_start = 0;
    
    wait(!t_busy);
    
    #10000;
    t_data = 8'hAC;
    t_start = 1;
    #1000 t_start = 0;
    
    wait(!t_busy);
    #20000;
    
    $display("Simulation complete");
    $finish;
end

endmodule
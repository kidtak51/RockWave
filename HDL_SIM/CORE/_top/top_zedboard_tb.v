/*
 * *****************************************************************
 * File: top_zedboard_tb.v
 * Category: top_core
 * File Created: 2019/01/21 12:11
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/03/20 05:41
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/1/21	kidtak51	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

module top_zedboard_tb();

reg clk;
reg [12:0] gpio_pin_in;
wire [7:0] gpio_pin_out;
wire         hsync;
wire         vsync;
wire [3:0]   rdata;
wire [3:0]   gdata;
wire [3:0]   bdata;

wire [11:0] pc = u_top_zedboard.u_top_core.u_top_fetch.program_counter;

top_zedboard u_top_zedboard(
	.clk            (clk            ),
    .gpio_pin_in    (gpio_pin_in    ),
    .gpio_pin_out   (gpio_pin_out   ),
    .hsync          (hsync),
    .vsync          (vsync),
    .rdata          (rdata),
    .gdata          (gdata),
    .bdata          (bdata)
);

//clock
initial
    clk = 0;
always begin
    #4 clk = ~clk;
end

initial begin
    //initial
    $dumpfile("top_zedboard_tb.vcd");
    $dumpvars(0,top_zedboard_tb);

    // init input
    gpio_pin_in = 13'h0000;

    ////Core simulation start
    #500;
    gpio_pin_in = 13'h0200;

    #50000;
    $finish;
end

endmodule

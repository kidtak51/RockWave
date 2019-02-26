/*
 * *****************************************************************
 * File: top_zedboard_tb.v
 * Category: top_core
 * File Created: 2019/01/21 12:11
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/02/22 04:12
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
wire[7:0] led;

top_zedboard u_top_zedboard(
	.clk            (clk            ),
    .led            (led            )
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

    ////Core simulation start
    #50000000;
    $finish;
end

endmodule

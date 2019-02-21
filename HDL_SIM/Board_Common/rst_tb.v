/*
 * *****************************************************************
 * File: rst_tb.v
 * Category: Common
 * File Created: 2019/01/29 22:42
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/30 22:12
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/29	Takuya Shono	First Version
 * *****************************************************************
 */

`define STEP 5
`timescale 1ns/1ns

module rst_tb;
    reg clk;            // Global Clock
    reg rstin_n;        // Reset from Board
    wire rst_n;         //Global Reset

    //1周期1000unit
    parameter STEP = 1;
   
    ///////////////////////////////////////////////////////////////////
    // インスタンス
    rst U_rst(.*);

    ///////////////////////////////////////////////////////////////////
    // Clock
    initial
        clk = 1'b0;
    always begin
        #(`STEP) clk = ~clk;
    end


    ///////////////////////////////////////////////////////////////////
    // Test Bench
    initial begin
 
        rstin_n = 1'b0;

        @(posedge clk)
        @(posedge clk)

         #(1) rstin_n = 1'b1;
         #(`STEP*10)
         #(1) rstin_n = 1'b0;
         #(`STEP*10)
         #(1) rstin_n = 1'b1;
         #(`STEP*10)
         #(1) rstin_n = 1'b0;
         #(`STEP*10)

        $finish;
    end

    initial begin
       $dumpfile("rst.vcd");
       $dumpvars(0,rst_tb);
       $monitor(" STEP=%d\n rstin_n= %b\n rst_n=%b\n ",$time,rstin_n,rst_n);
    end

endmodule

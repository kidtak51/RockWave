/*
 * *****************************************************************
 * File: fnc_vgacontroller_tb.v
 * Category: GPIO
 * File Created: 2019/01/31 05:09
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/11 05:38
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   TestBench for fnc_gpio
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/31	Masaru Aoki	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

// ≒ 23.75MHz
`define STEP 42

module fnc_vgacontroller_tb;

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    // reg
    reg           module_en;      // Module Enable
    wire          hbrank;         // 水平帰線区間
    wire          vbrank;         // 垂直帰線区間

    // VRAM
    wire [19:0]   addr;           // VRAM アドレス
    reg  [11:0]   data;           // 画素データ

    // Display
    wire          hsync;          // 水平同期
    wire          vsync;          // 垂直同期
    wire [3:0]    rdata;          // R画素
    wire [3:0]    gdata;          // G画素
    wire [3:0]    bdata;          // B画素

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    fnc_vgacontroller U_fnc_vgacontroller(.*);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP/2) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// 画像データ
initial
    data = 12'h000;
always begin
    #(`STEP/2) data = addr;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("fnc_vgacontroller.vcd");
    $dumpvars(0,fnc_vgacontroller_tb);

    rst_n=0;
    module_en=0;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    @(posedge clk)
    @(posedge clk)
    module_en = 1'b1;

    #(`STEP*800*500*2);



    $display("All tests pass!!");
    $finish;
end

task assert_eq;
    input [15:0] a;
    input [15:0] b;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h)",a,b);
            #(`STEP*10)
            $stop;
        end
    end
endtask

endmodule

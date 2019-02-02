/*
 * *****************************************************************
 * File: fnc_gpio_tb.v
 * Category: GPIO
 * File Created: 2019/01/31 05:09
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/02/03 05:52
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

`define STEP 10

module fnc_gpio_tb;

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    reg  [15:0] gpio_pin_in;   // GPIO 端子 (入力)
    wire [ 7:0] gpio_pin_out;  // GPIO 端子 (出力)

    reg  [ 7:0] gpio_out;     // GPIO 出力状態
    wire [15:0] gpio_in;      // GPIO 入力状態

    reg [7:0]  dflt_st;       // デジタルフィルタ設定
    reg [7:0]  refclk_st;     // 分周クロック設定

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    fnc_gpio U_fnc_gpio(.*);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP/5) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("fnc_gpio.vcd");
    $dumpvars(0,fnc_gpio_tb);

    rst_n=0;
    gpio_pin_in = 0;
    gpio_out = 0;
    dflt_st = 5;
    refclk_st = 2;


    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    //////////////////////////////////////////////////////////////////
    // 出力
    gpio_out = 8'h55;
    #(`STEP)
    assert_eq(gpio_out,gpio_pin_out);

    gpio_out = 8'hAA;
    #(`STEP)
    assert_eq(gpio_out,gpio_pin_out);

    gpio_out = 8'hFF;
    #(`STEP)
    assert_eq(gpio_out,gpio_pin_out);

    gpio_out = 8'h00;
    #(`STEP)
    assert_eq(gpio_out,gpio_pin_out);

    //////////////////////////////////////////////////////////////////
    // 入力
    gpio_pin_in = 16'h5555;
    #(`STEP*15);
    assert_eq(gpio_pin_in,gpio_in);

    gpio_pin_in = 16'hAAAA;
    #(`STEP*15);
    assert_eq(gpio_pin_in,gpio_in);

    gpio_pin_in = 16'hFFFF;
    #(`STEP*15);
    assert_eq(gpio_pin_in,gpio_in);

    gpio_pin_in = 16'h0000;
    #(`STEP*15);
    assert_eq(gpio_pin_in,gpio_in);


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

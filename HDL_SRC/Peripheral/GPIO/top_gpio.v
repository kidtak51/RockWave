/*
 * *****************************************************************
 * File: top_gpio.v
 * Category: GPIO
 * File Created: 2019/03/03 11:09
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/06 04:48
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   GPIOブロック　TOP階層
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/03	Masaru Aoki	First Version
 * *****************************************************************
 */

module top_gpio(
    input               clk,        // Global Clock
    input               rst_n,      // Global Reset

    input  [ INNUM-1:0] gpio_pin_in,   // GPIO 端子 (入力)
    output [OUTNUM-1:0] gpio_pin_out,  // GPIO 端子 (出力)

    // Local BUS
    input               sel,        // Select this Memory Block
    input [AWIDTH-1:0]  addr,       // Address
    input [2:0]         we,         // Write Enable
    input [XLEN-1:0]    wdata,      // Write Data
    output [XLEN-1:0]   rdata       // Read Data
);
    `include "core_general.vh"

    parameter INNUM = 13;      // 入力端子 本数
    parameter OUTNUM = 8;      // 出力端子 本数

    // Connect Wire func & reg
    wire [OUTNUM-1:0] gpio_out;   // GPIO 出力状態
    wire [ INNUM-1:0] gpio_in;    // GPIO 入力状態
    wire [7:0]  dflt_st;          // デジタルフィルタ設定
    wire [7:0]  refclk_st;        // 分周クロック設定


    // func Block
    fnc_gpio #(.INNUM(INNUM),.OUTNUM(OUTNUM)) U_fnc_gpio(
        .clk(clk), .rst_n(rst_n),
        .gpio_pin_in(gpio_pin_in), .gpio_pin_out(gpio_pin_out),
        .gpio_in(gpio_in), .gpio_out(gpio_out),
        .dflt_st(dflt_st), .refclk_st(refclk_st)
    );

    // reg Block
    reg_gpio #(.INNUM(INNUM),.OUTNUM(OUTNUM)) U_reg_gpio(
        .clk(clk), .rst_n(rst_n),
        .sel(sel), .addr(addr),
        .we(we), .wdata(wdata),
        .rdata(rdata),
        .gpio_in(gpio_in), .gpio_out(gpio_out),
        .dflt_st(dflt_st), .refclk_st(refclk_st)
    );

endmodule

/*
 * *****************************************************************
 * File: fnc_gpio.v
 * Category: GPIO
 * File Created: 2019/01/31 04:27
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/02/03 06:09
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Function Block for GPIO
 *      メタステ対策 / デジタルフィルタを含む
 *      TODO:割り込み対応
 *      TODO:出力端子にPWM機能
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/31	Masaru Aoki	First Version
 * *****************************************************************
 */


module fnc_gpio(
    input clk,              // Global Clock
    input rst_n,            // Global Reset

    input  [ INNUM-1:0] gpio_pin_in,   // GPIO 端子 (入力)
    output [OUTNUM-1:0] gpio_pin_out,  // GPIO 端子 (出力)

    input  [OUTNUM-1:0] gpio_out,     // GPIO 出力状態
    output [ INNUM-1:0] gpio_in,      // GPIO 入力状態

    input [7:0]  dflt_st,       // デジタルフィルタ設定
    input [7:0]  refclk_st      // 分周クロック設定
);

    parameter INNUM = 16;      // 入力端子 本数
    parameter OUTNUM = 8;      // 出力端子 本数

    wire [INNUM-1:0] gpio_pin_in_sync;   // GPIO入力端子 同期後

    wire [INNUM-1:0] null_act_edge;      // 入力信号ActiveEdge
    wire [INNUM-1:0] null_inact_edge;    // 入力信号InActiveEdge

    wire        refclk;             // 分周クロック

    ////////////////////////////////////////////////////////////////////////////
    // 分周クロック
    ////////////////////////////////////////////////////////////////////////////

    // Reference Clock
    refclk #(.BW(8)) 
    U_refclk (
    .clk(clk), .rst_n(rst_n),
    .ref_st(refclk_st),
    .refclk(refclk)
    );

    ////////////////////////////////////////////////////////////////////////////
    // 入力端子

    // Syncronizer
    syncronizer #(.WIDTH(INNUM), .INIVAL(0)) 
    U_sync (
    .clk(clk), .rst_n(rst_n),
    .async_in(gpio_pin_in),
    .sync_out(gpio_pin_in_sync)
    );

    // Degital Filter
    genvar i;
    generate
        for(i = 0; i<INNUM; i=i+1) begin: DeigtalFilter
            dfilter #(.INIVAL(1'b0), .BW(8))
                U_dfilter (
                .clk(clk), .rst_n(rst_n),
                .data_in(gpio_pin_in_sync[i]),
                .pol(1'b0),
                .refclk(refclk),
                .flt_rise_st(dflt_st),
                .flt_fall_st(dflt_st),
                .data_out(gpio_in[i]),
                .act_edge(null_act_edge[i]),
                .inact_edge(null_inact_edge[i])
            );
        end
    endgenerate

    ////////////////////////////////////////////////////////////////////////////
    // 出力端子
    ////////////////////////////////////////////////////////////////////////////

    // 現状は何もしない
    assign gpio_pin_out = gpio_out;

endmodule

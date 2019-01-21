/*
 * *****************************************************************
 * File: dfilter.v
 * Category: Common
 * File Created: 2019/01/14 09:22
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/14 21:02
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   デジタルフィルタ
 *      入力信号にノイズフィルタをかける
 *      同時にActiveエッジ/InActiveエッジ信号も出力する
 *      メタステは除去しない
 *      
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/14	Masaru Aoki	First Version
 * *****************************************************************
 */

module dfilter(
    input  clk,         // Global Clock
    input  rst_n,       // Global Reset

    input  data_in,     // 入力信号

    input  pol,         // 出力信号の極性設定( 0: Low Active / 1: High Active)
    input  refclk,      // 参照クロック

    input [BW-1:0] flt_rise_st, // フィルタ時間設定(立ち上がり)
    input [BW-1:0] flt_fall_st, // フィルタ時間設定(立ち下がり)

    output reg data_out,        // 出力信号
    output act_edge,            // 出力信号(Activeエッジ 1clk pls)
    output inact_edge           // 出力信号(Inactiveエッジ 1clk pls)
);

    parameter INIVAL = 1'b0;            // リセット時の初期値
    parameter BW = 8;                   // フィルタ時間幅(Bit Width)

    ///////////////////////////////   REG   ///////////////////////////
    reg     data_out_1d;        // 出力信号 1clk delay
    reg [BW-1:0] flt_count;     // フィルタ時間カウンタ

    ///////////////////////////////   WIRE   ///////////////////////////
    wire [BW-1:0]   flt_st;         // フィルタ時間設定 （立ち上がり/立ち下がり)
    wire            flt_count_full; // フィルタ時間カウンタMax到達
    wire            rise_edge;      // 出力信号立ち上がりエッジ
    wire            fall_edge;      // 出力信号立ち下がりエッジ

    ///////////////////////////////
    // 入力信号にフィルタをかける
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            data_out <= INIVAL;
        else if(flt_count_full)
            data_out <= data_in;
        else
            data_out <= data_out;
    end

    ///////////////////////////////
    // フィルタ時間カウンタ
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            flt_count <= {BW{1'b0}};
        else if(refclk)
            if(flt_count_full)
                flt_count <= ~flt_st;
            else if(data_in ^ data_out)
                flt_count <= flt_count + 1'b1;
            else
                flt_count <= ~flt_st;
        else
            flt_count <= flt_count;
    end

    assign flt_st = data_out ? flt_fall_st : flt_rise_st;
    assign flt_count_full = (flt_count >= {BW{1'b1}}) & refclk;
      
    ///////////////////////////////
    // activeエッジ / inactiveエッジ作成
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            data_out_1d <= INIVAL;
        else
            data_out_1d <= data_out;
    end
    
    assign rise_edge = (~data_out_1d) &   data_out ;
    assign fall_edge =   data_out_1d  & (~data_out);

    // 立ち上がり/立ち下がり → active / inactive
    assign   act_edge = pol ? rise_edge : fall_edge;
    assign inact_edge = pol ? fall_edge : rise_edge;

endmodule


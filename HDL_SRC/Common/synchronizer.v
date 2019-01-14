/*
 * *****************************************************************
 * File: synchronizer.v
 * Category: Common
 * File Created: 2019/01/11 05:11
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/14 09:13
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   メタステーブル対策の同期モジュール
 *      外部信号のメタステ対策として使用する場合、INIVALはinactiveの
 *      値を指定すること (ex: ActiveLow信号 → INIVAL=1)
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/11	Masaru Aoki	First Version
 * *****************************************************************
 */

module syncronizer(
    input  clk,         // Global Clock
    input  rst_n,       // Global Reset
    input [WIDTH-1:0] async_in,    // 非同期入力
    output [WIDTH-1:0] sync_out    // 同期出力
);

    `include "core_general.vh"

    parameter WIDTH  = 32;              // データ幅
    parameter INIVAL = 32'h0000;        // リセット時の初期値

    reg [WIDTH-1:0] sync1, sync2;       // 同期用FF

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            sync1 <= INIVAL;
        else
            sync1 <= async_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            sync2 <= INIVAL;
        else
            sync2 <= sync1;
    end

    assign sync_out = sync2;

endmodule
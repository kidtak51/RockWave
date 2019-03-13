/*
 * *****************************************************************
 * File: fnc_vgacontroller.v
 * Category: VGA
 * File Created: 2019/03/10 06:58
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/13 05:00
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   VGA controller
 *       VRAMのPixelデータを使用して、VGAディスプレイに出力する
 *      入力クロックはピクセル周波数
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/10	Masaru Aoki	First Version
 * *****************************************************************
 */

module fnc_vgacontroller(
    input           clk,            // Pixel Clock
    input           rst_n,          // Global Reset

    // reg
    input           module_en,      // Module Enable
    output          hbrank,         // 水平帰線区間
    output          vbrank,         // 垂直帰線区間

    // VRAM
    output [19:0]   addr,           // VRAM アドレス
    input  [11:0]   data,           // 画素データ

    // Display
    output reg      hsync,          // 水平同期
    output reg      vsync,          // 垂直同期
    output [3:0]    rdata,          // R画素
    output [3:0]    gdata,          // G画素
    output [3:0]    bdata           // B画素
);

    // H TOTAL 800pixels
    parameter   H_PIXELS        = 640;
    parameter   H_FRONT_PORCH   = 16;
    parameter   H_SYNC          = 64;
    parameter   H_BACK_PORCH    = 80;

    // V TOTAL 640lines
    parameter   V_PIXELS        = 480;
    parameter   V_FRONT_PORCH   = 3;
    parameter   V_SYNC          = 4;
    parameter   V_BACK_PORCH    = 13;

    reg [9:0]   horcount;       // 水平カウンタ
    reg [9:0]   vercount;       // 垂直カウンタ
    reg [19:0]  addr;           // VRAMアドレス


    ////////////////////////////////////////////////////////////
    // 水平カウンタ
    //   PixelClockでカウントアップ
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            horcount <= 10'h000;
        else if( ~module_en )
            horcount <= 10'h000;
        else if( horcount_full)
            horcount <= 10'h000;
        else
            horcount <= horcount + 1'b1;
    end

    wire h_front_porch_end = (horcount == (H_FRONT_PORCH - 1));
    wire h_sync_end        = (horcount == (H_FRONT_PORCH + H_SYNC - 1));
    wire h_back_porch_end  = (horcount == (H_FRONT_PORCH + H_SYNC + H_BACK_PORCH - 1));
    wire horcount_full     = (horcount == (H_FRONT_PORCH + H_SYNC + H_BACK_PORCH + H_PIXELS - 1));

    // H sync : 水平同期信号 (NEGATIVE)
    //     外部出力なため、Reg出力
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            hsync <= 1'b1;
        else if( ~module_en )
            hsync <= 1'b1;
        else if(h_front_porch_end)
            hsync <= 1'b0;
        else if(h_sync_end)
            hsync <= 1'b1;
        else
            hsync <= hsync;
    end

    // 水平帰線区間
    //     regブロックでクロック乗り換えを行うので、wireで良い
    assign hbrank = (horcount < (H_FRONT_PORCH + H_SYNC + H_BACK_PORCH));

    ////////////////////////////////////////////////////////////
    // 垂直カウンタ
    //   horcount_fullでカウントアップ
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            vercount <= 10'h000;
        else if( ~module_en )
            vercount <= 10'h000;
        else if( vercount_full)
            vercount <= 10'h000;
        else if( horcount_full)
            vercount <= vercount + 1'b1;
        else
            vercount <= vercount;
    end

    wire v_front_porch_end = horcount_full & (vercount == (V_FRONT_PORCH - 1));
    wire v_sync_end        = horcount_full & (vercount == (V_FRONT_PORCH + V_SYNC - 1));
    wire v_back_porch_end  = horcount_full & (vercount == (V_FRONT_PORCH + V_SYNC + V_BACK_PORCH - 1));
    wire vercount_full     = horcount_full & (vercount == (V_FRONT_PORCH + V_SYNC + V_BACK_PORCH + V_PIXELS - 1));

    // V sync : 垂直同期信号 (POSITIVE)
    //     外部出力なため、Reg出力
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            vsync <= 1'b0;
        else if( ~module_en )
            vsync <= 1'b0;
        else if(v_front_porch_end)
            vsync <= 1'b1;
        else if(v_sync_end)
            vsync <= 1'b0;
        else
            vsync <= vsync;
    end

    // 垂直帰線区間
    //     regブロックでクロック乗り換えを行うので、wireで良い
    assign vbrank = (vercount < (V_FRONT_PORCH + V_SYNC + V_BACK_PORCH));

    ////////////////////////////////////////////////////////////
    // VRAMアドレスカウンタ
    //   画像領域でカウントアップ
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            addr <= 20'h00000;
        else if( ~module_en )
            addr <= 20'h00000;
        else if( vercount_full)
            addr <= 20'h00000;
        else if( ~vbrank & ~hbrank)
            addr <= addr + 1'b1;
        else
            addr <= addr;
    end

    // 画像データ
    assign {rdata,gdata,bdata} = data;

endmodule

/*
 * *****************************************************************
 * File: localbus.v
 * Category: LocalBus
 * File Created: 2019/03/03 15:04
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/15 05:04
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   LocalBusに接続されるDataMemory および 周辺回路を制御する
 *       ・各モジュールのセレクト信号の作成
 *       ・各モジュールのインスタンス
 *        を行う
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/03	Masaru Aoki	First Version
 * *****************************************************************
 */
module localbus(
    input               clk,                // Global clock
    input               rst_n,              // Global Resest

    // Local BUS
    input  [XLEN-1:0]   addr,               // Address (32bit)
    input  [XLEN-1:0]   qin,                // Write Data
    input  [2:0]        we,                 // Write Enable
    output [XLEN-1:0]   qout,               // Read Data

    // PIN output / input
    input  [ INNUM-1:0] gpio_pin_in,   // GPIO 端子 (入力)
    output [OUTNUM-1:0] gpio_pin_out,  // GPIO 端子 (出力)

    output    hsync,
    output    vsync,
    output [3:0]   rdata,
    output [3:0]   gdata,
    output [3:0]   bdata


);
    parameter INNUM = 13;      // 入力端子 本数
    parameter OUTNUM = 8;      // 出力端子 本数

    `include "core_general.vh"

    wire [XLEN-1:0] ram_qout;                  // 常時RAM read data
    wire [XLEN-1:0] ram_qout_sel;              // Selected RAM Read data out (領域選択されていないと0出力)
    wire [XLEN-1:0] gpio_qout_sel;             // Selected GPIO Read data out
    wire [XLEN-1:0] vga_qout_sel;              // Selected VRAM Read data out

    // Local BUS としてのReadData出力
    assign qout = ram_qout_sel | gpio_qout_sel | vga_qout_sel;

    wire  ram_sel   = ((addr & BASE_MASK) ==  RAM_BASE);
    wire  gpio_sel  = ((addr & BASE_MASK) == GPIO_BASE);
    wire  vga_sel   = ((addr & BASE_MASK) ==  VGA_BASE);


    ////////////////////////////////////////////////////////////////
    // RAM領域
    //    Xilinx Block RAMは常時選択なためsel信号を追加
    wire [2:0] ram_we = ram_sel ? we : 3'b000;
    assign ram_qout_sel = ram_sel ? ram_qout : {XLEN{1'b0}};

    ram U_data_memory(
        .clk    (clk),
        .rst_n  (rst_n),
        .addr   (addr[AWIDTH-1:0]),
        .qin    (qin),
        .we     (ram_we),
        .qout   (ram_qout)
    );

    ////////////////////////////////////////////////////////////////
    // GPIO領域
    top_gpio #(.INNUM(INNUM),.OUTNUM(OUTNUM))
    U_top_gpio(
        .clk            (clk),
        .rst_n          (rst_n),
        .sel            (gpio_sel),
        .addr           (addr[AWIDTH-1:0]),
        .wdata          (qin),
        .we             (we),
        .rdata          (gpio_qout_sel),
        .gpio_pin_in    (gpio_pin_in),
        .gpio_pin_out   (gpio_pin_out)
    );

    ////////////////////////////////////////////////////////////////
    // VGA領域
    top_vgacontroller U_top_vgacontroller(
        .clk            (clk),
        .rst_n          (rst_n),

        .hsync          (hsync),
        .vsync          (vsync),
        .rdata          (rdata),
        .gdata          (gdata),
        .bdata          (bdata),

        .sel            (vga_sel),
        .addr           (addr[18:0]),
        .qin            (qin),
        .we             (we),
        .qout           (vga_qout_sel)
    );


endmodule

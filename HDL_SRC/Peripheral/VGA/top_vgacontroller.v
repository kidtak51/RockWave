/*
 * *****************************************************************
 * File: top_vgacontroller.v
 * Category: VGA
 * File Created: 2019/03/12 04:06
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/13 04:03
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   VGAコントローラ TOP階層
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/12	Masaru Aoki	First Version
 * *****************************************************************
 */
module top_vgacontroller(
    input           clk,            // Global Clock
    input           rst_n,          // Global Reset

    // Display
    output          hsync,          // 水平同期
    output          vsync,          // 垂直同期
    output [3:0]    rdata,          // R画素
    output [3:0]    gdata,          // G画素
    output [3:0]    bdata,          // B画素

    // Local BUS
    input               sel,        // Select this Memory Block
    input [18:0]        addr,       // Address
    input [2:0]         we,         // Write Enable
    input [XLEN-1:0]    qin,      // Write Data
    output [XLEN-1:0]   qout       // Read Data
);
    `include "core_general.vh"

    wire            pixel_clk;
    wire [18:0]     addrb;
    wire [11:0]     datab;

    // Pixel Clock生成
    pll_pixelclock U_pll_pixelclock
    (
    // Clock out ports
    .pixelclk(pixel_clk),     // output pixelclk
    // Clock in ports
    .clk(clk));      // input clk

    fnc_vgacontroller U_fnc_vgacontroller(
        .clk            (pixel_clk),
        .rst_n          (rst_n),
        .module_en      (1'b1),
        .hbrank         (),
        .vbrank         (),
        .addr           (addrb),
        .data           (datab),
        .hsync          (hsync),
        .vsync          (vsync),
        .rdata          (rdata),
        .gdata          (gdata),
        .bdata          (bdata)
    );

    // VRAM
    // True Dual Port RAMで生成し、PORTB側をROMとして使用
    vram U_vram (
          .clka         (clk),
          .ena          (sel),
          .wea          (we),
          .addra        (addr),
          .dina         (qin),
          .douta        (qout),
          .clkb         (pixel_clk),
          .web          (1'b0),
          .addrb        (addrb),
          .dinb         (12'h000),
          .doutb        (datab)
    );


endmodule

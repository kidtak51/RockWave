/*
 * *****************************************************************
 * File: top_vgacontroller.v
 * Category: VGA
 * File Created: 2019/03/12 04:06
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/20 05:29
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
    input [XLEN-1:0]    addr,       // Address
    input [2:0]         we,         // Write Enable
    input [XLEN-1:0]    qin,        // Write Data
    output [XLEN-1:0]   qout        // Read Data
);
    `include "core_general.vh"

    wire            pixel_clk;
    wire [18:0]     addrb;
    wire [11:0]     datab;

    wire            vga_en;     // VGAモジュールイネーブル
    wire            vblank;     // 垂直ブランク 
    wire            hblank;     // 水平ブランク

    wire   reg_sel  = sel & ((addr & 32'h00F0_0000) == 32'h0000_0000);
    wire   vram_sel = sel & ((addr & 32'h00F0_0000) == 32'h0010_0000);

    assign qout = qout_reg | qout_vram;

    // Pixel Clock生成
`ifdef __ICARUS__
    assign pixel_clk = clk;
`else
    pll_pixelclock U_pll_pixelclock
    (
    // Clock out ports
    .pixelclk(pixel_clk),     // output pixelclk
    // Clock in ports
    .clk(clk));      // input clk
`endif

    fnc_vgacontroller U_fnc_vgacontroller(
        .clk            (pixel_clk),
        .rst_n          (rst_n),
        .module_en      (vga_en),
        .hblank         (hblank),
        .vblank         (vblank),
        .addr           (addrb),
        .data           (datab),
        .hsync          (hsync),
        .vsync          (vsync),
        .rdata          (rdata),
        .gdata          (gdata),
        .bdata          (bdata)
    );

    wire [XLEN-1:0] qout_reg;
    // reg Block
    reg_vga  U_reg_vga(
        .clk(clk), .rst_n(rst_n),
        .sel(reg_sel), .addr(addr),
        .we(we), .wdata(qin),
        .rdata(qout_reg),
        .vblank(vblank), .hblank(hblank),
        .vga_en(vga_en)
    );

    // VRAM
    // True Dual Port RAMで生成し、PORTB側をROMとして使用
    wire [11:0] douta;
    wire [XLEN-1:0] qout_vram = {{(XLEN-12){1'b0}},douta};

    vram U_vram (
          .clka         (clk),
          .ena          (vram_sel),
          .wea          (we[2]),
          .addra        (addr[18:0]),
          .dina         (qin[11:0]),
          .douta        (douta),
          .clkb         (pixel_clk),
          .web          (1'b0),
          .addrb        (addrb),
          .dinb         (12'h000),
          .doutb        (datab)
    );
endmodule

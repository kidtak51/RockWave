/*
 * *****************************************************************
 * File: reg_vga.v
 * Category: VGA
 * File Created: 2019/03/17 05:51
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/20 05:38
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Register Block for VGA
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/17	Masaru Aoki	First Version
 * *****************************************************************
 */
module reg_vga(
    input       clk,        // Global clock
    input       rst_n,      // Global Reset

    // Local BUS
    input               sel,        // Select this Memory Block
    input [XLEN-1:0]    addr,       // Address
    input [2:0]         we,         // Write Enable
    input [XLEN-1:0]    wdata,      // Write Data
    output [31:0]   rdata,      // Read Data

    // for func block
    output              vga_en,     // VGAモジュールイネーブル
    input               vblank,     // 垂直ブランク
    input               hblank      // 水平ブランク

);
    `include "core_general.vh"

    wire [ 7:0]     reg00;
    wire [ 7:0]     reg04;

    // WriteEnable at Position
    assign we_1st = (we[2] == 1'b1); // 1stByte: All Write Access
    assign we_2nd = (we == 3'b1_10) || (we == 3'b1_01);// 2ndByte:Word / HarlWord Access
    assign we_3rd = (we == 3'b1_10); // 3rdByte: Word Access
    assign we_4th = (we == 3'b1_10); // 4thByte: Word Access

    // Address Select
    wire adsel00 = ({addr[7:2],2'b00} == 8'h00) & sel;
    wire adsel04 = ({addr[7:2],2'b00} == 8'h04) & sel;

    // Write Enable for RW reg
    wire wenble00 = adsel00 & we_1st;

    assign rdata = 
        { 8'h00, 8'h00, 8'h00, reg00} |
        { 8'h00, 8'h00, 8'h00, reg04} 
        ;

    /////////////////////////////////////////////////////////////////
    assign reg00[0] = reg00_vga_en;
    assign reg00[7:1] = 7'h00;
    wire reg00_vga_en;
    reg_rw #(1) U_reg00_vga_en(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[0:0]), .we(wenble00), 
        .rdata(reg00_vga_en), .re(adsel00),
        .dataout(vga_en)
    );

    /////////////////////////////////////////////////////////////////
    assign reg04[0] = reg04_vblank;
    assign reg04[1] = reg04_hblank;
    assign reg04[7:2] = 6'h00;
    wire reg04_hblank;
    reg_ronly #(1) U_reg04_hblank(
        .clk(clk), .rst_n(rst_n),
        .datain(hblank),
        .rdata(reg04_hblank), .re(adsel04)
    );
    wire reg04_vblank;
    reg_ronly #(1) U_reg04_vblank(
        .clk(clk), .rst_n(rst_n),
        .datain(vblank),
        .rdata(reg04_vblank), .re(adsel04)
    );


endmodule

/*
 * *****************************************************************
 * File: reg_gpio.v
 * Category: GPIO
 * File Created: 2019/03/03 09:29
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/06 05:07
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Register Block for GPIO
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/03	Masaru Aoki	First Version
 * *****************************************************************
 */
module reg_gpio(
    input       clk,        // Global clock
    input       rst_n,      // Global Reset

    // Local BUS
    input               sel,        // Select this Memory Block
    input [AWIDTH-1:0]  addr,       // Address
    input [2:0]         we,         // Write Enable
    input [XLEN-1:0]    wdata,      // Write Data
    output [XLEN-1:0]   rdata,     // Read Data

    // for func block
    output [OUTNUM-1:0] gpio_out,   // GPIO 出力状態
    input  [ INNUM-1:0] gpio_in,    // GPIO 入力状態

    output [7:0]  dflt_st,          // デジタルフィルタ設定
    output [7:0]  refclk_st         // 分周クロック設定
);
    `include "core_general.vh"

    parameter INNUM = 16;      // 入力端子 本数
    parameter OUTNUM = 8;      // 出力端子 本数


    wire [ 7:0]     reg00;
    wire [ 7:0]     reg04;
    wire [ 7:0]     reg10;
    wire [ 4:0]     reg11;
    wire [ 7:0]     reg20;

    // WriteEnable at Position
    assign we_1st = (we[2] == 1'b1); // 1stByte: All Write Access
    assign we_2nd = (we == 3'b1_10) || (we == 3'b1_01);// 2ndByte:Word / HarlWord Access
    assign we_3rd = (we == 3'b1_10); // 3rdByte: Word Access
    assign we_4th = (we == 3'b1_10); // 4thByte: Word Access

    // Address Select
    wire adsel00 = ({addr[7:2],2'b00} == 8'h00) & sel;
    wire adsel04 = ({addr[7:2],2'b00} == 8'h04) & sel;
    wire adsel10 = ({addr[7:2],2'b00} == 8'h10) & sel;
    wire adsel11 = ({addr[7:2],2'b00} == 8'h10) & sel;
    wire adsel20 = ({addr[7:2],2'b00} == 8'h20) & sel;

    // Write Enable for RW reg
    wire wenble00 = adsel00 & we_1st;
    wire wenble04 = adsel04 & we_1st;
    wire wenble20 = adsel20 & we_1st;

    assign rdata = 
        { 8'h00, 8'h00, 8'h00, reg00} |
        { 8'h00, 8'h00, 8'h00, reg04} |
        { 8'h00, 8'h00, 8'h00, reg10} |
        { 8'h00, 8'h00, reg11, 8'h00} |
        { 8'h00, 8'h00, 8'h00, reg20} 
        ;

    reg_rw #(8) U_reg00(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble00), 
        .rdata(reg00), .re(adsel00),
        .dataout(dflt_st)
    );

    reg_rw #(8) U_reg04(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble04),
        .rdata(reg04), .re(adsel04),
        .dataout(refclk_st)
    );

    reg_ronly #(8) U_reg10(
        .clk(clk), .rst_n(rst_n),
        .datain(gpio_in[7:0]),
        .rdata(reg10), .re(adsel10)
    );

    reg_ronly #(5) U_reg11(
        .clk(clk), .rst_n(rst_n),
        .datain(gpio_in[12:8]),
        .rdata(reg11), .re(adsel11)
    );

    reg_rw #(8) U_reg20(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble20),
        .rdata(reg20),  .re(adsel20),
        .dataout(gpio_out)
    );

endmodule

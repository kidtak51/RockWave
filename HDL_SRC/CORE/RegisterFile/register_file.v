/*
 * *****************************************************************
 * File: register_file.v
 * Category: RegisterFile
 * File Created: 2018/12/23 05:38
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/12/23 06:59
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   Register File
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/23	Masaru Aoki	First Version
 * *****************************************************************
 */

module register_file (
    input   clk,                    // Clock
    input   rst_n,                  // Reset
    input   [XLEN-1:0] rddata,      // 入力データ
    input   [4:0] rdsel,            // RD 選択
    input   phase_writeback,        // データ書き込み
    input   [4:0] rs1sel,           // RS1 選択
    input   [4:0] rs2sel,           // RS2 選択

    output  [XLEN-1:0] rs1data,     // 出力データ (rs1)
    output  [XLEN-1:0] rs2data      // 出力データ (rs2)
    );

    `include "core_general.vh"


    // X0レジスタは、0固定値
    wire    [XLEN-1:0] x1out;       // 汎用レジスタ x1 out
    wire               selx1;       // 汎用レジスタ x1 select
    wire    [XLEN-1:0] x2out;       // 汎用レジスタ x2 out
    wire               selx2;       // 汎用レジスタ x2 select
    wire    [XLEN-1:0] x3out;       // 汎用レジスタ x3 out
    wire               selx3;       // 汎用レジスタ x3 select
    wire    [XLEN-1:0] x4out;       // 汎用レジスタ x4 out
    wire               selx4;       // 汎用レジスタ x4 select
    wire    [XLEN-1:0] x5out;       // 汎用レジスタ x5 out
    wire               selx5;       // 汎用レジスタ x5 select
    wire    [XLEN-1:0] x6out;       // 汎用レジスタ x6 out
    wire               selx6;       // 汎用レジスタ x6 select
    wire    [XLEN-1:0] x7out;       // 汎用レジスタ x7 out
    wire               selx7;       // 汎用レジスタ x7 select
    wire    [XLEN-1:0] x8out;       // 汎用レジスタ x8 out
    wire               selx8;       // 汎用レジスタ x8 select
    wire    [XLEN-1:0] x9out;       // 汎用レジスタ x9 out
    wire               selx9;       // 汎用レジスタ x9 select
    wire    [XLEN-1:0] x10out;      // 汎用レジスタ x10 out
    wire               selx10;      // 汎用レジスタ x10 select
    wire    [XLEN-1:0] x11out;      // 汎用レジスタ x11 out
    wire               selx11;      // 汎用レジスタ x11 select
    wire    [XLEN-1:0] x12out;      // 汎用レジスタ x12 out
    wire               selx12;      // 汎用レジスタ x12 select
    wire    [XLEN-1:0] x13out;      // 汎用レジスタ x13 out
    wire               selx13;      // 汎用レジスタ x13 select
    wire    [XLEN-1:0] x14out;      // 汎用レジスタ x14 out
    wire               selx14;      // 汎用レジスタ x14 select
    wire    [XLEN-1:0] x15out;      // 汎用レジスタ x15 out
    wire               selx15;      // 汎用レジスタ x15 select
    wire    [XLEN-1:0] x16out;      // 汎用レジスタ x16 out
    wire               selx16;      // 汎用レジスタ x16 select
    wire    [XLEN-1:0] x17out;      // 汎用レジスタ x17 out
    wire               selx17;      // 汎用レジスタ x17 select
    wire    [XLEN-1:0] x18out;      // 汎用レジスタ x18 out
    wire               selx18;      // 汎用レジスタ x18 select
    wire    [XLEN-1:0] x19out;      // 汎用レジスタ x19 out
    wire               selx19;      // 汎用レジスタ x19 select
    wire    [XLEN-1:0] x20out;      // 汎用レジスタ x20 out
    wire               selx20;      // 汎用レジスタ x20 select
    wire    [XLEN-1:0] x21out;      // 汎用レジスタ x21 out
    wire               selx21;      // 汎用レジスタ x21 select
    wire    [XLEN-1:0] x22out;      // 汎用レジスタ x22 out
    wire               selx22;      // 汎用レジスタ x22 select
    wire    [XLEN-1:0] x23out;      // 汎用レジスタ x23 out
    wire               selx23;      // 汎用レジスタ x23 select
    wire    [XLEN-1:0] x24out;      // 汎用レジスタ x24 out
    wire               selx24;      // 汎用レジスタ x24 select
    wire    [XLEN-1:0] x25out;      // 汎用レジスタ x25 out
    wire               selx25;      // 汎用レジスタ x25 select
    wire    [XLEN-1:0] x26out;      // 汎用レジスタ x26 out
    wire               selx26;      // 汎用レジスタ x26 select
    wire    [XLEN-1:0] x27out;      // 汎用レジスタ x27 out
    wire               selx27;      // 汎用レジスタ x27 select
    wire    [XLEN-1:0] x28out;      // 汎用レジスタ x28 out
    wire               selx28;      // 汎用レジスタ x28 select
    wire    [XLEN-1:0] x29out;      // 汎用レジスタ x29 out
    wire               selx29;      // 汎用レジスタ x29 select
    wire    [XLEN-1:0] x30out;      // 汎用レジスタ x30 out
    wire               selx30;      // 汎用レジスタ x30 select
    wire    [XLEN-1:0] x31out;      // 汎用レジスタ x31 out
    wire               selx31;      // 汎用レジスタ x31 select

    ////////////////////////////////////////////////////////////////////////////
    // RS1
     assign rs1data = selector(rs1sel,
                {XLEN{1'b0}},x1out,x2out,x3out,x4out,x5out,x6out,x7out,
                 x8out ,x9out ,x10out,x11out,x12out,x13out,x14out,x15out,
                 x16out,x17out,x18out,x19out,x20out,x21out,x22out,x23out,
                 x24out,x25out,x26out,x27out,x28out,x29out,x30out,x31out);

    ////////////////////////////////////////////////////////////////////////////
    // RS2
     assign rs2data = selector(rs2sel,
                {XLEN{1'b0}},x1out,x2out,x3out,x4out,x5out,x6out,x7out,
                 x8out ,x9out ,x10out,x11out,x12out,x13out,x14out,x15out,
                 x16out,x17out,x18out,x19out,x20out,x21out,x22out,x23out,
                 x24out,x25out,x26out,x27out,x28out,x29out,x30out,x31out);

    ////////////////////////////////////////////////////////////////////////////
    // RD
    assign selx1  = (rdsel == 5'b00001 ) & phase_writeback;
    assign selx2  = (rdsel == 5'b00010 ) & phase_writeback;
    assign selx3  = (rdsel == 5'b00011 ) & phase_writeback;
    assign selx4  = (rdsel == 5'b00100 ) & phase_writeback;
    assign selx5  = (rdsel == 5'b00101 ) & phase_writeback;
    assign selx6  = (rdsel == 5'b00110 ) & phase_writeback;
    assign selx7  = (rdsel == 5'b00111 ) & phase_writeback;
    assign selx8  = (rdsel == 5'b01000 ) & phase_writeback;
    assign selx9  = (rdsel == 5'b01001 ) & phase_writeback;
    assign selx10 = (rdsel == 5'b01010 ) & phase_writeback;
    assign selx11 = (rdsel == 5'b01011 ) & phase_writeback;
    assign selx12 = (rdsel == 5'b01100 ) & phase_writeback;
    assign selx13 = (rdsel == 5'b01101 ) & phase_writeback;
    assign selx14 = (rdsel == 5'b01110 ) & phase_writeback;
    assign selx15 = (rdsel == 5'b01111 ) & phase_writeback;
    assign selx16 = (rdsel == 5'b10000 ) & phase_writeback;
    assign selx17 = (rdsel == 5'b10001 ) & phase_writeback;
    assign selx18 = (rdsel == 5'b10010 ) & phase_writeback;
    assign selx19 = (rdsel == 5'b10011 ) & phase_writeback;
    assign selx20 = (rdsel == 5'b10100 ) & phase_writeback;
    assign selx21 = (rdsel == 5'b10101 ) & phase_writeback;
    assign selx22 = (rdsel == 5'b10110 ) & phase_writeback;
    assign selx23 = (rdsel == 5'b10111 ) & phase_writeback;
    assign selx24 = (rdsel == 5'b11000 ) & phase_writeback;
    assign selx25 = (rdsel == 5'b11001 ) & phase_writeback;
    assign selx26 = (rdsel == 5'b11010 ) & phase_writeback;
    assign selx27 = (rdsel == 5'b11011 ) & phase_writeback;
    assign selx28 = (rdsel == 5'b11100 ) & phase_writeback;
    assign selx29 = (rdsel == 5'b11101 ) & phase_writeback;
    assign selx30 = (rdsel == 5'b11110 ) & phase_writeback;
    assign selx31 = (rdsel == 5'b11111 ) & phase_writeback;
    
    reg_rw x1 (.clk(clk),.rst_n(rst_n),.wenble(selx1),.datain(rddata),.dataout(x1out));
    reg_rw x2 (.clk(clk),.rst_n(rst_n),.wenble(selx2),.datain(rddata),.dataout(x2out));
    reg_rw x3 (.clk(clk),.rst_n(rst_n),.wenble(selx3),.datain(rddata),.dataout(x3out));
    reg_rw x4 (.clk(clk),.rst_n(rst_n),.wenble(selx4),.datain(rddata),.dataout(x4out));
    reg_rw x5 (.clk(clk),.rst_n(rst_n),.wenble(selx5),.datain(rddata),.dataout(x5out));
    reg_rw x6 (.clk(clk),.rst_n(rst_n),.wenble(selx6),.datain(rddata),.dataout(x6out));
    reg_rw x7 (.clk(clk),.rst_n(rst_n),.wenble(selx7),.datain(rddata),.dataout(x7out));
    reg_rw x8 (.clk(clk),.rst_n(rst_n),.wenble(selx8),.datain(rddata),.dataout(x8out));
    reg_rw x9 (.clk(clk),.rst_n(rst_n),.wenble(selx9),.datain(rddata),.dataout(x9out));
    reg_rw x10(.clk(clk),.rst_n(rst_n),.wenble(selx10),.datain(rddata),.dataout(x10out));
    reg_rw x11(.clk(clk),.rst_n(rst_n),.wenble(selx11),.datain(rddata),.dataout(x11out));
    reg_rw x12(.clk(clk),.rst_n(rst_n),.wenble(selx12),.datain(rddata),.dataout(x12out));
    reg_rw x13(.clk(clk),.rst_n(rst_n),.wenble(selx13),.datain(rddata),.dataout(x13out));
    reg_rw x14(.clk(clk),.rst_n(rst_n),.wenble(selx14),.datain(rddata),.dataout(x14out));
    reg_rw x15(.clk(clk),.rst_n(rst_n),.wenble(selx15),.datain(rddata),.dataout(x15out));
    reg_rw x16(.clk(clk),.rst_n(rst_n),.wenble(selx16),.datain(rddata),.dataout(x16out));
    reg_rw x17(.clk(clk),.rst_n(rst_n),.wenble(selx17),.datain(rddata),.dataout(x17out));
    reg_rw x18(.clk(clk),.rst_n(rst_n),.wenble(selx18),.datain(rddata),.dataout(x18out));
    reg_rw x19(.clk(clk),.rst_n(rst_n),.wenble(selx19),.datain(rddata),.dataout(x19out));
    reg_rw x20(.clk(clk),.rst_n(rst_n),.wenble(selx20),.datain(rddata),.dataout(x20out));
    reg_rw x21(.clk(clk),.rst_n(rst_n),.wenble(selx21),.datain(rddata),.dataout(x21out));
    reg_rw x22(.clk(clk),.rst_n(rst_n),.wenble(selx22),.datain(rddata),.dataout(x22out));
    reg_rw x23(.clk(clk),.rst_n(rst_n),.wenble(selx23),.datain(rddata),.dataout(x23out));
    reg_rw x24(.clk(clk),.rst_n(rst_n),.wenble(selx24),.datain(rddata),.dataout(x24out));
    reg_rw x25(.clk(clk),.rst_n(rst_n),.wenble(selx25),.datain(rddata),.dataout(x25out));
    reg_rw x26(.clk(clk),.rst_n(rst_n),.wenble(selx26),.datain(rddata),.dataout(x26out));
    reg_rw x27(.clk(clk),.rst_n(rst_n),.wenble(selx27),.datain(rddata),.dataout(x27out));
    reg_rw x28(.clk(clk),.rst_n(rst_n),.wenble(selx28),.datain(rddata),.dataout(x28out));
    reg_rw x29(.clk(clk),.rst_n(rst_n),.wenble(selx29),.datain(rddata),.dataout(x29out));
    reg_rw x30(.clk(clk),.rst_n(rst_n),.wenble(selx30),.datain(rddata),.dataout(x30out));
    reg_rw x31(.clk(clk),.rst_n(rst_n),.wenble(selx31),.datain(rddata),.dataout(x31out));

    ////////////////////////////////////////////////////////////////////////////
    // function

   function[XLEN-1:0] selector;
        input[4:0] sel;
        input[XLEN-1:0] d0;
        input[XLEN-1:0] d1;
        input[XLEN-1:0] d2;
        input[XLEN-1:0] d3;
        input[XLEN-1:0] d4;
        input[XLEN-1:0] d5;
        input[XLEN-1:0] d6;
        input[XLEN-1:0] d7;
        input[XLEN-1:0] d8;
        input[XLEN-1:0] d9;
        input[XLEN-1:0] d10;
        input[XLEN-1:0] d11;
        input[XLEN-1:0] d12;
        input[XLEN-1:0] d13;
        input[XLEN-1:0] d14;
        input[XLEN-1:0] d15;
        input[XLEN-1:0] d16;
        input[XLEN-1:0] d17;
        input[XLEN-1:0] d18;
        input[XLEN-1:0] d19;
        input[XLEN-1:0] d20;
        input[XLEN-1:0] d21;
        input[XLEN-1:0] d22;
        input[XLEN-1:0] d23;
        input[XLEN-1:0] d24;
        input[XLEN-1:0] d25;
        input[XLEN-1:0] d26;
        input[XLEN-1:0] d27;
        input[XLEN-1:0] d28;
        input[XLEN-1:0] d29;
        input[XLEN-1:0] d30;
        input[XLEN-1:0] d31;
        begin
            case(sel)
                5'b00000: selector = d0;
                5'b00001: selector = d1;
                5'b00010: selector = d2;
                5'b00011: selector = d3;
                5'b00100: selector = d4;
                5'b00101: selector = d5;
                5'b00110: selector = d6;
                5'b00111: selector = d7;
                5'b01000: selector = d8;
                5'b01001: selector = d9;
                5'b01010: selector = d10;
                5'b01011: selector = d11;
                5'b01100: selector = d12;
                5'b01101: selector = d13;
                5'b01110: selector = d14;
                5'b01111: selector = d15;
                5'b10000: selector = d16;
                5'b10001: selector = d17;
                5'b10010: selector = d18;
                5'b10011: selector = d19;
                5'b10100: selector = d20;
                5'b10101: selector = d21;
                5'b10110: selector = d22;
                5'b10111: selector = d23;
                5'b11000: selector = d24;
                5'b11001: selector = d25;
                5'b11010: selector = d26;
                5'b11011: selector = d27;
                5'b11100: selector = d28;
                5'b11101: selector = d29;
                5'b11110: selector = d30;
                5'b11111: selector = d31;
                 default: selector = {XLEN{1'bx}};
            endcase
        end
    endfunction // selector


endmodule

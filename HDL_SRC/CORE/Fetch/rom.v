/*
 * *****************************************************************
 * File: rom.v
 * Category: Fetch
 * File Created: 2018/12/16 07:11
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/02/22 04:30
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   Instruction ROM
 *   Xilinxでは、BlockRAMを推察させる
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/02/22	Masaru Aoki	CoreGeneratorで生成したBlockRAMを使用する
 * 2019/02/19	Masaru Aoki	BlockRAMを推察させてからROM化する
 * 2018/12/16	Masaru Aoki	First Version
 * *****************************************************************
 */

module rom(
    input clk,                  // Global Clock
    input rst_n,                // Global Reset
    input [AWIDTH-1:0] addr,    // Address
    output [DWIDTH-1:0] qout       // Read  Data
);
    `include "core_general.vh"

    wire null_rsta_busy;

`ifndef __ICARUS__
// Xilinx Vivadoでは、Core Generaterで生成したBlockRAMを読み込む
// FW は、COEファイルで準備して CoreGeneraterで読み込むこと
    blk_mem_gen_0 U_ram (
        .clka(clk),                 // input wire clka
        .rsta(~rst_n),              // input wire rsta
        .wea(1'b0),                 // input wire [0 : 0] wea
        .addra(addr),               // input wire [11 : 0] addra
        .dina(32'h00000000),        // input wire [31 : 0] dina
        .douta(qout),               // output wire [31 : 0] douta
        .rsta_busy(null_rsta_busy)  // output wire rsta_busy
    );

`else
// iverilogではVerilog記述のRAMモジュールを使用する
// FWは、Hexファイルで準備して、top階層で$readmemhする

    v_rams_20c U_ram(
        .clk(clk),
        .we(1'b0),
        .addr(addr),
        .din(32'h00000000),
        .dout(qout)
    );
endmodule

module  v_rams_20c  (clk, we,  addr,  din,  dout);
    input  clk;
    input  we;
    input  [11:0]    addr;
    input  [31:0]    din;
    output  [31:0]    dout;
    reg  [31:0]  ram  [0:4095];
    reg  [31:0]  dout;
    
   
    always  @(posedge  clk) begin
        if  (we)
            ram[addr]  <=  din;
            
        dout  <=  ram[addr];
    end
`endif
endmodule

/*
 * *****************************************************************
 * File: rom_tb.v
 * Category: Fetch
 * File Created: 2018/12/16 07:28
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/12/20 04:42
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/16	Masaru Aoki	First Version
 * *****************************************************************
 */

module rom_tb;

`include "core_general.vh"

reg clk;
reg rst_n;
reg wenble;
reg [AWIDTH-1:0] addr;
wire [DWIDTH-1:0] q;

///////////////////////////////////////////////////////////////////
// インスタンス
rom test(
    .clk(clk), .rst_n(rst_n),
    .addr(addr),
    .qout(q)
);

///////////////////////////////////////////////////////////////////
// メモリロード
initial
    $readmemh("../../fw/rv32ui-p-addi.hex",test.mem,12'h000,12'hfff);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Sim
initial begin
    $dumpfile("rom_tb.vcd");
    $dumpvars(0,rom_tb);
    $monitor("%t: addr=%h  q=%h",$time,addr,q);

    rst_n = 0;
    addr = 0;
    @(posedge clk)
    rst_n = 1;
    @(posedge clk)
    addr ++;
    @(posedge clk)
    addr ++;
    @(posedge clk)
    addr ++;
    @(posedge clk)
    addr ++;

    $finish;
end

endmodule
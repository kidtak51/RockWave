/*
 * *****************************************************************
 * File: reg_rw_tb.v
 * Category: RegisterFile
 * File Created: 2018/11/25 06:43
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/11/27 05:16
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *    R/W レジスタ　テストベンチ
 * *****************************************************************
 * HISTORY:
 * Date      	By    	    Comments
 * ----------	----------  ----------------------------------------
 * 2018/11/25	Masaru Aoki	First Version
  * *****************************************************************
 */

module reg_rw_tb;

reg clk;
reg rst_n;
reg wenble;
reg [31:0] datain;
wire [31:0] dataout;

reg_rw test(
    clk, rst_n,
    wenble,
    datain, dataout
);

initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

initial begin
    $dumpfile("reg_rw.vcd");
    $dumpvars(0,reg_rw_tb);
    $monitor("%t: en=%b  in=%h out=%h",$time,wenble,datain,dataout);

    rst_n = 0;
    wenble = 0;
    datain = 32'h00000000;
    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    @(posedge clk)
    datain = 32'haaaaaaaa;
    @(posedge clk)
    wenble = 1;
    @(posedge clk)
    wenble = 0;

    @(posedge clk)
    datain = 32'h55555555;
    @(posedge clk)
    wenble = 1;
    @(posedge clk)
    wenble = 0;

    @(posedge clk)
    datain = 32'h00000000;
    @(posedge clk)
    wenble = 1;
    @(posedge clk)
    wenble = 0;

    @(posedge clk)
    datain = 32'hffffffff;
    @(posedge clk)
    wenble = 1;
    @(posedge clk)
    wenble = 0;

    $finish;
end

endmodule

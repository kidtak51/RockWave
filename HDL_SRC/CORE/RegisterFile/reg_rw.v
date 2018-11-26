/*
 * *****************************************************************
 * File: reg_rw.v
 * Category: RegisterFile
 * File Created: 2018/11/25 06:54
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/11/27 04:19
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *    R/W レジスタ
 * *****************************************************************
 * HISTORY:
 * Date      	By    	        Comments
 * ----------	--------------  ------------------------------------
 * 2018/11/25	Masaru Aoki     First Version
 * *****************************************************************
 */

module reg_rw (
    clk, rst_n,
    wenble,
    datain, dataout
    );

    parameter XLEN = 32;
    parameter INIVAL = {XLEN{1'b0}};

    input   clk;                    // Clock
    input   rst_n;                  // Reset
    input   wenble;                 // データ書き込み
    input   [XLEN-1:0] datain;      // 入力データ
    output  [XLEN-1:0] dataout;     // 出力データ

    reg     [XLEN-1:0] data;        // 値を保持するデータレジスタ

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            data <= INIVAL;
        else if(wenble)
            data <= datain;
        else
            data <= data;
    end

    assign dataout = data;

endmodule // reg_rw

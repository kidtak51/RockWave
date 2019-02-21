/*
 * *****************************************************************
 * File: refclk.v
 * Category: Common
 * File Created: 2019/01/14 10:11
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/14 10:56
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   参照クロック
 *      clk → 1/N → refclk
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/14	Masaru Aoki	First Version
 * *****************************************************************
 */

module refclk (
    input  clk,         // Global Clock
    input  rst_n,       // Global Reset

    output  refclk      // 参照クロック
);

    parameter BW = 'd8; // 分周カウンタビット幅
    parameter N = 8'h2; // 分周比

    reg [BW-1:0] count; // 分周カウンタ 
    wire count_full;    // カウンタfull    

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            count <= ~(N-'d1);
        else if(count_full)
            count <= ~(N-'d1);
        else
            count <= count + 1'b1;
    end

    assign count_full = (count == {BW{1'B1}});

    assign refclk = count_full;

endmodule // refclk 
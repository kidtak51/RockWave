/*
 * *****************************************************************
 * File: refclk.v
 * Category: Common
 * File Created: 2019/01/14 10:11
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/28 08:25
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   参照クロック
 *      clk → 1/(ref_st+1) → refclk
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/28	Masaru Aoki	分周比をポートから取得
 * 2019/01/14	Masaru Aoki	First Version
 * *****************************************************************
 */

module refclk (
    input  clk,         // Global Clock
    input  rst_n,       // Global Reset

    input  [BW-1:0] ref_st, // 分周比

    output  refclk      // 参照クロック
);

    parameter BW = 'd8; // 分周カウンタビット幅

    reg [BW-1:0] count; // 分周カウンタ 
    wire count_full;    // カウンタfull    

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            count <= {BW{1'b1}};
        else if(count_full)
            count <= ~(ref_st);
        else
            count <= count + 1'b1;
    end

    assign count_full = (count == {BW{1'b1}});

    assign refclk = count_full;

endmodule // refclk 

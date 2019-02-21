/*
 * *****************************************************************
 * File: rst.v
 * Category: Common
 * File Created: 2019/01/28 23:45
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/30 21:57
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:rst module
 *   立ち上がりは同期、立下りは非同期とする
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/28	Takuya Shono	First Version
 * *****************************************************************
 */

module rst(
    input  clk,         // Global Clock
    input  rstin_n,     // 外部からのReset入力
    output  rst_n       // Globall Reset
);
    reg rst_reg1;
    reg rst_reg2;

    always @ (posedge clk or negedge rstin_n)begin
        if(!rstin_n)
            rst_reg1 <= 1'b0;
          else
            rst_reg1 <= rstin_n;
    end

   always @ (posedge clk or negedge rstin_n)begin
        if(!rstin_n)
            rst_reg2 <= 1'b0;
         else
            rst_reg2 <= rst_reg1;
    end

    assign rst_n = rst_reg2;

    endmodule


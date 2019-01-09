/*
 * *****************************************************************
 * File: obuf.v
 * Category: instruction_decode
 * File Created: 2019/01/08 06:45
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/01/09 18:33
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   入力をFFを通して出力するバッファ回路
 *   ただし、OUT_FLIPFLOP_REMOVEをdefineすることでFFを通さずにスルーして出力することも可能
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/08	kidtak51	First Version
 * *****************************************************************
 */
module obuf
#(
    parameter WIDTH = 1'b1//FFのデータ幅
)
(
    input clk,//FFのクロック
    input rst_n,//FFの非同期リセット
    input en,//FFのenable信号
    input[WIDTH-1:0] d_in,//データ入力
    output[WIDTH-1:0] d_out//データ出力
);


`ifdef OUT_FLIPFLOP_REMOVE
    //FFなし
    assign d_out = d_in;
`else
    //FFあり
    reg[WIDTH-1:0] buffer_reg;
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            buffer_reg <= {WIDTH{1'b0}};
        end
        else if (en) begin
            buffer_reg <= d_in;
        end
        else begin
            buffer_reg <= buffer_reg;
        end
    end
    assign d_out = buffer_reg;
`endif

endmodule

/*
 * *****************************************************************
 * File: instruction_decode_output_buffer.v
 * Category: instruction_decode
 * File Created: 2019/01/08 06:45
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/01/08 20:52
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/08	kidtak51	First Version
 * *****************************************************************
 */
module obuf
#(
    parameter WIDTH = 1'b1,//FFのデータ幅
    parameter FF_EN = 1'b1//0にするとFFを通らずに出力
)
(
    input clk,//FFのクロック
    input rst_n,//FFの非同期リセット
    input en,//FFのenable信号
    input[WIDTH-1:0] d,//FFのデータ入力
    output[WIDTH-1:0] q//FFのデータ出力
);


generate
    //enable付FF
    if (FF_EN == 1'b1) begin
        reg[WIDTH-1:0] buffer_reg;
        always @(posedge clk, negedge rst_n) begin
            if (!rst_n) begin
                buffer_reg <= {WIDTH{1'b0}};
            end
            else if (en) begin
                buffer_reg <= d;
            end
            else begin
                buffer_reg <= buffer_reg;
            end
        end
        assign q = buffer_reg;
    end
    //FFなし
    else begin
        assign q = d;
    end
endgenerate

endmodule

/*
 * *****************************************************************
 * File: alu.v
 * Category: alu
 * File Created: 2018/12/19 23:48
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2018/12/28 14:05
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/19	Takuya Shono	First Version
 * *****************************************************************
 */

module alu (
    aluin1,
    aluin2,
    funct3,
    aluout
    );
    
    parameter XLEN = 32;

    input  wire [XLEN-1:0] aluin1;
    input  wire [XLEN-1:0] aluin2;
    input  wire [2:0] funct3;
    output wire [XLEN-1:0] aluout;

    function [XLEN-1:0] calc( 
        input [2:0] funct3,
        input [XLEN-1:0] aluin1,
        input [XLEN-1:0] aluin2
        );        
        begin
            case( funct3 )
                    3'b000  : calc = aluin1 + aluin2; //ADD 加算
 //                   3'b000  : calc = aluin1 - aluin2; //SUB 減算//2の補数
 //                   3'b001  : calc = aluin1 << aluin2; //SLL 左シフト//下位5bitマスク
 //                   3'b010  : calc = aluin1 + aluin2; //SLT 符号付きで大小比較＆結果をレジスタにロード
 //                   3'b011  : calc = aluin1 + aluin2; //SLTU 符号なしで大小比較＆結果をレジスタにロード
                    3'b100  : calc = aluin1 ^ aluin2; //排他的論理和
 //                   3'b101  : calc = aluin1 + aluin2; //右論理シフト
 //                   3'b101  : calc = aluin1 + aluin2; //左論理シフト
                    3'b110  : calc = aluin1 | aluin2; //OR 論理和                   
                    3'b111  : calc = aluin1 & aluin2; //論理積
                    default : calc = 32'hXXXX_XXXX;
            endcase
        end
    endfunction

    assign aluout = calc( funct3, aluin1, aluin2 );

endmodule // alu

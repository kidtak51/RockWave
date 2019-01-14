/*
 * *****************************************************************
 * File: alu.v
 * Category: alu
 * File Created: 2018/12/19 23:48
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/15 24:12
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
    input  [XLEN-1:0] aluin1, //alu入力信号1
    input  [XLEN-1:0] aluin2, //alu入力信号2
    input  [3:0] funct_alu, //alu演算器選択信号
    output [XLEN-1:0] aluout //alu演算結果信号
    );
    
    `include "core_general.vh"

    function [XLEN-1:0] calc( 
        input [XLEN-1:0] aluin1,
        input [XLEN-1:0] aluin2,
        input [3:0] funct_alu
        );

        begin
            case( funct_alu )
                   4'b0000  : calc = aluin1 + aluin2; //ADD//ADDI 加算
                   4'b1000  : calc = aluin1 - aluin2; //SUB 減算
                   4'b0001  : calc = aluin1 << aluin2[4:0]; //SLL//SLLI 左論理シフト
                   4'b1001  : calc = aluin1 << aluin2[4:0]; //SLL//SLLI 左論理シフト
                   4'b0100  : calc = aluin1 ^ aluin2; //XOR 排他的論理和
                   4'b1100  : calc = aluin1 ^ aluin2; //XOR 排他的論理和
                   4'b0101  : calc = aluin1 >> aluin2 [4:0]; //SRL//SRLI 右論理シフト
                   4'b1101  : calc = $signed(aluin1) >>> aluin2 [4:0]; //SRA//SRAI 右算術シフト
                   4'b0110  : calc = aluin1 | aluin2; //OR 論理和                   
                   4'b1110  : calc = aluin1 | aluin2; //OR 論理和                                      
                   4'b0111  : calc = aluin1 & aluin2; //AND 論理積
                   4'b1111  : calc = aluin1 & aluin2; //AND 論理積
                   default : calc = {XLEN{1'bx}};
            endcase
        end
    endfunction

    assign aluout = calc( aluin1, aluin2, funct_alu);

endmodule // alu

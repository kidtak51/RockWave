/*
 * *****************************************************************
 * File: alu.v
 * Category: alu
 * File Created: 2018/12/19 23:48
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/14 14:51
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
    funct_alu,
    aluout
    );
    
    parameter XLEN = 32;

    input  wire [XLEN-1:0] aluin1; //alu入力信号1
    input  wire [XLEN-1:0] aluin2; //alu入力信号2
    input  wire [3:0] funct_alu; //alu演算器選択信号
    output wire [XLEN-1:0] aluout; //alu演算結果信号

    function [XLEN-1:0] calc( 
        input [XLEN-1:0] aluin1,
        input [XLEN-1:0] aluin2,
        input [3:0] funct_alu
        );

        begin
            casex( funct_alu )
                   4'b0000  : calc = aluin1 + aluin2; //ADD//ADDI 加算
                   4'b1000  : calc = aluin1 - aluin2; //SUB 減算
                   4'bx001  : calc = aluin1 << aluin2[4:0]; //SLL//SLLI 左シフト
                   4'bx100  : calc = aluin1 ^ aluin2; //XOR 排他的論理和
                   4'b0101  : calc = aluin1 >> aluin2 [4:0]; //SRL//SRLI 右シフト
                   4'b1101  : calc = $signed(aluin1) >>> $signed(aluin2 [4:0]); //SRA//SRAI 右算術シフト
                   4'bx110  : calc = aluin1 | aluin2; //OR 論理和                   
                   4'bx111  : calc = aluin1 & aluin2; //AND 論理積
                   default : calc = 32'hxxxx_xxxx;
            endcase
        end
    endfunction

    assign aluout = calc( aluin1, aluin2, funct_alu);

endmodule // alu

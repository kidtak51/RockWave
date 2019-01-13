/*
 * *****************************************************************
 * File: alu.v
 * Category: alu
 * File Created: 2018/12/19 23:48
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/14 24:00
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

    input  wire signed [XLEN-1:0] aluin1; //alu入力信号1
    input  wire signed [XLEN-1:0] aluin2; //alu入力信号2
    input  wire [3:0] funct_alu; //alu演算器選択信号
    output wire [XLEN-1:0] aluout; //alu演算結果信号

    function [XLEN-1:0] calc( 
        input signed [XLEN-1:0] aluin1,
        input signed [XLEN-1:0] aluin2,
        input funct_alu
        );

        begin
            case( funct_alu )
                   4'b0000  : calc = aluin1 + aluin2; //ADD//ADDI 加算
                   4'b1000  : calc = aluin1 - aluin2; //SUB 減算
                   4'b0001  : calc = aluin1 << aluin2 [4:0]; //SLL//SLLI 左シフト
                   4'bX010  : calc = (aluin1 < aluin2)? 1:0; //SLT //SLTI
                   4'bX011  : calc = ($unsigned(aluin1) < $unsigned(aluin2))? 1:0; //SLTU //SLTIU
                   4'bX100  : calc = aluin1 ^ aluin2; //XOR//XORI 排他的論理和
                   4'b0101  : calc = aluin1 >> aluin2 [4:0]; //SRL//SRLI 右シフト
                   4'b1101  : calc = aluin1 >>> aluin2 [4:0]; //SRA//SRAI 右算術シフト
                   4'bX110  : calc = aluin1 | aluin2; //OR//ORI 論理和                   
                   4'bX111  : calc = aluin1 & aluin2; //AND//ANDI 論理積
                   default : calc = 32'hXXXX_XXXX;
            endcase
        end
    endfunction

    assign aluout = calc( aluin1, aluin2, funct_alu);

endmodule // alu

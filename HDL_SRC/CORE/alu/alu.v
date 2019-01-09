/*
 * *****************************************************************
 * File: alu.v
 * Category: alu
 * File Created: 2018/12/19 23:48
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/09 23:55
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
    funct7,
    aluout
    );
    
    parameter XLEN = 32;

    input  wire signed [XLEN-1:0] aluin1;
    input  wire signed [XLEN-1:0] aluin2;
    input  wire [2:0] funct3;
    input  wire funct7;
    output wire [XLEN-1:0] aluout;
    wire [3:0] funct73;

    assign funct73 = {funct7,funct3};
    
    function [XLEN-1:0] calc( 
        input [3:0] funct73,
        input signed [XLEN-1:0] aluin1,
        input signed [XLEN-1:0] aluin2
        );
        begin
            case( funct73 )
                   4'b0000  : calc = aluin1 + aluin2; //ADD 加算
                   4'b1000  : calc = aluin1 - aluin2; //SUB 減算
                   4'b0001  : calc = aluin1 << 5; //SLL 左シフト
                   4'b0100  : calc = aluin1 ^ aluin2; //XOR 排他的論理和
                   4'b0101  : calc = aluin1 >> 5; //SRL 右シフト
                   4'b1101  : calc = aluin1 >>> 5; //SRA 右算術シフト
                   4'b0110  : calc = aluin1 | aluin2; //OR 論理和                   
                   4'b0111  : calc = aluin1 & aluin2; //AND 論理積
                   default : calc = 32'hXXXX_XXXX;
            endcase
        end
    endfunction

    assign aluout = calc( funct73, aluin1, aluin2 );

endmodule // alu

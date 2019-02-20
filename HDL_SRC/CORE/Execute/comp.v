/*
 * *****************************************************************
 * File: top_execute_tb.v
 * Category: Execute
 * File Created: 2019/01/14 18:57
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/02/19 12:13
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/02/18   shonta      SLTIと分離するためdecoded_opにmust jumpを追加
 * 2019/01/14	shonta  	First Version
 * *****************************************************************
 */

module comp (
    input [XLEN-1:0] rs1data_de, //レジスタ選択結果1 rs1データ
    input [XLEN-1:0] rs2data_de, //レジスタ選択結果2 rs2データ
    input [OPLEN-1:0] decoded_op_de, // Decoded OPcode
    output comp_out //比較結果
    );

    //parameter
    `include "core_general.vh"

   wire [2:0] funct3 = decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L];

    function [XLEN-1:0] comp( 
        input [XLEN-1:0] rs1data_de,
        input [XLEN-1:0] rs2data_de,
        input [2:0] funct3
        );

        begin
            case( funct3 )
                   FUNCT3_BEQ   : comp = ( rs1data_de == rs2data_de )? 1:0 ; 
                   FUNCT3_BNE   : comp = ( rs1data_de != rs2data_de )? 1:0 ; 
                   //FUNCT3_JUMP  : comp = 1 ; //must jump SLTの追加により削除した
                   FUNCT3_BLT   : comp = ( $signed(rs1data_de) <  $signed(rs2data_de))? 1:0 ; 
                   FUNCT3_BGE   : comp = ( $signed(rs1data_de) >= $signed(rs2data_de))? 1:0 ;
                   FUNCT3_BLTU  : comp = ( rs1data_de < rs2data_de)? 1:0 ; 
                   FUNCT3_BGEU  : comp = ( rs1data_de >= rs2data_de)? 1:0 ;
                   FUNCT3_SLT   : comp = ( $signed(rs1data_de) < $signed(rs2data_de))? 1:0 ;
                   default : comp = 1'bx;
            endcase
        end
    endfunction

    assign comp_out = comp( rs1data_de, rs2data_de, funct3);

endmodule // comp

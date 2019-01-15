/*
 * *****************************************************************
 * File: comp.v
 * Category: Execute
 * File Created: 2019/01/14 18:57
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/16 24:33
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
 * 2019/01/14	Takuya Shono	First Version
 * *****************************************************************
 */

module comp (
    input [XLEN-1:0] rs1data_de, //レジスタ選択結果1 rs1データ
    input [XLEN-1:0] rs2data_de, //レジスタ選択結果2 rs2データ
    input [OPLEN-1:0] decoded_op_de, // Decoded OPcode
    output jamp_state_pre //比較結果
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
                   3'b000  : comp = ( rs1data_de == rs2data_de )? 1:0 ;
                   3'b001  : comp = ( rs1data_de != rs2data_de )? 1:0 ;
                   3'b010  : comp = ( $signed(rs1data_de) < rs2data_de)? 1:0 ;
                   3'b011  : comp = ( rs1data_de <  rs2data_de )? 1:0 ;
                   3'b100  : comp = ( $signed(rs1data_de) < rs2data_de)? 1:0 ;
                   3'b101  : comp = ( $signed(rs1data_de) >= rs2data_de)? 1:0 ; 
                   3'b110  : comp = ( rs1data_de < rs2data_de)? 1:0 ; 
                   3'b111  : comp = ( rs1data_de >= rs2data_de)? 1:0 ; 
                   default : comp = 1'bx;
            endcase
        end
    endfunction

    assign jamp_state_pre = comp( rs1data_de, rs2data_de, funct3);

endmodule // comp

/*
 * *****************************************************************
 * File: writeback.v
 * Category: Writeback
 * File Created: 2019/01/23 12:25
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/25 19:09
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
 * 2019/01/23	Takuya Shono	First Version
 * *****************************************************************
 */

module writeback(

    // From StateMachine
    input phase_writeback,             // writeback Phase
     // From Memory
    input jump_state_mw,               // PCの次のアドレスがJumpアドレス
    input [OPLEN-1:0] decoded_op_mw,   // Decoded OPcode
    input [4:0] rdsel_mw,              // RD選択
    input [XLEN-1:0] next_pc_mw,       // Next PC Address for Decode
    input [XLEN-1:0] alu_out_mw,       // ALU output
    input [XLEN-1:0] mem_out_mw,       // Data Memory output
 
    //For RegisterFile
    output [XLEN-1:0] rddata_wr,       //出力データ 
    output [4:0] rdsel_wr,             //RD選択
    //For Fetch
    output [XLEN-1:0] regdata_for_pc,  // jump先アドレス
    output jump_state_wf,              //PCの次のアドレスがJumpアドレス
   // For StateMachine
    output stall_writeback             // Stall writeback Phase  

);

    `include "core_general.vh"

    wire jump_en;       //jump許可
    wire [USE_RD_BIT_M-USE_RD_BIT_L:0] use_rd;  //データ出力選択
    wire [XLEN-1:0] jump_state_selin; //セレクタ入力用に[XLEN]bit拡張する

    assign rdsel_wr = rdsel_mw; 

    //selecter1
    assign jump_en = decoded_op_mw[JUMP_EN_BIT];
    assign jump_state_wf = (jump_en == 1'b1)?  jump_state_mw : 1'b0 ;
    
    //selecter2
    assign use_rd  = decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L]; 
    assign jump_state_selin = {{XLEN-1{1'b0}},jump_state_mw}; 

    function [XLEN-1:0] select;
        input [XLEN-1:0] mem_out_mw;        //データ入力1    
        input [XLEN-1:0] jump_state_selin;  //データ入力2    
        input [XLEN-1:0] next_pc_mw;        //データ入力3    
        input [XLEN-1:0] alu_out_mw;        //データ入力4
        input [USE_RD_BIT_M-USE_RD_BIT_L:0] use_rd;                 //セレクタ
            case( use_rd )
                USE_RD_ALU    : select = alu_out_mw;
                USE_RD_PC     : select = next_pc_mw;
                USE_RD_MEMORY : select = mem_out_mw;
                USE_RD_COMP   : select = jump_state_selin;
                default: select =  {XLEN{1'bx}};
            endcase
    endfunction

    assign rddata_wr = select( mem_out_mw, jump_state_selin, next_pc_mw, alu_out_mw, use_rd);

    assign stall_writeback = 1'b0;

endmodule //top_writeback

/*
 * *****************************************************************
 * File: top_execute.v
 * Category: Execute
 * File Created: 2019/01/16 23:22
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/21 12:14
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
 * 2019/01/16	Takuya Shono	First Version
 * *****************************************************************
 */

module top_execute(
    input clk,                       // Global Clock
    input rst_n,                     // Global Reset

    // From StateMachine
    input phase_execute,             // execute Phase
     // From Decorde
    input[XLEN-1:0] imm, //即値
    input[XLEN-1:0] rs1data_de, //レジスタ選択結果1
    input[XLEN-1:0] rs2data_de, //レジスタ選択結果2
    input[XLEN-1:0] curr_pc_de, //現在のプログラムカウンタの値
    input[XLEN-1:0] next_pc_de, //次のプログラムカウンタの値
    input[3:0] funct_alu, //alu演算器選択信号
    input[4:0] rdsel_de, //データメモリ選択信号
    input[OPLEN-1:0] decoded_op_de, //opcodeデコード結果、後段のaluやmemory_accessで使用することを想定
    
    // For Memory
    output [OPLEN-1:0] decoded_op_em, // Decoded OPcode
    output [XLEN-1:0] rs2data_em,     //レジスタ選択結果2
    output jump_state_em,             // PCの次のアドレスがJumpアドレス
    output [4:0] rdsel_em,            // RD選択
    output [XLEN-1:0] next_pc_em,     // Next PC Address 
    output [XLEN-1:0] alu_out_em,     // ALU outp

   // For StateMachine
    output stall_execute        // Stall execute Phase    
);

    `include "core_general.vh"

    localparam LATCH_LEN = (XLEN*3+1+5+OPLEN);
    reg [LATCH_LEN-1:0] latch_execute; // Latch for Next Stage

    wire [XLEN-1:0] aluin1;
    wire [XLEN-1:0] aluin2;
    wire [XLEN-1:0] aluout_pre;

    wire jump_state_pre;
    wire use_rs1;
    wire use_rs2;

    //For alu
    assign aluin1 = ( use_rs1 == USE_RS1_RS1DATA)? rs1data_de : curr_pc_de;
    assign aluin2 = ( use_rs2 == USE_RS2_RS2DATA)? rs2data_de : imm;
    //For comp
    assign use_rs1 = decoded_op_de[USE_RS1_BIT];
    assign use_rs2 = decoded_op_de[USE_RS2_BIT];

    //call module alu
    alu U_alu(
       .aluin1(aluin1),
       .aluin2(aluin2),
       .funct_alu(funct_alu),
       .aluout(aluout_pre)
        );

    //call module comp
    comp U_comp(
        .rs1data_de(rs1data_de),
        .rs2data_de(rs2data_de),
        .decoded_op_de(decoded_op_de),
        .jump_state_pre(jump_state_pre)
    );

     /////////////////////////////////////////////
    // 次ステージのためのラッチ
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            latch_execute <= {LATCH_LEN{1'b0}};
        else if(phase_execute)
            latch_execute <= {next_pc_de,aluout_pre,jump_state_pre,decoded_op_de,rs2data_de,rdsel_de};
        else
            latch_execute <= latch_execute;
    end

    assign {next_pc_em,alu_out_em,jump_state_em,decoded_op_em,rs2data_em,rdsel_em} = latch_execute;

    /////////////////////////////////////////////
    // For statemachine
    //     現状Executeは1clkで終了する
    assign stall_execute = 1'b0;

endmodule //top_execute



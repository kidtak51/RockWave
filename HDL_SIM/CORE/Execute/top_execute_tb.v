/*
 * *****************************************************************
 * File: top_execute_tb.v
 * Category: Execute
 * File Created: 2019/01/16 23:45
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/19 21:59
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


`define STEP 5
`timescale 1ns/1ns

module top_execute_tb;
    `include "core_general.vh"

    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // From StateMachine
    reg phase_fetch;
    reg phase_decode;
    reg phase_execute;
    reg phase_memoryaccess;        
    reg phase_writeback;           // WriteBack Phase
     // From Decorde
    reg[XLEN-1:0] imm; //即値
    reg[XLEN-1:0] rs1data_de; //レジスタ選択結果1
    reg[XLEN-1:0] rs2data_de; //レジスタ選択結果2
    reg[XLEN-1:0] curr_pc_de; //現在のプログラムカウンタの値
    reg[XLEN-1:0] next_pc_de; //次のプログラムカウンタの値
    reg[3:0] funct_alu; //alu演算器選択信号
    reg[4:0] rdsel_de; //データメモリ選択信号
    reg[OPLEN-1:0] decoded_op_de; //opcodeデコード結果、後段のaluやmemory_accessで使用することを想定
    // For Memory
    wire [OPLEN-1:0] decoded_op_em; // Decoded OPcode
    wire jump_state_em;             // PCの次のアドレスがJumpアドレス
    wire [4:0] rdsel_em;            // RD選択
    wire [XLEN-1:0] next_pc_em;     // Next PC Address 
    wire [XLEN-1:0] alu_out_em;     // ALU wire
    wire [XLEN-1:0] rs2data_em;     // RS2data
     // For StateMachine
    wire stall_execute;        // Stall Execute Phase
    //For alu
    wire [XLEN-1:0] aluin1;     // alu入力
    wire [XLEN-1:0] aluin2;     // alu入力
    wire [XLEN-1:0] aluout_pre; // alu出力
    //For comp
    wire jump_state_pre; // comp出力

    integer i;

    ///////////////////////////////////////////////////////////////////
    // DUT インスタンス
    top_execute U_top_execute(.*);

    initial 
        clk = 0;
    always begin
        #(`STEP) clk = ~clk;
    end

    //////////////////////////////////////////////////
    // State Machine
    initial begin
        phase_fetch = 0;
        phase_decode = 0;
        phase_execute = 0;
        phase_memoryaccess = 0;
        phase_writeback = 0;
        @(posedge rst_n)
        phase_fetch <= 1;
    end
    always begin
        @(posedge clk)
        phase_fetch <= phase_writeback;
        phase_decode <= phase_fetch;
        phase_execute <= phase_decode;
        phase_memoryaccess  <= phase_execute;
        phase_writeback <= phase_memoryaccess;
    end

    //////////////////////////////////////////////////
    // Test Bench
    initial begin   
        rst_n=0;
        imm = 0;
        rs1data_de = 0;
        rs2data_de = 0;
        curr_pc_de = 0;
        next_pc_de = 10;
        funct_alu = 0;
        rdsel_de = 0;
        decoded_op_de = 0;
 
        @(posedge clk)
        @(posedge clk)
        rst_n = 1;

        ////////////////////////////////////
        // ALU系動作確認
        ////////////////////////////////////
        @( posedge phase_decode)
        next_pc_de    = 32'hA0A0_A0A0;
        rdsel_de      = 32'h0A0A_0A0A;

        decoded_op_de[USE_RS1_BIT] = 1'b1;
        decoded_op_de[USE_RS2_BIT] = 1'b1;
        rs1data_de    = 32'hA0A0_A0A0;        curr_pc_de    = 32'h1010_1010;
        rs2data_de    = 32'h0A0A_0A0A;
        imm           = 32'h0101_0101;
        funct_alu     = 4'b0000;
        
        @( posedge phase_execute)
        #(1)
        assert_eq(next_pc_em, 32'hA0A0_A0A0, "next_pc_de->next_pc_em");
//        assert_eq(rdsel_em, 32'h0A0A_0A0A, "rdsel_de->rdsel_em");
//        assert_eq(alu_out_em, 32'hAAAA_AAAA, "rs1data_de+rs2data_de->alu_out_em");

//         @( posedge phase_execute)
//        #(1)
//        assert_eq(alu_out_em, 32'hA1A1_A1A1, //"rs1data_de+imm->alu_out_em");
//
//         @( posedge phase_execute)
//        #(1)
//        assert_eq(alu_out_em, 32'h1A1A_1A1A, //"curr_pc_de+rs2data_de->alu_out_em");
//
//         @( posedge phase_execute)
//        #(1)
//        assert_eq(alu_out_em, 32'h1111_1111, //"curr_pc_de+imm->alu_out_em");
//
        /////////////////////////////////////////
        //comp系動作確認
        /////////////////////////////////////////
        

    $finish;
end

    task assert_eq;
        input [XLEN-1:0] a;
        input [XLEN-1:0] b;
        input [0:8*50-1] message;
        begin
            if( a === b) begin
                $display ("       OK (%h,%h,%s)", a, b, message);
            end
            else begin
                $display ("Assert NG (%h,%h,%s)", a, b, message);
                #(`STEP*10)
                $finish;
            end
        end
    endtask

endmodule
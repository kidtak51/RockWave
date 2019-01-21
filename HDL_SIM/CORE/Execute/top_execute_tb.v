/*
 * *****************************************************************
 * File: top_execute_tb.v
 * Category: Execute
 * File Created: 2019/01/16 23:45
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/21 12:26
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
    wire [XLEN-1:0] aluout_pre; // alu出力 //FF前段
    //For comp
    wire jump_state_pre; // comp出力 //FF前段

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
        rst_n=1'b0;
        imm = 32'h0000_0000;
        rs1data_de = 32'h0000_0000;
        rs2data_de = 32'h0000_0000;
        curr_pc_de = 32'h0000_0000;
        next_pc_de = 32'h0000_0000;
        funct_alu = 4'b0000;
        rdsel_de = 5'b0_0000;
        decoded_op_de = 9'b0_0000_0000;
 
        @(posedge clk)
        @(posedge clk)
        rst_n = 1'b1;

        ////////////////////////////////////
        // スルー信号動作確認
        ////////////////////////////////////
        @( posedge phase_execute)
        decoded_op_de    = 9'b1_0101_0101;
        rs2data_de       = 32'h1010_1010;
        next_pc_de       = 32'hA0A0_A0A0;
        rdsel_de         = 5'b1_0101;
     
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq(decoded_op_em, 9'b1_0101_0101, "decoded_op_de->decoded_op_em");
        assert_eq(rs2data_em,    32'h1010_1010, "rs2data_de->rs2data_em");
        assert_eq(next_pc_em,    32'hA0A0_A0A0, "next_pc_de->next_pc_em");
        assert_eq(rdsel_em,      5'b101_01,     "rdsel_de->rdsel_em");

        ////////////////////////////////////
        // ALU系動作確認
        ////////////////////////////////////

    //初期化
        @( posedge phase_execute)
        imm = 32'h0000_0000;
        rs1data_de = 32'h0000_0000;
        rs2data_de = 32'h0000_0000;
        curr_pc_de = 32'h0000_0000;
        next_pc_de = 32'h0000_0000;
        funct_alu = 4'b0000;
        rdsel_de = 5'b0_0000;
        decoded_op_de = 9'b0_0000_0000;

    //rs1data_de+rs2data_de->alu_out_em
        @( posedge phase_execute)
        decoded_op_de[USE_RS1_BIT] = 1'b1;
        decoded_op_de[USE_RS2_BIT] = 1'b1;
        rs1data_de    = 32'hA0A0_A0A0;       
        curr_pc_de    = 32'h1010_1010;
        rs2data_de    = 32'h0A0A_0A0A;
        imm           = 32'h0101_0101;
        funct_alu     = 4'b0000; //add
        
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq(alu_out_em, 32'hAAAA_AAAA, "rs1data_de+rs2data_de->alu_out_em");

    //rs1data_de^rs2data_de->alu_out_em
        @( posedge phase_execute)
        funct_alu     = 4'b1100; //xor
        rs1data_de    = 32'hFFFF_FFFF;       
        rs2data_de    = 32'hF0F0_F0F0;

        @( posedge phase_memoryaccess)
        #(1)
        assert_eq(alu_out_em, 32'h0F0F_0F0F, "rs1data_de^rs2data_de->alu_out_em");

    //curr_pc_de+imm->alu_out_em
        @( posedge phase_execute)
        funct_alu     = 4'b0000; //add
        decoded_op_de[USE_RS1_BIT] = 1'b0;
        decoded_op_de[USE_RS2_BIT] = 1'b0;
        rs1data_de    = 32'hA0A0_A0A0;       
        curr_pc_de    = 32'h1010_1010;
        rs2data_de    = 32'h0A0A_0A0A;
        imm           = 32'h0101_0101;
        
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq(alu_out_em, 32'h1111_1111, "curr_pc_de+imm->alu_out_em");

    //curr_pc_de^imm
        @( posedge phase_execute)
        funct_alu     = 4'b1100; //xor
        curr_pc_de    = 32'hFFFF_FFFF;
        imm           = 32'hF0F0_F0F0;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq(alu_out_em, 32'h0F0F_0F0F, "curr_pc_de^imm->alu_out_em");

    //curr_pc_de(x)^imm
        @( posedge phase_execute)
        funct_alu     = 4'b1100; //xor
        curr_pc_de    = 32'hFFFF_xxxx;
        imm           = 32'hF0F0_F0F0;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq(alu_out_em, 32'h0F0F_xxxx, "curr_pc_de(x)^imm ->alu_out_em");

        /////////////////////////////////////////
        //comp系動作確認
        ///////////////////////////////////////// 

    //初期化
        @( posedge phase_execute)
        imm = 32'h0000_0000;
        rs1data_de = 32'h0000_0000;
        rs2data_de = 32'h0000_0000;
        curr_pc_de = 32'h0000_0000;
        next_pc_de = 32'h0000_0000;
        funct_alu = 4'b0000;
        rdsel_de = 5'b0_0000;
        decoded_op_de = 9'b0_0000_0000;

    //BEQ
        @( posedge phase_execute)
        decoded_op_de [FUNCT3_BIT_M:FUNCT3_BIT_L] = 3'b000; //BEQ
        rs1data_de = 32'hA0A0_A0A0;
        rs2data_de = 32'hA0A0_A0A0;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq_jump_state(jump_state_em, 1'b1, "BEQ,jump_state_em = 1");

        @( posedge phase_execute)
        decoded_op_de [FUNCT3_BIT_M:FUNCT3_BIT_L] = 3'b000; //BEQ
        rs1data_de = 32'hA0A0_A0A0;
        rs2data_de = 32'h0A0A_0A0A;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq_jump_state(jump_state_em, 1'b0, "BEQ,jump_state_em = 0");

    //BLTU
        @( posedge phase_execute)
        decoded_op_de [FUNCT3_BIT_M:FUNCT3_BIT_L] = 3'b110; //BLTU
        rs1data_de = 32'h0000_0001;
        rs2data_de = 32'hA0A0_A0A0;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq_jump_state(jump_state_em, 1'b1, "BLTU,jump_state_em = 1");

        @( posedge phase_execute)
        decoded_op_de [FUNCT3_BIT_M:FUNCT3_BIT_L] = 3'b110; //BLTU
        rs1data_de = 32'hA0A0_A0A0;
        rs2data_de = 32'hA0A0_A0A0;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq_jump_state(jump_state_em, 1'b0, "BLTU,jump_state_em = 0");

        @( posedge phase_execute)
        decoded_op_de [FUNCT3_BIT_M:FUNCT3_BIT_L] = 3'b110; //BLTU
        rs1data_de = 32'hA0A0_A0A0;
        rs2data_de = 32'h0000_0001;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq_jump_state(jump_state_em, 1'b0, "BLTU,jump_state_em = 0");
    //BLTU(x)
        @( posedge phase_execute)
        decoded_op_de [FUNCT3_BIT_M:FUNCT3_BIT_L] = 3'b110; //BLTU
        rs1data_de = 32'hA0A0_A0A0;
        rs2data_de = 32'h0000_xxxx;
        @( posedge phase_memoryaccess)
        #(1)
        assert_eq_jump_state(jump_state_em, 1'bx, "BLTU,jump_state_em = x");

    $finish;
end

    initial begin
        $dumpfile("top_execute_tb.vcd");
        $dumpvars(0,top_execute_tb);
    end

//assert 多bit信号
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

//assert 1bit信号
    task assert_eq_jump_state;
        input a;
        input b;
        input [0:8*50-1] message;
        begin
            if( a === b) begin
                $display ("       OK (%b,%b,%s)", a, b, message);
            end
            else begin
                $display ("Assert NG (%b,%b,%s)", a, b, message);
                #(`STEP*10)
                $finish;
            end
        end
    endtask

endmodule
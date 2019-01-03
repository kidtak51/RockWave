/*
 * *****************************************************************
 * File: core_general.vh
 * Category: CORE
 * File Created: 2018/12/18 04:23
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/04 24:26
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   全体で使用する定義
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/1/4	  kidtak51	  parameter名一部修正
 * 2018/12/28	Masaru Aoki	FUNCT3 / DataMemWE / JumpEn 追加
 * 2018/12/18	Masaru Aoki	First Version
 * *****************************************************************
 */

    // CPU Register Bit Size
    parameter XLEN = 32;
    
    /////////////////////////////////////////////
    // Instruction Memory
    /////////////////////////////////////////////
    // InstMemory Data Width
    parameter DWIDTH = XLEN;
    // InstMemory Address Width
    parameter AWIDTH = 12;
    // InstMemory Words size
    parameter WORDS = (2**AWIDTH);
    // Reset Vector
    parameter RESET_VECTOR = 32'h8000_0000;

    /////////////////////////////////////////////
    // Doecode
    /////////////////////////////////////////////
    parameter OPLEN = 9;

    // RS1/RS2
    parameter USE_RS1_BIT = 0;
      parameter USE_RS1_PC      = 0;
      parameter USE_RS1_RS1DATA = 1;
    parameter USE_RS2_BIT = 1;
      parameter USE_RS2_IMM     = 0;
      parameter USE_RS2_RS2DATA = 1;

    // RD
    parameter USE_RD_BIT_L = 2;
    parameter USE_RD_BIT_M = 3;
      parameter USE_RD_ALU    = 2'b00;
      parameter USE_RD_PC     = 2'b01;
      parameter USE_RD_MEMORY = 2'b10;
      parameter USE_RD_COMP   = 2'b11;
   
    // funct3
    parameter FUNCT3_BIT_L = 4;
    parameter FUNCT3_BIT_M = 6;
      // LOAD / STORE
      parameter FUNCT3_B = 3'b000;
      parameter FUNCT3_H = 3'b001;
      parameter FUNCT3_W = 3'b010;
      parameter FUNCT3_BU = 3'b100;
      parameter FUNCT3_HU = 3'b101;
      // BRANCH
      parameter FUNCT3_BEQ  = 3'b000;
      parameter FUNCT3_BNE  = 3'b001;
      parameter FUNCT3_JUMP = 3'b010;  // Must Jump
      parameter FUNCT3_BLT  = 3'b100;
      parameter FUNCT3_BGE  = 3'b101;
      parameter FUNCT3_BLTU = 3'b110;
      parameter FUNCT3_BGEU = 3'b111;
      // OP
      parameter FUNCT3_SLT  = 3'b010;
      parameter FUNCT3_SLTU = 3'b011;

    // Data Memory Write Enable
    parameter DATA_MEM_WE_BIT = 7;

    // Jump Enable
    parameter JUMP_EN_BIT = 8;
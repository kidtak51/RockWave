/*
 * *****************************************************************
 * File: core_general.vh
 * Category: CORE
 * File Created: 2018/12/18 04:23
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/12/20 04:46
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   全体で使用する定義
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
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
   parameter OPLEN = 4;

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
   
/*
 * *****************************************************************
 * File: statemachine_tb.v
 * Category: StateMachine
 * File Created: 2019/01/21 24:16
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/21 01:03
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
 * 2019/01/21	Takuya Shono	First Version
 * *****************************************************************
 */

`define STEP 5
`timescale 1ns/1ns

module statemachine_tb;
    `include "core_general.vh"

    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // For StateMachine
    reg stall_fetch;              // 状態fetchをkeepする
    reg stall_decode;             // 状態decodeをkeepする
    reg stall_execute;            // 状態executeをkeepする
    reg stall_memoryaccess;       // 状態memoryaccessをkeepする
    reg stall_writeback;          // 状態writebackをkeepする
    // For state instruction
    wire phase_fetch;             //状態をFETCHにする
    wire phase_decode;            //状態をDECODEにする
    wire phase_execute;           //状態をEXECUTEにする
    wire phase_memoryaccess;      //状態をMEMORYACCESSにする
    wire phase_writeback;          //状態をWRITEBACKにする
   
    wire  [4:0] current; //現在の状態
    wire  [4:0] next;    //次の状態

   // DUT インスタンス
    statemachine U_statemachine(.*);

    initial
        clk = 0;
    always begin
         #(`STEP) clk = ~clk;
    end

    initial begin
        rst_n               = 0;
        stall_fetch         = 0;
        stall_decode        = 0;
        stall_execute       = 0;
        stall_memoryaccess  = 0;
        stall_writeback     = 0;

        @(posedge clk)
        @(posedge clk)
        rst_n = 1;

        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        
        $finish;
    end

    initial begin
        $dumpfile("statemachine.vcd");
        $dumpvars(0,statemachine_tb);
    end
endmodule

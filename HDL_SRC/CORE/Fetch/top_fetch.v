/*
 * *****************************************************************
 * File: top_fetch.v
 * Category: Fetch
 * File Created: 2018/12/17 04:52
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/23 05:45
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   FETCHフェースのTOP階層
 *      ・Program Counter
 *      ・Inst Memory Control
 *      ・後段へのラッチ
 *           Xilinxへ実装する際は InstMemory(ROM)をクロック同期メモリ
 *           とするため、InstCodeはラッチを通さない
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/17	Masaru Aoki	First Version
 * *****************************************************************
 */


module top_fetch(
    input clk,                       // Global Clock
    input rst_n,                     // Global Reset

    // From StateMachine
    input phase_fetch,               // Fetch Phase
    input phase_writeback,           // WriteBack Phase
    // From MemoryAccess
    input jump_state_wf,             // PCの次のアドレスがJumpアドレス
    input [XLEN-1:0] regdata_for_pc, // Jump先アドレス
    // From InstMemory
    input [XLEN-1:0] inst_data,      // InstMemory Data

    // For InstMemory
    output [AWIDTH-1:0] inst_addr,   // InstMemory Address
    // For Decode
    output [XLEN-1:0] curr_pc_fd,    // Current PC Address for Decode
    output [XLEN-1:0] next_pc_fd,    //    Next PC Address for Decode
    output [XLEN-1:0] inst,          // Instruction
    // For StateMachine
    output stall_fetch               // Stall Fetch Phase
);

    `include "core_general.vh"
   
    reg [XLEN-1:0] program_counter; // Program Counter
    reg [(XLEN*2)-1:0] latch_fetch; // Latch for Next Stage
    
    wire [XLEN-1:0] curr_pc;        //      PC Address
    wire [XLEN-1:0] next_pc;        // Next PC Address
    wire [(XLEN-AWIDTH)-3:0] dummy_inst_addr2; // 未使用PC上位ビット
    wire [              1:0] dummy_inst_addr1; // 未使用PC下位ビット(1word=4byte)

    /////////////////////////////////////////////
    // Program Counter
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            program_counter <= RESET_VECTOR;
        else if(phase_writeback)
            if(jump_state_wf)
                program_counter <= regdata_for_pc;
            else
                program_counter <= next_pc;
        else
            program_counter <= program_counter;
    end

    assign curr_pc = program_counter;
    // RISC-Vの命令は4byte単位 
    assign next_pc = program_counter + 4;
    // InstMemory用アドレス / InstMemoryは1Word=4Byteなため下位2bitを捨てる
    assign {dummy_inst_addr2,inst_addr,dummy_inst_addr1} = program_counter;
    // Decode用inst
    //   XilinxのBlockRAMが同期RAMで1clk遅延するためラッチを通さない
    assign inst = inst_data;

    // 現状ではFetchPhaseはストールの必要なし
    //   InstMemoryが1clkでデータの準備ができなくなったら使用する
    assign stall_fetch = 1'b0; 

    /////////////////////////////////////////////
    // 次ステージのためのラッチ
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            latch_fetch <= {(XLEN*2){1'b0}};
        else if(phase_fetch)
            latch_fetch <= {curr_pc,next_pc};
        else
            latch_fetch <= latch_fetch;
    end

    assign {curr_pc_fd,next_pc_fd} = latch_fetch;

endmodule



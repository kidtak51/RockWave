/*
 * *****************************************************************
 * File: top_fetch_tb.v
 * Category: Fetch
 * File Created: 2018/12/18 04:35
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/12/19 05:25
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   TestBench for top_fetch
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/18	Masaru Aoki	First Version
 * *****************************************************************
 */

`define STEP 5

module top_fetch_tb;
    reg  clk;                       // Global Clock
    reg rst_n;                      // Global Reset
    reg phase_fetch;                // Fetch Phase
    reg phase_decode;               // Decode Phase
    reg phase_execute;              // Execute Phase
    reg phase_memory;               // MemoryAccess Phase
    reg phase_writeback;            // WriteBack Phase
    reg jump_state_mf;              // PCの次のアドレスがJumpアドレス
    reg [XLEN-1:0] regdata_for_pc;  // Jump先アドレス
    wire  [XLEN-1:0] inst_data;     // InstData
    wire  [AWIDTH-1:0] inst_addr;   // InstAddress
    wire  [XLEN-1:0] curr_pc_fd;    // 現在のPC
    wire  [XLEN-1:0] next_pc_fd;    // 次のPC
    wire  [XLEN-1:0] inst;          // 命令
    wire  stall_fetch;              // Stall Fetch Phase

    `include "core_general.vh"

///////////////////////////////////////////////////////////////////
// インスタンス
top_fetch U_top_fetch(
    .clk(clk), .rst_n(rst_n),
    .phase_fetch(phase_fetch),
    .phase_writeback(phase_writeback),
    .jump_state_mf(jump_state_mf),
    .regdata_for_pc(regdata_for_pc),
    .inst_data(inst_data),
    .inst_addr(inst_addr),
    .curr_pc_fd(curr_pc_fd),
    .next_pc_fd(next_pc_fd),
    .inst(inst),
    .stall_fetch(stall_fetch)
);

rom U_inst_rom(
    .clk(clk), .rst_n(rst_n),
    .addr(inst_addr),
    .qout(inst_data)
);
///////////////////////////////////////////////////////////////////
// メモリロード
initial
    $readmemh("../../fw/rv32ui-p-addi.hex",U_inst_rom.mem,12'h000,12'hfff);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// State Machine
initial begin
    phase_fetch = 0;
    phase_decode = 0;
    phase_execute = 0;
    phase_memory = 0;
    phase_writeback = 0;
    @(posedge rst_n)
    phase_fetch <= 1;
end
always begin
    @(posedge clk)
    phase_fetch <= phase_writeback;
    phase_decode <= phase_fetch;
    phase_execute <= phase_decode;
    phase_memory  <= phase_execute;
    phase_writeback <= phase_memory;
end

///////////////////////////////////////////////////////////////////
// Sim
initial begin
    $dumpfile("top_fetch_tb.vcd");
    $dumpvars(0,top_fetch_tb);
    $monitor("%t: addr=%h  data=%h",$time,inst_addr,inst_data);

    rst_n = 0;
    jump_state_mf = 0;
    regdata_for_pc = 0;
    @(posedge clk)
    @(posedge clk)
    rst_n = 1;
    @(posedge clk)

    #(`STEP*50)
    @(posedge phase_memory)
    jump_state_mf = 1;
    regdata_for_pc = 32'h8000_0100;
    @(posedge phase_memory)
    jump_state_mf = 0;
    #(`STEP*50)

    $finish;
end

endmodule
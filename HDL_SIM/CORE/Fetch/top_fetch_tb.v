/*
 * *****************************************************************
 * File: top_fetch_tb.v
 * Category: Fetch
 * File Created: 2018/12/18 04:35
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/23 05:51
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
 * 2019/01/23	Masaru Aoki	アドレス増加のテストを追加
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
    reg jump_state_wf;              // PCの次のアドレスがJumpアドレス
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
    .jump_state_wf(jump_state_wf),
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
    jump_state_wf = 0;
    regdata_for_pc = 0;
    @(posedge clk)
    @(posedge clk)
    rst_n = 1;
    @(posedge phase_decode)    #(1)
    assert_eq(curr_pc_fd,RESET_VECTOR, "Reset Currennt");
    assert_eq(next_pc_fd,RESET_VECTOR+4, "Reset Next");
    assert_eq(inst_addr,(RESET_VECTOR>>2)&12'hFFF,"Reset InstAddr");
    assert_eq(inst_data,inst, "Reset Instructiom");

    // ProgramCountは4byte / inst_addrは1word　単位で増加する
    @(posedge phase_decode)    #(1)
    assert_eq(curr_pc_fd,RESET_VECTOR+4, "1st inst Currennt");
    assert_eq(next_pc_fd,RESET_VECTOR+8, "1st inst Next");
    assert_eq(inst_addr,1,"1st inst InstAddr");
    assert_eq(inst_data,inst, "1st inst Instructiom");

    #(`STEP*50)
    @(posedge phase_memory)
    jump_state_wf = 1;
    regdata_for_pc = 32'h8000_0100;
    // jump_stateが立っていたら、regdata_for_pcのアドレスにJump
    @(posedge phase_decode)    #(1)
    assert_eq(curr_pc_fd,32'h8000_0100, "Jump Currennt");
    assert_eq(next_pc_fd,32'h8000_0104, "Jump Next");
    assert_eq(inst_addr,(12'h100>>2),"Jump InstAddr");
    assert_eq(inst_data,inst, "Jump Instructiom");
    @(posedge phase_memory)
    jump_state_wf = 0;
    #(`STEP*50)

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
//                #(`STEP*10)
                $finish;
            end
        end
    endtask

endmodule
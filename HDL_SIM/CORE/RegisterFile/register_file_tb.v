/*
 * *****************************************************************
 * File: register_file_tb.v
 * Category: RegisterFile
 * File Created: 2018/12/23 05:46
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/12/23 12:33
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   TestBench for register_file
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/23	Masaru Aoki	First Version
 * *****************************************************************
 */

`define STEP 5
`timescale 1ns/1ns

module register_file_tb;

`include "core_general.vh"

    reg   clk;                    // Clock
    reg   rst_n;                  // Reset
    reg   [XLEN-1:0] rddata;      // 入力データ
    reg   [4:0] rdsel;            // RD 選択
    reg   phase_fetch;            // Fetch Phase
    reg   phase_decode;           // Decode Phase
    reg   phase_execute;          // Execute Phase
    reg   phase_memory;           // MemoryAccess Phase
    reg   phase_writeback;        // WriteBack Phase
    reg   [4:0] rs1sel;           // RS1 選択
    reg   [4:0] rs2sel;           // RS2 選択

    wire  [XLEN-1:0] rs1data;     // 出力データ (rs1)
    wire  [XLEN-1:0] rs2data;     // 出力データ (rs2)

    integer i;

    // DUTインスタンス
    register_file U_register_file(.*);

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

initial begin
    $dumpfile("register_file.vcd");
    $dumpvars(0,register_file_tb);
//    $monitor("%t: RD(en=%b sel=%h out=%4h) RS1(sel=%d,%4h) RS2(sel=%d,%4h)",$time,phase_writeback,rdsel,rddata,rs1sel,rs1data,rs2sel,rs2data);

    rst_n=0;
    rddata =0;
    rdsel =0;
    rs1sel = 0;
    rs2sel = 0;
    phase_writeback = 0;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    ////////////////////////////////////////////
    // 初期値チェック
    $display("RS1 init check");
    for(i = 0;i<32;i=i+1) begin
        rs1sel = i;
        @(posedge clk)
        assert_eq (rs1data,0);
    end
    $display("RS2 init check");
    for(i = 0;i<32;i=i+1) begin
        rs2sel = i;
        @(posedge clk)
        assert_eq (rs2data,0);
    end

    ////////////////////////////////////////////
    // RDチェック 
    $display("RD check");
    // X0は書き込めない
    rdsel = 0;
    rs1sel = 0;
    rddata = 32'h0000;
    wait_reg_write();
    assert_eq (rs1data,0);

    rddata = 32'hFFFF;
    wait_reg_write();
    assert_eq (rs1data,0);

    rddata = 32'hAAAA;
    wait_reg_write();
    assert_eq (rs1data,0);

    rddata = 32'h5555;
    wait_reg_write();
    assert_eq (rs1data,0);

    // X1〜X31書き込み RS1から読み出す
    for(i = 1;i<32;i=i+1) begin
        rdsel = i;
        rs1sel = i;
        rddata = 32'h0000;
        wait_reg_write();
        assert_eq (rs1data,rddata);

        rddata = 32'hFFFF;
        wait_reg_write();
        assert_eq (rs1data,rddata);

        rddata = 32'h5555;
        wait_reg_write();
        assert_eq (rs1data,rddata);

        rddata = 32'hAAAA;
        wait_reg_write();
        assert_eq (rs1data,rddata);
    end

    ////////////////////////////////////////////
    // RS1 チェック 
    $display("RS1 check");
    // X1〜X31に1〜31を書き込み RS1から読み出す
    // X0は常に0
    for(i = 1;i<32;i=i+1) begin
        rdsel = i;
        rddata = i;
        wait_reg_write();
    end

    for(i = 0;i<32;i=i+1) begin
        rs1sel = i;
        @(posedge phase_execute)
        assert_eq (rs1data,i);
    end

    ////////////////////////////////////////////
    // RS2 チェック 
    $display("RS2 check");
    for(i = 0;i<32;i=i+1) begin
        rs2sel = i;
        @(posedge phase_execute)
        assert_eq (rs2data,i);
    end

    $display("***** TEST OK! *****");
    $finish;
end

task wait_reg_write;
begin
    // WriteBack phaseでレジスタに書き込み
    @(negedge phase_writeback);
    // Execute phaseで読み出し
    @(negedge phase_execute);
end
endtask


task assert_eq;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h)",a,b);
            $finish;
        end
    end
endtask

endmodule
/*
 * *****************************************************************
 * File: top_memoryaccess_rv64i_tb.v
 * Category: MemoryAccess
 * File Created: 2019/01/06 04:28
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/24 05:00
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   top_memoryaccessとramを組み合わせたテスト
 *       RV64I Ver.
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/06	Masaru Aoki	First Version
 * *****************************************************************
 */

 `define STEP 5
 `timescale 1ns/1ns

 `define RV64I

module top_memoryaccess_rv64i_tb;
    `include "core_general.vh"

    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // From StateMachine
    reg phase_fetch;
    reg phase_decode;
    reg phase_execute;
    reg phase_memoryaccess;        // Fetch Phase
    reg phase_writeback;           // WriteBack Phase
    // From Execute
    reg [OPLEN-1:0] decoded_op_em; // Decoded OPcode
    reg jump_state_em;             // PCの次のアドレスがJumpアドレス
    reg [4:0] rdsel_em;            // RD選択
    reg [XLEN-1:0] next_pc_em;     // Next PC Address from Execute
    reg [XLEN-1:0] alu_out_em;     // ALU output
    reg [XLEN-1:0] rs2data_em;     // RS2 data
    // For DataMemory
    wire [AWIDTH-1:0] data_mem_addr;// Address
    wire [XLEN-1:0] data_mem_wdata;// Write Data
    wire [XLEN-1:0] data_mem_out;   // output
    wire [2:0] data_mem_we;        // Write Enable
    // For WriteBack
    wire [OPLEN-1:0] decoded_op_mw;// Decoded OPcode
    wire jump_state_mw;            // PCの次のアドレスがJumpアドレス
    wire [4:0] rdsel_mw;           // RD選択
    wire [XLEN-1:0] next_pc_mw;    // Next PC Address for Decode
    wire [XLEN-1:0] alu_out_mw;    // ALU wire
    wire [XLEN-1:0] mem_out_mw;    // Data Memory Output
    // For StateMachine
    wire stall_memoryaccess;        // Stall MemoryAccess Phase

    integer i;

    ///////////////////////////////////////////////////////////////////
    // DUT インスタンス
    top_memoryaccess U_top_memoryaccess(.*);
    ram U_ram(
        .clk(clk),
        .rst_n(rst_n),
        .addr(data_mem_addr),
        .qin(data_mem_wdata),
        .qout(data_mem_out),
        .we(data_mem_we)
    );

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

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("top_memoryaccess.vcd");
    $dumpvars(0,top_memoryaccess_rv64i_tb);

    rst_n=0;
    decoded_op_em=0;
    jump_state_em=0;
    rdsel_em=0;
    next_pc_em=0;
    alu_out_em=0;
    rs2data_em=0;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    ////////////////////////////////////////
    // STORE系動作確認
    ////////////////////////////////////////
    $display("STORE");
    $display("sb :STORE byte");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0000;  // addr
    rs2data_em = 64'h5555_5555_5555_5555;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'h0000_0000_0000_0055);

    $display("sh :STORE Halfword");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0004;  // addr
    rs2data_em = 64'hAAAA_AAAA_AAAA_AAAA;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'h0000_0000_0000_AAAA);

    $display("sw :STORE Word");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0008;  // addr
    rs2data_em = 64'hFFFF_FFFF_FFFF_FFFF;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'h0000_0000_FFFF_FFFF);

    // RV64I
    $display("sd :STORE Double");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0008;  // addr
    rs2data_em = 64'hFFFF_FFFF_FFFF_FFFF;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'hFFFF_FFFF_FFFF_FFFF);

    ////////////////////////////////////////
    // LOAD系動作確認
    //     DataMemoryの出力の一部だけ取り出し符号拡張する
    ////////////////////////////////////////
    $display("LOAD");
    /////
    $display("lb :Load Byte");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_000C;  // addr
    rs2data_em = 64'hFFFF_FFFF_FFFF_FFFF;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'hFFFF_FFFF_FFFF_FFFF);
    /////
    $display("lbu:Load Byte Unsinged");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_BU;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'h0000_0000_0000_00FF);

    /////
    $display("lh :Load Halfword");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0010;  // addr
    rs2data_em = 64'hAAAA_AAAA_AAAA_AAAA;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'hFFFF_FFFF_FFFF_AAAA);
    /////
    $display("lhu:Load Halfword Unsinged");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_HU;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'h0000_0000_0000_AAAA);

    /////
    $display("lw :Load Word");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0014;  // addr
    rs2data_em = 64'hEFEF_EFEF_EFEF_EFEF;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'hFFFF_FFFF_EFEF_EFEF);
    ///// RV64I
    $display("lhu:Load Word Unsinged");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_WU;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'h0000_0000_EFEF_EFEF);

    ///// RV64I
    $display("lw :Load Double");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0014;  // addr
    rs2data_em = 64'h0000_5555_AAAA_FFFF;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_D;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,64'h0000_5555_AAAA_FFFF);

    $display("All test is GREEN");
    $finish;
end

task assert_eq;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h)",a,b);
            #(`STEP*10)
            $finish;
        end
    end
endtask


endmodule
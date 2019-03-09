/*
 * *****************************************************************
 * File: top_memoryaccess.v
 * Category: MemoryAccess
 * File Created: 2019/01/02 05:45
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/03 15:54
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   MemoryAccess 階層
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/24	Masaru Aoki	RV64I対応
 * 2019/01/02	Masaru Aoki	First Version
 * *****************************************************************
 */
module top_memoryaccess(
    input clk,                       // Global Clock
    input rst_n,                     // Global Reset

    // From StateMachine
    input phase_memoryaccess,        // Fetch Phase
    // From DataMemory
    input [XLEN-1:0] data_mem_out,   // Output
    // From Execute
    input [OPLEN-1:0] decoded_op_em, // Decoded OPcode
    input jump_state_em,             // PCの次のアドレスがJumpアドレス
    input [4:0] rdsel_em,            // RD選択
    input [XLEN-1:0] next_pc_em,     // Next PC Address from Execute
    input [XLEN-1:0] alu_out_em,     // ALU output
    input [XLEN-1:0] rs2data_em,     // RS2data
    // For DataMemory
    output [XLEN-1:0] data_mem_addr,// Address
    output [XLEN-1:0] data_mem_wdata,// Write Data
    output [2:0] data_mem_we,        // Write Enable
    // For WriteBack
    output [OPLEN-1:0] decoded_op_mw,// Decoded OPcode
    output jump_state_mw,            // PCの次のアドレスがJumpアドレス
    output [4:0] rdsel_mw,           // RD選択
    output [XLEN-1:0] next_pc_mw,    // Next PC Address for Decode
    output [XLEN-1:0] alu_out_mw,    // ALU output
    output [XLEN-1:0] mem_out_mw,    // Data Memory output
    // For StateMachine
    output stall_memoryaccess        // Stall MemoryAccess Phase
);

    `include "core_general.vh"

    localparam LATCH_LEN = (XLEN*2+5+1+OPLEN);
    reg [LATCH_LEN-1:0] latch_memoryaccess; // Latch for Next Stage

    /////////////////////////////////////////////
    // Rename Decode Opcode 
    wire [2:0] funct3 = decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L];
    wire we = decoded_op_em[DATA_MEM_WE_BIT];

    /////////////////////////////////////////////
    // Memory Access STORE系
    assign data_mem_addr = alu_out_em;
    assign data_mem_wdata = rs2data_em;
    assign data_mem_we = {(we & phase_memoryaccess),funct3[1:0]};

    /////////////////////////////////////////////
    // Memory Access LOAD系
    assign mem_out_mw = func_mem_out(funct3,data_mem_out);
    function [XLEN-1:0] func_mem_out(
        input [2:0] funct3,
        input [XLEN-1:0] mem_out
    );
    begin
        case(funct3)
            FUNCT3_B : func_mem_out = {{(XLEN-8){mem_out[7]}},mem_out[7:0]};
            FUNCT3_BU: func_mem_out = {{(XLEN-8){      1'b0}},mem_out[7:0]};
            FUNCT3_H : func_mem_out = {{(XLEN-16){mem_out[15]}},mem_out[15:0]};
            FUNCT3_HU: func_mem_out = {{(XLEN-16){       1'b0}},mem_out[15:0]};
            FUNCT3_W : func_mem_out = {{(XLEN-31){mem_out[31]}},mem_out[30:0]};
`ifdef RV64I
            FUNCT3_WU: func_mem_out = {{(XLEN-32){       1'b0}},mem_out[31:0]};
            FUNCT3_D : func_mem_out = {{(XLEN-63){mem_out[63]}},mem_out[62:0]};
`endif
            default:   func_mem_out = {(XLEN-1){1'bx}};
        endcase
    end
    endfunction
    /////////////////////////////////////////////
    // 次ステージのためのラッチ
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            latch_memoryaccess <= {LATCH_LEN{1'b0}};
        else if(phase_memoryaccess)
            latch_memoryaccess <= {next_pc_em,alu_out_em,jump_state_em,decoded_op_em,rdsel_em};
        else
            latch_memoryaccess <= latch_memoryaccess;
    end

    assign {next_pc_mw,alu_out_mw,jump_state_mw,decoded_op_mw,rdsel_mw} = latch_memoryaccess;

    /////////////////////////////////////////////
    // For statemachine
    //     現状メモリアクセスは1clkで終了する
    assign stall_memoryaccess = 1'b0;

endmodule // top_memoryaccess

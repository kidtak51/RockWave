/*
 * *****************************************************************
 * File: ram.v
 * Category: MemoryAccess
 * File Created: 2018/12/30 06:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/06 05:23
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   Data Memory
 *   XilinxではBlockRAMを推察させる
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/04	Masaru Aoki	Byte / HalfWord / Wordアクセスに対応
 * 2018/12/30	Masaru Aoki	First Version
 * *****************************************************************
 */


module ram(
    input clk,                  // Global Clock
    input rst_n,                // Global Reset
    input [AWIDTH-1:0] addr,    // Address
    input [DWIDTH-1:0] qin,     // Read  Data
    input [2:0] we,             // Memory Write Enable
    output [DWIDTH-1:0] qout    // Read  Data
);
    `include "core_general.vh"

    reg [DWIDTH-1:0] qout;
    reg [7:0] mem [WORDS+2:0];


    //////////////////////////////////////////////////////////////
    //  Xilinx の Block RAMを推察させる
    //    UG901
    //     https://www.xilinx.com/support/documentation/sw_manuals_j/xilinx2016_4/ug901-vivado-synthesis.pdf
    integer i;
    initial for (i=0; i<WORDS+3; i=i+1) mem[i] = 0;
    always @(posedge clk) begin
        if(we == 3'b1_10) begin // Word
            mem[addr  ] <= qin[ 7: 0];
            mem[addr+1] <= qin[15: 8];
            mem[addr+2] <= qin[23:16];
            mem[addr+3] <= qin[31:24];
        end
        else if(we == 3'b1_01) begin // HalfWord
            mem[addr  ] <= qin[ 7: 0];
            mem[addr+1] <= qin[15: 8];
        end
        else if(we == 3'b1_00) begin // Byte
            mem[addr  ] <= qin[ 7: 0];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            qout <= {DWIDTH{1'b0}};
        end
        else begin
            qout <= {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
        end
    end
endmodule

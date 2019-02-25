/*
 * *****************************************************************
 * File: ram.v
 * Category: MemoryAccess
 * File Created: 2018/12/30 06:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/02/22 04:52
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
 * 2019/02/22	Masaru Aoki	ByteWriteEnable付きのBlockRAMに変更
 * 2019/01/24	Masaru Aoki	RV64Iに対応
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

    wire [3:0] weram;

    assign weram[3] = (we == 3'b1_10); // 4thByte Word Access
    assign weram[2] = (we == 3'b1_10); // 3rdByte Word Access
    assign weram[1] = (we == 3'b1_10) || (we == 3'b1_01);// 2ndByte Word / HarlWord
    assign weram[0] = (we[2] == 1'b1); // 1stByte All Write Access

    bytewrite_ram_1b U_ram(
        .clk(clk),
        .we(weram),
        .addr(addr),
        .di(qin),
        .do(qout)
    );
endmodule

// Single-Port BRAM with Byte-wide Write Enable
//	Read-First mode
//	Single-process description
//	Compact description of the write with a generate-for 
//   statement
//	Column width and number of columns easily configurable
//
// bytewrite_ram_1b.v
//

module bytewrite_ram_1b (clk, we, addr, di, do);

parameter SIZE = 4096; 
parameter ADDR_WIDTH = 12; 
parameter COL_WIDTH = 8; 
parameter NB_COL = 4;

input	clk;
input	[NB_COL-1:0]	we;
input	[ADDR_WIDTH-1:0]	addr;
input	[NB_COL*COL_WIDTH-1:0] di;
output reg [NB_COL*COL_WIDTH-1:0] do;

reg	[NB_COL*COL_WIDTH-1:0] RAM [SIZE-1:0];

always @(posedge clk)
begin
    do <= RAM[addr];
end

generate genvar i;
for (i = 0; i < NB_COL; i = i+1)
begin
always @(posedge clk)
begin
    if (we[i])
        RAM[addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= di[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
    end 
end
endgenerate

endmodule

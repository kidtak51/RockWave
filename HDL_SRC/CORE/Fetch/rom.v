/*
 * *****************************************************************
 * File: rom.v
 * Category: Fetch
 * File Created: 2018/12/16 07:11
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2018/12/20 04:48
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   Instruction ROM
 *   Xilinxでは、BlockRAMを推察させる
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/16	Masaru Aoki	First Version
 * *****************************************************************
 */

module rom(
    input clk,                  // Global Clock
    input rst_n,                // Global Reset
    input [AWIDTH-1:0] addr,    // Address
    output [DWIDTH-1:0] qout       // Read  Data
);
    `include "core_general.vh"

    reg [DWIDTH-1:0] qout;
    reg [DWIDTH-1:0] mem [WORDS-1:0];

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            qout <= {DWIDTH{1'b0}};
        end
        else begin
            qout <= mem[addr];
        end
    end
endmodule

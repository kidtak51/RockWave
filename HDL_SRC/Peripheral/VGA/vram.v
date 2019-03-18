/*
 * *****************************************************************
 * File: vram.v
 * Category: VGA
 * File Created: 2019/03/16 08:39
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/16 08:55
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   IverilogでのSIM用のVRAM
 *   FPGAではXilnixのBlockRAMを使用する
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/16	Masaru Aoki	First Version
 * *****************************************************************
 */
module vram(
    input               clka,
    input               ena,
    input       [ 0:0]  wea,
    input       [18:0]  addra,
    input       [11:0]  dina,
    output reg  [11:0]  douta,
    input               clkb,
    input       [ 0:0]  web,
    input       [18:0]  addrb,
    input       [11:0]  dinb,
    output reg  [11:0]  doutb
);

/* デュアルポートRAM - 同一ポート内ではライト前の値がリードされる */
reg[11:0] ram[0:2**19-1];
always @(posedge clka)
    begin
        if(wea)
            ram[addra] <= dina;
        douta <= ram[addra];
    end

always @(posedge clkb)
    begin
        if(web)
            ram[addrb] <= dinb;
        doutb <= ram[addrb];
    end

endmodule

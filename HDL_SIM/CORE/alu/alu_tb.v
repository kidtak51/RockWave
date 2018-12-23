 /*
 * *****************************************************************
 * File: alu_tb.v
 * Category: alu
 * File Created: 2018/12/19 12:12
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2018/12/19 12:12
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/19	Takuya Shono	First Version
 * *****************************************************************
 */

module alu_tb;

reg [31:0] aluin1;
reg [31:0] aluin2;
reg [2:0] funct3;
wire [31:0] aluout;

//1周期1000unit
parameter STEP = 1;

alu test(
   aluin1, aluin2, funct3, aluout
);

initial begin

    funct3 = 3'b000;
    aluin1 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    #STEP
    funct3 = 3'b000;
    aluin1 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    #STEP
    funct3 = 3'b000;
    aluin1 = 32'b0000_0000_0000_0000_0000_0000_0000_0111;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_1010;

    #STEP    funct3 = 3'b001;
    #STEP    funct3 = 3'b010;
    #STEP    funct3 = 3'b011;    
    #STEP    funct3 = 3'b100;
    #STEP    funct3 = 3'b101;
    #STEP    funct3 = 3'b110;
    #STEP    funct3 = 3'b111;


end

/* 表示 */
initial begin
 $dumpfile("alu.vcd");
    $dumpvars(0,alu_tb);
    $monitor(" STEP=%d funct3= %b aluin1=%b  aluin2=%b aluout=%b ",STEP,funct3,aluin1,aluin2,aluout);
end

endmodule

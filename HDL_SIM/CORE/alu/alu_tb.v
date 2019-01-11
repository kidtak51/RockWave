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
 *              演算を行う
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
reg funct7;
wire [31:0] aluout;

//1周期1000unit
parameter STEP = 1;

alu test(
   aluin1, aluin2, funct3, funct7, aluout
);

initial begin

    funct3 = 3'b000;
    funct7 = 1'b0;
    aluin1 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    #STEP
    funct3 = 3'b000;
    funct7 = 1'b0;
    aluin1 = 32'b0000_0000_0000_0000_0000_0000_0000_0111;
    aluin2 = 32'b1000_0000_0000_0000_0000_0000_0000_1010;

    #STEP    funct7 = 1'b0; funct3 = 3'b000; //ADD
    #STEP    funct7 = 1'b1; funct3 = 3'b000; //SUB
    #STEP    funct7 = 1'b0; funct3 = 3'b001; //SLL
    #STEP    funct7 = 1'b0; funct3 = 3'b010; //SLT
    #STEP    funct7 = 1'b0; funct3 = 3'b011; //SLTU
    #STEP    funct7 = 1'b0; funct3 = 3'b100; //XOR
    #STEP    funct7 = 1'b0; funct3 = 3'b110; //OR
    #STEP    funct7 = 1'b0; funct3 = 3'b111; //AND
    #STEP    funct7 = 1'bX; funct3 = 3'bXXX; 

    aluin1 = 32'b1000_0000_0000_0000_0000_0000_0000_0111;
    aluin2 = 32'b1000_0000_0000_0000_0000_0000_0000_1010;

    #STEP    funct7 = 1'b0; funct3 = 3'b101; //SRL
    #STEP    funct7 = 1'b1; funct3 = 3'b101; //SRA


end

/* 表示 */
initial begin
 $dumpfile("alu.vcd");
    $dumpvars(0,alu_tb);
    $monitor(" STEP=%d funct7= %b funct3= %b aluin1=%b aluin2=%b aluout=%b ",STEP,funct7,funct3,aluin1,aluin2,aluout);
end

endmodule

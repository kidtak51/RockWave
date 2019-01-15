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

`include "core_general.vh"

reg [XLEN-1:0] aluin1;
reg [XLEN-1:0] aluin2;
reg [3:0] funct_alu;
wire [XLEN-1:0] aluout;


//1周期1000unit
parameter STEP = 1;

alu test(
   .aluin1(aluin1), .aluin2(aluin2),
   .funct_alu(funct_alu), .aluout(aluout)
);

initial begin

    funct_alu = 4'b0000;
    aluin1 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    #STEP
    funct_alu = 4'b0000;
    aluin1 = 32'b0000_0000_0000_0000_0000_0000_0001_0111;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_1010;

/* add */       #STEP    funct_alu = 4'b0000;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0010_0001, "ADD");
/* sub */       #STEP    funct_alu = 4'b1000;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0000_1101, "SUB");
/* SLL/SLLI */  #STEP    funct_alu = 4'b0001;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0101_1100_0000_0000, "SLL/SLLI"); 
/* SLL/SLLI */  #STEP    funct_alu = 4'b1001;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0101_1100_0000_0000, "SLL/SLLI"); 
/* XOR */       #STEP    funct_alu = 4'b0100;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0001_1101, "XOR"); 
/* XOR */       #STEP    funct_alu = 4'b1100;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0001_1101, "XOR");
/* OR */        #STEP    funct_alu = 4'b0110;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0001_1111, "OR"); 
/* OR */        #STEP    funct_alu = 4'b1110;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0001_1111, "OR"); 
/* AND */       #STEP    funct_alu = 4'b0111;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0000_0010, "AND"); 
/* AND */       #STEP    funct_alu = 4'b1111;   #STEP assert_calc(aluout, 32'b0000_0000_0000_0000_0000_0000_0000_0010, "AND"); 

    #STEP
    aluin1 = 32'b1000_0000_0000_0000_0000_0000_0001_0101;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_0011;
/* SRL/SRLI */  #STEP    funct_alu = 4'b0101;   #STEP assert_calc(aluout, 32'b0001_0000_0000_0000_0000_0000_0000_0010, "SRL/SRLI"); 
/* SRA/SRAI */  #STEP    funct_alu = 4'b1101;   #STEP assert_calc(aluout, 32'b1111_0000_0000_0000_0000_0000_0000_0010, "SRA/SRAI"); 

    #STEP
    aluin1 = 32'b1000_0000_0000_0000_0000_0000_0001_0101;
    aluin2 = 32'b1000_0000_0000_0000_0000_0000_0001_0001;
/* SRA/SRAI */  #STEP    funct_alu = 4'b1101;   #STEP assert_calc(aluout, 32'b1111_1111_1111_1111_1100_0000_0000_0000, "SRA/SRAI"); 

    #STEP
    aluin1 = 32'b1000_0000_0000_0000_0000_0000_0001_0101;
    aluin2 = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
/* SRA/SRAI */  #STEP    funct_alu = 4'b1101;   #STEP assert_calc(aluout, 32'b1100_0000_0000_0000_0000_0000_0000_1010, "SRA/SRAI"); 



//xxxx
    #STEP
    aluin1 = 32'b1000_0000_0000_0000_0000_0000_0001_0101;
    aluin2 = 32'b0000_0000_0000_0000_0000_0000_0000_0011;
/* xxxx */      #STEP    funct_alu = 4'b0011;   #STEP assert_calc(aluout, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx, "xxxx"); 

end

task assert_calc;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    input [0:8*10-1] message;
    begin
        if(a === b) begin
            $display("       OK (%b,%b,%s)", a, b, message);
        end
        else begin
            $display("Assert NG (%b,%b,%s)", a, b, message);
            $finish;
        end
    end
endtask

/* 表示 */
initial begin
 $dumpfile("alu.vcd");
    $dumpvars(0,alu_tb);
    $monitor(" STEP=%d\n funct_alu= %b\n aluin1=%b\n aluin2=%b\n aluout=%b\n ",$time,funct_alu,aluin1,aluin2,aluout);
end

endmodule

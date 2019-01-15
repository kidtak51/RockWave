/*
 * *****************************************************************
 * File: comp_tb.v
 * Category: Execute
 * File Created: 2019/01/16 24:31
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/16 24:53
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/16	Takuya Shono	First Version
 * *****************************************************************
 */


module comp_tb;

`include "core_general.vh"

reg [XLEN-1:0] rs1data_de; //レジスタ選択結果1 rs1データ
reg [XLEN-1:0] rs2data_de; //レジスタ選択結果2 rs2データ
reg [OPLEN-1:0] decoded_op_de; // Decoded OPcode
wire jamp_state_pre; // 比較結果

//1周期1000unit
parameter STEP = 1;

comp test(
   .rs1data_de(rs1data_de), .rs2data_de(rs2data_de),
   .decoded_op_de(decoded_op_de), .jamp_state_pre(jamp_state_pre)
);

initial begin

    decoded_op_de = 8'b0000_0000;
    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

    #STEP
    decoded_op_de = 8'b0000_0000;
    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0000;


      #STEP    decoded_op_de = 8'b0000_0000;   #STEP assert_comp(jamp_state_pre, 1'b0, "");
      #STEP    decoded_op_de = 8'b0000_0000;   #STEP assert_comp(jamp_state_pre, 1'b0, "");
      #STEP    decoded_op_de = 8'b0000_0000;   #STEP assert_comp(jamp_state_pre, 1'b0, "");
      #STEP    decoded_op_de = 8'b0000_0000;   #STEP assert_comp(jamp_state_pre, 1'b0, "");
      #STEP    decoded_op_de = 8'b0000_0000;   #STEP assert_comp(jamp_state_pre, 1'b0, "");
      #STEP    decoded_op_de = 8'b0000_1000;   #STEP assert_comp(jamp_state_pre, 1'b0, "");
      #STEP    decoded_op_de = 8'b0000_0001;   #STEP assert_comp(jamp_state_pre, 1'b0, ""); 
      #STEP    decoded_op_de = 8'b0000_1001;   #STEP assert_comp(jamp_state_pre, 1'b0, ""); 
      #STEP    decoded_op_de = 8'b0000_0100;   #STEP assert_comp(jamp_state_pre, 1'b0, ""); 
      #STEP    decoded_op_de = 8'b0000_1100;   #STEP assert_comp(jamp_state_pre, 1'b0, "");
      #STEP    decoded_op_de = 8'b0000_0110;   #STEP assert_comp(jamp_state_pre, 1'b0, ""); 
      #STEP    decoded_op_de = 8'b0000_1110;   #STEP assert_comp(jamp_state_pre, 1'b0, ""); 
      #STEP    decoded_op_de = 8'b0000_0111;   #STEP assert_comp(jamp_state_pre, 1'b0, ""); 
      #STEP    decoded_op_de = 8'b0000_1111;   #STEP assert_comp(jamp_state_pre, 1'b0, ""); 

//xxxx
    #STEP
    decoded_op_de = 8'b0000_0000;
    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0001_0101;
    rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0011;
/* xxxx */      #STEP       decoded_op_de = 8'b0000_0000;   #STEP assert_comp(jamp_state_pre, 1'bx, "x"); 

end

task assert_comp;
    input a;
    input b;
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
 $dumpfile("comp.vcd");
    $dumpvars(0,comp_tb);
    $monitor(" STEP=%d\n decoded_op_de= %b\n rs1data_de=%b\n rs2data_de=%b\n jamp_state_pre=%b\n ",$time,decoded_op_de,rs1data_de,rs2data_de,jamp_state_pre);
end

endmodule

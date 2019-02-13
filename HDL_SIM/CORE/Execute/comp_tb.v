/*
 * *****************************************************************
 * File: comp_tb.v
 * Category: Execute
 * File Created: 2019/01/16 24:31
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/02/12 06:47
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 * 2019/02/12 SLTを追加
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
wire jump_state_pre; // 比較結果

//1周期1000unit
parameter STEP = 1;

comp test(
   .rs1data_de(rs1data_de), .rs2data_de(rs2data_de),
   .decoded_op_de(decoded_op_de), .jump_state_pre(jump_state_pre)
);

initial begin

             decoded_op_de = 8'b0000_0000;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    //FUNCT3_BEQ
    #STEP    decoded_op_de = 8'bx000_xxxx;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BEQ_1");

    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0101;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BEQ_2");
    //FUNCT3_BNE
    #STEP    decoded_op_de = 8'bx001_xxxx;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0101;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BNE_1");

    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BNE_2");
    //MUST JUMP //SLT追加により削除した
    //    #STEP    decoded_op_de = 8'bx010_xxxx;
    //             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    //             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    //    #STEP    assert_comp(jump_state_pre, 1'b1, "MUST JUMP_1");

    //    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    //             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0101;
    //    #STEP    assert_comp(jump_state_pre, 1'b1, "MUST JUMP_2");
    //FUNCT3_BLT
    //rs1<rs2
    #STEP    decoded_op_de = 8'bx100_xxxx;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BLT_1");
    //rs1>rs2
    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BLT_2");
    //rs1<rs2,  rs1:signed
             rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BLT_3");
    //rs1>rs2,  rs1:signed
    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BLT_4");
    //rs1<rs2,  rs1,rs2:signed
             rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BLT_5");
    //rs1>rs2,  rs1,rs2:signed
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BLT_6");
    //equal
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BLT_7");

    //FUNCT3_BGE
    //rs1<rs2
    #STEP    decoded_op_de = 8'bx101_xxxx;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1010;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BGE_1");
    //rs1>rs2
    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BGE_2");
    //rs1<rs2,  rs1:signed
             rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BGE_3");
    //rs1>rs2,  rs1:signed
    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BGE_4");
    //rs1<rs2,  rs1,rs2:signed
             rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BGE_5");
    //rs1>rs2,  rs1,rs2:signed
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BGE_6");
    //equal
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BGE_7");

    //FUNCT3_BLTU
    //rs1<rs2
    #STEP    decoded_op_de = 8'bx110_xxxx;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BLTU_1");
    //rs1>rs2
    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BLTU_2");
    //rs1<rs2
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BLTU_3");
    //rs1>rs2
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BLTU_4");
    //equal
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BLTU_5");

    //FUNCT3_BGEU
    //rs1<rs2
    #STEP    decoded_op_de = 8'bx111_xxxx;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BGEU_1");
    //rs1>rs2
    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BGEU_2");
    //rs1<rs2
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_BGEU_3");
    //rs1>rs2
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BGEU_4");
    //equal
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_BGEU_5");

    //FUNCT3_SLT
    //rs1<rs2
    #STEP    decoded_op_de = 8'bx010_xxxx;
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_SLT_1");
    //rs1>rs2
    #STEP    rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_SLT_2");
    //rs1<rs2
             rs1data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_SLT_3");
    //rs1>rs2
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
             rs2data_de = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
    #STEP    assert_comp(jump_state_pre, 1'b1, "FUNCT3_SLT_4");
    //equal
    #STEP    rs1data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
             rs2data_de = 32'b1000_0000_0000_0000_0000_0000_0000_1001;
    #STEP    assert_comp(jump_state_pre, 1'b0, "FUNCT3_SLT_5");


    //funct3=3'b011
    #STEP    decoded_op_de = 8'bx011_xxxx;
    #STEP    assert_comp(jump_state_pre, 1'bx, "FUNCT3=3'b011");

    //funct3=3'b0x0
    #STEP    decoded_op_de = 8'bxx0x_0xxx;
    #STEP    assert_comp(jump_state_pre, 1'bx, "FUNCT3=3'b0x1");

    $display("All tests pass!!");

end

task assert_comp;
    input a;
    input b;
    input [0:8*15-1] message;
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
    $monitor(" STEP=%d\n decoded_op_de= %b\n rs1data_de=%b\n rs2data_de=%b\n jump_state_pre=%b\n ",$time,decoded_op_de,rs1data_de,rs2data_de,jump_state_pre);

end

endmodule

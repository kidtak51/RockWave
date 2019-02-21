/*
 * *****************************************************************
 * File: writeback_tb.v
 * Category: WriteBack
 * File Created: 2019/01/23 12:31
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/02/16 23:50
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description: test writeback
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/23	Takuya Shono	First Version
 * *****************************************************************
 */

module writeback_tb;

    `include "core_general.vh"

    reg phase_writeback;             // writeback Phase
     // From Memory
    reg jump_state_mw;               // PCの次のアドレスがJumpアドレス
    reg [OPLEN-1:0] decoded_op_mw;   // Decoded OPcode
    reg [4:0] rdsel_mw;              // RD選択
    reg [XLEN-1:0] next_pc_mw;       // Next PC Address for Decode
    reg [XLEN-1:0] alu_out_mw;       // ALU output
    reg [XLEN-1:0] mem_out_mw;       // Data Memory wire
    //For RegisterFile
    wire [XLEN-1:0] rddata_wr;       //出力データ 
    wire [4:0] rdsel_wr;             //RD選択
    //For Fetch
    wire [XLEN-1:0] regdata_for_pc;  // jump先アドレス
    wire jump_state_wf;              //PCの次のアドレスがJumpアドレス
    // For StateMachine
    wire stall_writeback;             // Stall writeback Phase  

    //interanl
    wire [XLEN-1:0] jump_state_selin; //セレクタに入力されるjump許可

    //1周期1000unit
    parameter STEP = 1;

    writeback test(.*);

    initial begin
            phase_writeback = 1;
            jump_state_mw   = 0;
            decoded_op_mw   = 9'b0_0000_0000;
            rdsel_mw       =  5'b0_0000;
            next_pc_mw      = 32'h0000_0000;
            alu_out_mw      = 32'h0000_0000;
            mem_out_mw      = 32'h0000_0000;

    //selecter1
    #STEP   jump_state_mw   = 1'b1;
    #STEP   assert_eq_jump_state( 0, jump_state_wf, "jump_en=0");    
    #STEP   decoded_op_mw[JUMP_EN_BIT] = 1'b1;
    #STEP   assert_eq_jump_state( 1, jump_state_wf, "jump_en=1");
    //selecter2
    #STEP   alu_out_mw    = 32'h2222_2222;
            next_pc_mw    = 32'h1111_1111;
            mem_out_mw    = 32'hAAAA_AAAA;
            jump_state_mw = 1;
            
    //ALU
    #STEP   decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L] = USE_RD_ALU;
    #STEP   assert_eq( 32'h2222_2222, rddata_wr,"ALU");
    //PC
    #STEP   decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L] = USE_RD_PC;
    #STEP   assert_eq( 32'h1111_1111, rddata_wr, "PC");
    //MEMORY
    #STEP   decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L] = USE_RD_MEMORY;
    #STEP   assert_eq( 32'hAAAA_AAAA, rddata_wr, "MEMORY");
    //JUMP
    #STEP   decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L] = USE_RD_COMP;
    #STEP   assert_eq( 32'h0000_0001, rddata_wr, "COMP");
    //JUMP
    #STEP   jump_state_mw = 0;
    #STEP   decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L] = USE_RD_COMP;
    #STEP   assert_eq( 32'h0000_0000, rddata_wr, "COMP");
    //xxx
    #STEP   jump_state_mw = 0;
    #STEP   decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L] = 2'bxx;
    #STEP   assert_eq( 32'hxxxx_xxxx, rddata_wr, "xxxx");

    //regdata_for_pc
    #STEP   alu_out_mw = 32'hAAAA_AAAA;
    #STEP   assert_eq( alu_out_mw, regdata_for_pc, "regdata_for_pc");
    #STEP   alu_out_mw = 32'h5555_5555;
    #STEP   assert_eq( alu_out_mw, regdata_for_pc, "regdata_for_pc");
   
    
    #STEP   
    $display("ALL_TESTS_PASS");
    
    $finish;
end

    initial begin
        $dumpfile("writeback.vcd");
        $dumpvars(0,writeback_tb);
        $monitor(" STEP=%d\n alu_out_mw=%h\n next_pc_mw=%h\n mem_out_mw=%h\n jump_state_mw=%b\n use_rd=%b\n rddata_wr=%h\n ",$time,alu_out_mw,next_pc_mw,mem_out_mw,jump_state_mw,decoded_op_mw[USE_RD_BIT_M:USE_RD_BIT_L],rddata_wr);
    //  $monitor(" STEP=%d\n jump_en= %b\n jump_state_mw=%b\n jump_state_wf=%b\n ",$time,decoded_op_mw[JUMP_EN_BIT],jump_state_mw,jump_state_wf);
    end

//assert 多bit信号
    task assert_eq;
        input [XLEN-1:0] a;
        input [XLEN-1:0] b;
        input [0:8*21-1] message;
        begin
            if( a === b) begin
                $display ("       OK (%h,%h,%s)", a, b, message);
            end
            else begin
                $display ("Assert NG (%h,%h,%s)", a, b, message);
                $finish;
            end
        end
    endtask

//assert 1bit信号
    task assert_eq_jump_state;
        input a;
        input b;
        input [0:8*16-1] message;
        begin
            if( a === b) begin
                $display ("       OK (%b,%b,%s)", a, b, message);
            end
            else begin
                $display ("Assert NG (%b,%b,%s)", a, b, message);
                $finish;
            end
        end
    endtask

endmodule

/*
 * *****************************************************************
 * File: top_core_tb.v
 * Category: top_core
 * File Created: 2019/01/21 12:11
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/02/18 07:27
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
 * 2019/1/21	kidtak51	First Version
 * *****************************************************************
 */

module top_core_tb(  
);
`include "core_general.vh"

reg clk;
reg rst_n;
wire[AWIDTH-1:0] inst_addr;
wire[31:0] inst_data;
wire[XLEN-1:0] data_mem_out;
wire[AWIDTH-1:0] data_mem_addr;
wire[XLEN-1:0] data_mem_wdata;
wire[2:0] data_mem_we;


top_core u_top_core(
	.clk            (clk            ),
    .rst_n          (rst_n          ),
    .inst_addr      (inst_addr      ),
    .inst_data      (inst_data      ),
    .data_mem_out   (data_mem_out   ),
    .data_mem_addr  (data_mem_addr  ),
    .data_mem_wdata (data_mem_wdata ),
    .data_mem_we    (data_mem_we    )
);

//テスト信号のbit幅
//本来はテスト対象に合わせてBit幅を定義するべきだが、
//テストコードの記述を簡略化するため。
//verilogの文法で切り捨てられることを期待し、
//テスト信号を十分大きいbit幅で定義する。
localparam TESTBITWIDTH = 128;

//テスト正解格納用変数
reg[TESTBITWIDTH-1:0] ans;

integer i;

initial begin
    $dumpfile("top_core_tb.vcd");
    $dumpvars(0,top_core_tb);

    //////////////////////////////////////////////////
    //u_top_core input port接続チェック
    //////////////////////////////////////////////////
    clk = 0;#1;
    assert_eq_m(clk,u_top_core.u_top_fetch.clk,"u_top_core.u_top_fetch.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_instruction_decode.clk,"u_top_core.u_instruction_decode.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_top_execute.clk,"u_top_core.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_top_memoryaccess.clk,"u_top_core.u_top_memoryaccess.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_register_file.clk,"u_top_core.u_register_file.clk",`__LINE__); 
    clk = 1;#1;
    assert_eq_m(clk,u_top_core.u_top_fetch.clk,"u_top_core.u_top_fetch.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_instruction_decode.clk,"u_top_core.u_instruction_decode.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_top_execute.clk,"u_top_core.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_top_memoryaccess.clk,"u_top_core.u_top_memoryaccess.clk",`__LINE__);
    assert_eq_m(clk,u_top_core.u_register_file.clk,"u_top_core.u_register_file.clk",`__LINE__); 

    rst_n = 0;#1;
    assert_eq_m(rst_n,u_top_core.u_top_fetch.rst_n,"u_top_core.u_top_fetch.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_instruction_decode.rst_n,"u_top_core.u_instruction_decode.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_top_execute.rst_n,"u_top_core.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_top_memoryaccess.rst_n,"u_top_core.u_top_memoryaccess.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_register_file.rst_n,"u_top_core.u_register_file.rst_n",`__LINE__); 
    rst_n = 1;#1;
    assert_eq_m(rst_n,u_top_core.u_top_fetch.rst_n,"u_top_core.u_top_fetch.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_instruction_decode.rst_n,"u_top_core.u_instruction_decode.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_top_execute.rst_n,"u_top_core.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_top_memoryaccess.rst_n,"u_top_core.u_top_memoryaccess.rst_n",`__LINE__);
    assert_eq_m(rst_n,u_top_core.u_register_file.rst_n,"u_top_core.u_register_file.rst_n",`__LINE__); 

    //////////////////////////////////////////////////
    //u_top_fetch output port接続チェック
    //////////////////////////////////////////////////
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_fetch.inst_addr = ans;#1;
        assert_eq_m(u_top_core.u_top_fetch.inst_addr,inst_addr,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_fetch.curr_pc_fd = ans;#1;
        assert_eq_m(u_top_core.u_top_fetch.curr_pc_fd,u_top_core.u_instruction_decode.curr_pc_fd,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_fetch.next_pc_fd = ans;#1;
        assert_eq_m(u_top_core.u_top_fetch.next_pc_fd,u_top_core.u_instruction_decode.next_pc_fd,"",`__LINE__);
        ans = ~ans;
    end
    
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_fetch.inst = ans;#1;
        assert_eq_m(u_top_core.u_top_fetch.inst,u_top_core.u_instruction_decode.inst,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_fetch.stall_fetch = ans;#1;
        assert_eq_m(u_top_core.u_top_fetch.stall_fetch,u_top_core.u_statemachine.stall_fetch,"",`__LINE__);
        ans = ~ans;
    end

    //////////////////////////////////////////////////
    //u_instruction_decode output port接続チェック
    //////////////////////////////////////////////////
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.rs1sel = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.rs1sel,u_top_core.u_register_file.rs1sel,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.rs2sel = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.rs2sel,u_top_core.u_register_file.rs2sel,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.imm = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.imm,u_top_core.u_top_execute.imm,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.rs1data_de = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.rs1data_de,u_top_core.u_top_execute.rs1data_de,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.curr_pc_de = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.curr_pc_de,u_top_core.u_top_execute.curr_pc_de,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.next_pc_de = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.next_pc_de,u_top_core.u_top_execute.next_pc_de,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.funct_alu = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.funct_alu,u_top_core.u_top_execute.funct_alu,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.rdsel_de = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.rdsel_de,u_top_core.u_top_execute.rdsel_de,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.decoded_op_de = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.decoded_op_de,u_top_core.u_top_execute.decoded_op_de,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_instruction_decode.stall_decode = ans;#1;
        assert_eq_m(u_top_core.u_instruction_decode.stall_decode,u_top_core.u_statemachine.stall_decode,"",`__LINE__);
        ans = ~ans;
    end

    //////////////////////////////////////////////////
    //u_top_execute output port接続チェック
    //////////////////////////////////////////////////
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_execute.decoded_op_em = ans;#1;
        assert_eq_m(u_top_core.u_top_execute.decoded_op_em,u_top_core.u_top_memoryaccess.decoded_op_em,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_execute.rs2data_em = ans;#1;
        assert_eq_m(u_top_core.u_top_execute.rs2data_em,u_top_core.u_top_memoryaccess.rs2data_em,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_execute.jump_state_em = ans;#1;
        assert_eq_m(u_top_core.u_top_execute.jump_state_em,u_top_core.u_top_memoryaccess.jump_state_em,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_execute.rdsel_em = ans;#1;
        assert_eq_m(u_top_core.u_top_execute.rdsel_em,u_top_core.u_top_memoryaccess.rdsel_em,"",`__LINE__);
        ans = ~ans;
    end
    
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_execute.next_pc_em = ans;#1;
        assert_eq_m(u_top_core.u_top_execute.next_pc_em,u_top_core.u_top_memoryaccess.next_pc_em,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_execute.alu_out_em = ans;#1;
        assert_eq_m(u_top_core.u_top_execute.alu_out_em,u_top_core.u_top_memoryaccess.alu_out_em,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_execute.stall_execute = ans;#1;
        assert_eq_m(u_top_core.u_top_execute.stall_execute,u_top_core.u_statemachine.stall_execute,"",`__LINE__);
        ans = ~ans;
    end

    //////////////////////////////////////////////////
    //u_top_memoryaccess output port接続チェック
    //////////////////////////////////////////////////
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.data_mem_addr = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.data_mem_addr,data_mem_addr,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.data_mem_we = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.data_mem_we,data_mem_we,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.decoded_op_mw = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.decoded_op_mw,u_top_core.u_writeback.decoded_op_mw,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.jump_state_mw = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.jump_state_mw,u_top_core.u_writeback.jump_state_mw,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.rdsel_mw = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.rdsel_mw,u_top_core.u_writeback.rdsel_mw,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.next_pc_mw = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.next_pc_mw,u_top_core.u_writeback.next_pc_mw,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.alu_out_mw = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.alu_out_mw,u_top_core.u_writeback.alu_out_mw,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.mem_out_mw = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.mem_out_mw,u_top_core.u_writeback.mem_out_mw,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_top_memoryaccess.stall_memoryaccess = ans;#1;
        assert_eq_m(u_top_core.u_top_memoryaccess.stall_memoryaccess,u_top_core.u_statemachine.stall_memoryaccess,"",`__LINE__);
        ans = ~ans;
    end

    //////////////////////////////////////////////////
    //u_writeback output port接続チェック
    //////////////////////////////////////////////////
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_writeback.rddata_wr = ans;#1;
        assert_eq_m(u_top_core.u_writeback.rddata_wr,u_top_core.u_register_file.rddata_wr,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_writeback.regdata_for_pc = ans;#1;
        assert_eq_m(u_top_core.u_writeback.regdata_for_pc,u_top_core.u_top_fetch.regdata_for_pc,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_writeback.jump_state_wf = ans;#1;
        assert_eq_m(u_top_core.u_writeback.jump_state_wf,u_top_core.u_top_fetch.jump_state_wf,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_writeback.rdsel_wr = ans;#1;
        assert_eq_m(u_top_core.u_writeback.rdsel_wr,u_top_core.u_register_file.rdsel_wr,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_writeback.stall_writeback = ans;#1;
        assert_eq_m(u_top_core.u_writeback.stall_writeback,u_top_core.u_statemachine.stall_writeback,"",`__LINE__);
        ans = ~ans;
    end

    //////////////////////////////////////////////////
    //u_register_fileのoutput port接続チェック
    //////////////////////////////////////////////////
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_register_file.rs1data_rd = ans;#1;
        assert_eq_m(u_top_core.u_register_file.rs1data_rd,u_top_core.u_instruction_decode.rs1data_rd,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_register_file.rs2data_rd = ans;#1;
        assert_eq_m(u_top_core.u_register_file.rs2data_rd,u_top_core.u_instruction_decode.rs2data_rd,"",`__LINE__);
        ans = ~ans;
    end

    //////////////////////////////////////////////////
    //u_statemachine output port接続チェック
    //////////////////////////////////////////////////
    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_statemachine.phase_fetch = ans;#1;
        assert_eq_m(u_top_core.u_statemachine.phase_fetch,u_top_core.u_top_fetch.phase_fetch,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_statemachine.phase_decode = ans;#1;
        assert_eq_m(u_top_core.u_statemachine.phase_decode,u_top_core.u_instruction_decode.phase_decode,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_statemachine.phase_execute = ans;#1;
        assert_eq_m(u_top_core.u_statemachine.phase_execute,u_top_core.u_top_execute.phase_execute,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_statemachine.phase_memoryaccess = ans;#1;
        assert_eq_m(u_top_core.u_statemachine.phase_memoryaccess,u_top_core.u_top_memoryaccess.phase_memoryaccess,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_statemachine.phase_writeback = ans;#1;
        assert_eq_m(u_top_core.u_statemachine.phase_writeback,u_top_core.u_register_file.phase_writeback,"",`__LINE__);
        ans = ~ans;
    end

    ans = {TESTBITWIDTH{1'b1}};
    for ( i=0; i<2; i=i+1 ) begin
        force u_top_core.u_statemachine.phase_writeback = ans;#1;
        assert_eq_m(u_top_core.u_statemachine.phase_writeback,u_top_core.u_top_fetch.phase_writeback,"",`__LINE__);
        ans = ~ans;
    end

    $display("All tests pass!!");
    $finish;
end

task assert_eq_m;
    input [TESTBITWIDTH-1:0] expectValue;
    input [TESTBITWIDTH-1:0] resultValue;
    input [0:8*50-1] message;
    input [15:0] line;
    begin
        if(expectValue == resultValue) begin
        end
        else begin
            $display("Assert NG (expect:%h, result:%h, Line:%05d, message:%s)", expectValue, resultValue, line, message);
            #14
            $finish;
        end
    end
endtask

endmodule


//writebackモジュールが実装されたら下記は削除する
//module writeback(
//    input[XLEN-1:0] mem_out_mw,
//    input jump_state_mw,
//    input[XLEN-1:0] next_pc_mw,
//    input[XLEN-1:0] alu_out_mw,
//    input[OPLEN-1:0] decoded_op_mw,
//    input[4:0] rdsel_mw,
//    output[XLEN-1:0] rddata_wr,
//    output[XLEN-1:0] regdata_for_pc,
//    output jump_state_wf,
//    output[4:0] rdsel_wr,
//    output stall_writeback
//);
//`include "core_general.vh"
//endmodule


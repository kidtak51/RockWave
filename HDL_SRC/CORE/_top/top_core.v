/*
 * *****************************************************************
 * File: top_core.v
 * Category: CORE
 * File Created: 2019/01/10 07:14
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/03/03 15:54
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/02/20   shonta      phase_writebackを接続した
 * 2019/01/10	kidtak51	First Version
 * *****************************************************************
 */
module top_core(
    //system
    input clk,//CPUクロック
    input rst_n,//非同期リセット, 1'b1固定可
    
    //instruction memory
    output [AWIDTH-1:0] inst_addr,//instruction memoryのアドレスを接続する
    input [XLEN-1:0] inst_data,//instruction memoryのデータを接続する

    //data memory
    input [XLEN-1:0] data_mem_out,//データメモリからのデータ出力を接続する
    output [XLEN-1:0] data_mem_addr,//データメモリへのアドレスを接続する
    output [XLEN-1:0] data_mem_wdata,//データメモリへのデータ入力を接続する
    output [2:0] data_mem_we//データメモリへのWriteEnable信号を接続する
);

`include "core_general.vh"
wire phase_fetch;
wire stall_fetch;
wire phase_decode;
wire stall_decode;
wire phase_execute;
wire stall_execute;
wire phase_memoryaccess;
wire stall_memoryaccess;
wire phase_writeback;
wire stall_writeback;
wire jump_state_wf;             // PCの次のアドレスがJumpアドレス//////
wire [XLEN-1:0] regdata_for_pc; // Jump先アドレス
wire [XLEN-1:0] inst_data;      // InstMemory Data
wire [AWIDTH-1:0] inst_addr;   // InstMemory Address
wire [XLEN-1:0] curr_pc_fd;    // Current PC Address for Decode
wire [XLEN-1:0] next_pc_fd;    //    Next PC Address for Decode
wire [31:0] inst;          // Instruction
wire [XLEN-1:0] rs1data_de; //レジスタ選択結果1 rs1_data_rdを(ほぼ)そのまま出力
wire [XLEN-1:0] rs2data_de; //レジスタ選択結果2 rs2_data_rdを(ほぼ)そのまま出力
wire [XLEN-1:0] curr_pc_de; //現在のプログラムカウンタの値 curr_pc_fdを(ほぼ)そのまま出力
wire [XLEN-1:0] next_pc_de; //次のプログラムカウンタの値 next_pc_fdを(ほぼ)そのまま出力
wire [3:0] funct_alu; //alu演算器選択信号
wire [4:0] rdsel_de; //データメモリ選択信号
wire [OPLEN-1:0] decoded_op_de; //opcodeデコード結果、後段のaluやmemory_accessで使用することを想定
wire [XLEN-1:0] imm;
wire [XLEN-1:0] next_pc_em; //次のプログラムカウンタの値 next_pc_fdを(ほぼ)そのまま出力
wire [4:0] rdsel_em; //データメモリ選択信号
wire [OPLEN-1:0] decoded_op_em; //opcodeデコード結果、後段のaluやmemory_accessで使用することを想定
wire [XLEN-1:0] alu_out_em;
wire jump_state_em;
wire [XLEN-1:0] rs2data_em;     // RS2data
wire [OPLEN-1:0] decoded_op_mw;// Decoded OPcode
wire jump_state_mw;            // PCの次のアドレスがJumpアドレス
wire [4:0] rdsel_mw;           // RD選択
wire [XLEN-1:0] next_pc_mw;    // Next PC Address for Decode
wire [XLEN-1:0] alu_out_mw;    // ALU 
wire [XLEN-1:0] mem_out_mw;        // Data Memory 
wire [XLEN-1:0] rddata_wr;   // 入力データ
wire [4:0] rdsel_wr;         // RD 選択
wire [4:0] rs1sel;           // RS1 選択
wire [4:0] rs2sel;           // RS2 選択
wire [XLEN-1:0] rs1data_rd;  // 出力データ (rs1)
wire [XLEN-1:0] rs2data_rd;   // 出力データ (rs2)

statemachine u_statemachine(
	.clk                (clk             ),
    .rst_n              (rst_n           ),
    .phase_fetch        (phase_fetch     ),
    .phase_decode       (phase_decode    ),
    .phase_execute      (phase_execute   ),
    .phase_memoryaccess (phase_memoryaccess ),
    .phase_writeback    (phase_writeback    ),
    .stall_execute      (stall_execute      ),
    .stall_fetch        (stall_fetch        ),
    .stall_decode       (stall_decode       ),
    .stall_memoryaccess (stall_memoryaccess ),
    .stall_writeback    (stall_writeback)
);

writeback u_writeback(
    .mem_out_mw(mem_out_mw),
    .jump_state_mw(jump_state_mw),
    .next_pc_mw(next_pc_mw),
    .alu_out_mw(alu_out_mw),
    .decoded_op_mw(decoded_op_mw),
    .rdsel_mw(rdsel_mw),
    .rddata_wr(rddata_wr),
    .regdata_for_pc(regdata_for_pc),
    .jump_state_wf(jump_state_wf),
    .rdsel_wr(rdsel_wr),
    .phase_writeback(phase_writeback),
    .stall_writeback(stall_writeback)
);

top_fetch u_top_fetch(
	.clk             (clk             ),
    .rst_n           (rst_n           ),
    .phase_fetch     (phase_fetch     ),
    .phase_writeback (phase_writeback ),
    .jump_state_wf   (jump_state_wf   ),
    .regdata_for_pc  (regdata_for_pc  ),
    .inst_data       (inst_data       ),
    .inst_addr       (inst_addr       ),
    .curr_pc_fd      (curr_pc_fd      ),
    .next_pc_fd      (next_pc_fd      ),
    .inst            (inst            ),
    .stall_fetch     (stall_fetch     )
);


instruction_decode u_instruction_decode(
	.clk           (clk         ),
    .rst_n         (rst_n       ),
    .inst          (inst        ),
    .rs1data_rd    (rs1data_rd  ),
    .rs2data_rd    (rs2data_rd  ),
    .curr_pc_fd    (curr_pc_fd  ),
    .next_pc_fd    (next_pc_fd  ),
    .phase_decode  (phase_decode),
    .rs1sel        (rs1sel      ),
    .rs2sel        (rs2sel      ),
    .imm           (imm         ),
    .rs1data_de    (rs1data_de  ),
    .rs2data_de    (rs2data_de  ),
    .curr_pc_de    (curr_pc_de  ),
    .next_pc_de    (next_pc_de  ),
    .funct_alu     (funct_alu   ),
    .rdsel_de      (rdsel_de    ),
    .stall_decode  (stall_decode),
    .decoded_op_de (decoded_op_de)
);

top_execute u_top_execute(
	.clk           (clk           ),
    .rst_n         (rst_n         ),
    .next_pc_de    (next_pc_de    ),
    .curr_pc_de    (curr_pc_de    ),
    .rs1data_de    (rs1data_de    ),
    .rs2data_de    (rs2data_de    ),
    .imm           (imm           ),
    .rdsel_de      (rdsel_de      ),
    .funct_alu     (funct_alu     ),
    .decoded_op_de (decoded_op_de ),
    .next_pc_em    (next_pc_em    ),
    .alu_out_em    (alu_out_em    ),
    .jump_state_em (jump_state_em ),
    .rdsel_em      (rdsel_em      ),
    .rs2data_em    (rs2data_em    ),
    .decoded_op_em (decoded_op_em ),
    .phase_execute (phase_execute ),
    .stall_execute (stall_execute )
);



top_memoryaccess u_top_memoryaccess(
	.clk                (clk                ),
    .rst_n              (rst_n              ),
    .phase_memoryaccess (phase_memoryaccess ),
    .data_mem_out       (data_mem_out       ),
    .decoded_op_em      (decoded_op_em      ),
    .jump_state_em      (jump_state_em      ),
    .rdsel_em           (rdsel_em           ),
    .next_pc_em         (next_pc_em         ),
    .alu_out_em         (alu_out_em         ),
    .rs2data_em         (rs2data_em         ),
    .data_mem_addr      (data_mem_addr      ),
    .data_mem_wdata     (data_mem_wdata     ),
    .data_mem_we        (data_mem_we        ),
    .decoded_op_mw      (decoded_op_mw      ),
    .jump_state_mw      (jump_state_mw      ),
    .rdsel_mw           (rdsel_mw           ),
    .next_pc_mw         (next_pc_mw         ),
    .alu_out_mw         (alu_out_mw         ),
    .mem_out_mw         (mem_out_mw         ),
    .stall_memoryaccess (stall_memoryaccess )
);

register_file u_register_file(
	.clk             (clk             ),
    .rst_n           (rst_n           ),
    .rddata_wr       (rddata_wr       ),
    .rdsel_wr        (rdsel_wr        ),
    .phase_writeback (phase_writeback ),
    .rs1sel          (rs1sel          ),
    .rs2sel          (rs2sel          ),
    .rs1data_rd      (rs1data_rd      ),
    .rs2data_rd      (rs2data_rd      )
);




endmodule // top_core

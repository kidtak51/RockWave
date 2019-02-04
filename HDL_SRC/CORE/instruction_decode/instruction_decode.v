/*
 * *****************************************************************
 * File: instruction_decode.v
 * Category: instruction_decode
 * File Created: 2018/12/17 20:41
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/02/04 07:12
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   デコードブロック
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/17	kidtak51	First Version
 * *****************************************************************
 */

module instruction_decode(
    input clk, //CPUの動作クロック
    input rst_n, //リセット 非同期リセットを想定しているものの, リセット不使用のデザインでも使用可能 リセット不使用の場合は1固定すること
    input[31:0] inst, //デコード前の命令, Fetchした値を入力する
    input[XLEN-1:0] rs1data_rd, //レジスタ選択結果1 レジスタ選択信号1の結果
    input[XLEN-1:0] rs2data_rd, //レジスタ選択結果2 レジスタ選択信号2の結果
    input[XLEN-1:0] curr_pc_fd, //現在のプログラムカウンタの値
    input[XLEN-1:0] next_pc_fd, //次のプログラムカウンタの値
    input phase_decode, //instruction_decodeブロックの出力段FFのEnable信号
    output[4:0] rs1sel, //レジスタ選択信号1 register_fileに接続する
    output[4:0] rs2sel, //レジスタ選択信号2 register_fileに接続する
    output[XLEN-1:0] imm, //即値、fetchした値をそのまま入力する
    output[XLEN-1:0] rs1data_de, //レジスタ選択結果1 rs1_data_rdを(ほぼ)そのまま出力
    output[XLEN-1:0] rs2data_de, //レジスタ選択結果2 rs2_data_rdを(ほぼ)そのまま出力
    output[XLEN-1:0] curr_pc_de, //現在のプログラムカウンタの値 curr_pc_fdを(ほぼ)そのまま出力
    output[XLEN-1:0] next_pc_de, //次のプログラムカウンタの値 next_pc_fdを(ほぼ)そのまま出力
    output[3:0] funct_alu, //alu演算器選択信号
    output[4:0] rdsel_de, //データメモリ選択信号
    output stall_decode,
    output[OPLEN-1:0] decoded_op_de //opcodeデコード結果、後段のaluやmemory_accessで使用することを想定
);

//parameter
`include "core_general.vh"

//common
localparam LUI = 7'b01_101_11;
localparam AUIPC = 7'b00_101_11;
localparam JAL = 7'b11_011_11;
localparam JALR = 7'b11_001_11;
localparam BRANCH = 7'b11_000_11;
localparam LOAD = 7'b00_000_11;
localparam STORE = 7'b01_000_11;
localparam OP_IMM = 7'b00_100_11;
localparam OP = 7'b01_100_11;
localparam MISC_MEM = 7'b00_011_11;
localparam SYSTEM = 7'b11_100_11;

//commom
assign stall_decode = 1'b0;
wire[6:0] inst_op = inst[6:0];

//use_alu_in1
wire use_alu_in1_system = (inst_funct3[2] == 1'b0) ? USE_ALU_IN1_RS1DATA : USE_ALU_IN1_PC;
wire use_alu_in1 = fnc_use_alu_in1(inst_op, use_alu_in1_system);
function fnc_use_alu_in1(
    input[6:0] op,
    input use_alu_in1_system
);
begin
    case (op)
        //LUIはrs1の値を持たないものの、後段のALUがrs1 = 0を要求するために必要
        LUI : fnc_use_alu_in1 = USE_ALU_IN1_RS1DATA;
        JALR, LOAD, STORE, OP_IMM, OP : fnc_use_alu_in1 = USE_ALU_IN1_RS1DATA;
        SYSTEM : fnc_use_alu_in1 = use_alu_in1_system;
        BRANCH, AUIPC, JAL : fnc_use_alu_in1 = USE_ALU_IN1_PC;
        default : fnc_use_alu_in1 = 1'bx;
    endcase
end  
endfunction

//use_alu_in2
wire use_alu_in2 = fnc_use_alu_in2(inst_op);
function fnc_use_alu_in2(
    input[6:0] op
);
begin
    case (op)
        OP : fnc_use_alu_in2 = USE_ALU_IN2_RS2DATA;
        BRANCH, LUI, AUIPC, JAL, JALR, LOAD, STORE, OP_IMM : fnc_use_alu_in2 = USE_ALU_IN2_IMM;
        default : fnc_use_alu_in2 = 1'bx;
    endcase
end  
endfunction
 
//rd_data_sel
wire[USE_RD_BIT_M-USE_RD_BIT_L:0] rd_data_sel_opimm = ((inst_funct3 == FUNCT3_SLT) || (inst_funct3 == FUNCT3_SLTU)) ? USE_RD_COMP : USE_RD_ALU;
wire[USE_RD_BIT_M-USE_RD_BIT_L:0] rd_data_sel = fnc_rd_data_sel(inst_op, rd_data_sel_opimm);
function [USE_RD_BIT_M-USE_RD_BIT_L:0] fnc_rd_data_sel(
    input[6:0] op,
    input[USE_RD_BIT_M-USE_RD_BIT_L:0] rd_data_sel_opimm
);
begin
    case (op)
        JAL, JALR : fnc_rd_data_sel = USE_RD_PC;
        LOAD : fnc_rd_data_sel = USE_RD_MEMORY;
        OP_IMM : fnc_rd_data_sel = rd_data_sel_opimm;
        default : fnc_rd_data_sel = USE_RD_ALU;
    endcase
end  
endfunction

//rd_sel
wire[4:0] inst_rd = inst[11:7];
wire rd_no_write_case = (inst_op == STORE) || (inst_op == BRANCH);
wire[4:0] rd_sel = rd_no_write_case ? 5'd0 : inst_rd;

//funct3
wire[2:0] inst_funct3_raw = inst[14:12];
wire[2:0] inst_funct3 = ((inst_op == JAL) || (inst_op == JALR)) ? FUNCT3_JUMP : inst_funct3_raw;

//funct_alu
wire[6:0] inst_funct7_raw = inst[31:25];
//OPとOP_IMMの一部の条件以外はfunct7は未使用。aluにfunct7[5]をそのまま入力するので、未使用の条件では0固定にする。
wire[6:0] inst_funct7 = ((inst_op == OP) || ((inst_op == OP_IMM) && (inst_funct3_raw[2:0] == 2'b01))) ? inst_funct7_raw : 7'd0;
//force_add_caseなら強制ADD(4'd0)
wire force_add_case = (inst_op == BRANCH) || (inst_op == AUIPC) || (inst_op == LOAD) || (inst_op == STORE) || (inst_op == LUI) || (inst_op == JAL);
wire[3:0] funct_alu_pre = force_add_case ? 4'd0 : {inst_funct7[5], inst_funct3_raw};

//rs1, rs2 ここはFFを通らない
assign rs1sel = (inst_op == LUI) ? 5'd0 : inst[19:15];
assign rs2sel = inst[24:20];

//imm
wire[XLEN-1:0] imm_pre = fnc_imm(inst_op, inst);
function [XLEN-1:0] fnc_imm(
    input[6:0] op,
    input[31:0] inst_data
);
begin
    case (op)
        LUI, AUIPC : 
            fnc_imm = {{(XLEN-31){inst_data[31]}}, inst_data[30:20], inst_data[19:12], 12'b0000_0000_0000};
        JAL : 
            fnc_imm = {{(XLEN-20){inst_data[31]}}, inst_data[19:12], inst_data[20], inst_data[30:25], inst_data[24:21], 1'b0};
        JALR, LOAD, OP_IMM : 
            fnc_imm = {{(XLEN-11){inst_data[31]}}, inst_data[30:25], inst_data[24:21], inst_data[20]};
        BRANCH :
            fnc_imm = {{(XLEN-12){inst_data[31]}}, inst_data[7], inst_data[30:25], inst_data[11:8], 1'b0};
        STORE : 
            fnc_imm = {{(XLEN-11){inst_data[31]}}, inst_data[30:25], inst_data[11:8], inst_data[7]};
        OP, MISC_MEM, SYSTEM : 
            fnc_imm = {XLEN{1'bx}};
        default : 
            fnc_imm = {XLEN{1'bx}}; 
    endcase
end  
endfunction

//jump_en
wire jump_en = (inst_op == JAL) || (inst_op == JALR) || (inst_op == BRANCH); 

//data memory write enable
wire data_mem_we = (inst_op == STORE);

//decoded_op
wire[OPLEN-1:0] decoded_op_pre;
assign decoded_op_pre[USE_ALU_IN1_BIT] = use_alu_in1;
assign decoded_op_pre[USE_ALU_IN2_BIT] = use_alu_in2;
assign decoded_op_pre[USE_RD_BIT_M:USE_RD_BIT_L] = rd_data_sel;
assign decoded_op_pre[FUNCT3_BIT_M:FUNCT3_BIT_L] = inst_funct3;
assign decoded_op_pre[JUMP_EN_BIT] = jump_en;
assign decoded_op_pre[DATA_MEM_WE_BIT] = data_mem_we;

//FF
obuf #(.WIDTH(XLEN))  u_o1(.d_in(imm_pre),        .d_out(imm),           .clk(clk), .rst_n(rst_n), .en(phase_decode));
obuf #(.WIDTH(XLEN))  u_o2(.d_in(next_pc_fd),     .d_out(next_pc_de),    .clk(clk), .rst_n(rst_n), .en(phase_decode));
obuf #(.WIDTH(XLEN))  u_o3(.d_in(curr_pc_fd),     .d_out(curr_pc_de),    .clk(clk), .rst_n(rst_n), .en(phase_decode));
obuf #(.WIDTH(XLEN))  u_o4(.d_in(rs1data_rd),     .d_out(rs1data_de),    .clk(clk), .rst_n(rst_n), .en(phase_decode));
obuf #(.WIDTH(XLEN))  u_o5(.d_in(rs2data_rd),     .d_out(rs2data_de),    .clk(clk), .rst_n(rst_n), .en(phase_decode));
obuf #(.WIDTH(4)   )  u_o6(.d_in(funct_alu_pre),  .d_out(funct_alu),     .clk(clk), .rst_n(rst_n), .en(phase_decode));
obuf #(.WIDTH(5)   )  u_o7(.d_in(rd_sel),         .d_out(rdsel_de),      .clk(clk), .rst_n(rst_n), .en(phase_decode));
obuf #(.WIDTH(OPLEN)) u_o8(.d_in(decoded_op_pre), .d_out(decoded_op_de), .clk(clk), .rst_n(rst_n), .en(phase_decode));

endmodule

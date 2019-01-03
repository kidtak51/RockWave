/*
 * *****************************************************************
 * File: instruction_decode.v
 * Category: instruction_decode
 * File Created: 2018/12/17 20:41
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/01/04 24:23
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/17	kidtak51	First Version
 * *****************************************************************
 */

module instruction_decode(
    input clk,
    input rst_n,
    input[31:0] inst,
    input[XLEN-1:0] rs1_data_rd,
    input[XLEN-1:0] rs2_data_rd,
    input[XLEN-1:0] curr_pc_fd,
    input[XLEN-1:0] next_pc_fd,
    input decode_en,
    output[4:0] rs1_sel,
    output[4:0] rs2_sel,
    output reg[XLEN-1:0] imm,
    output reg[XLEN-1:0] rs1_data_de,
    output reg[XLEN-1:0] rs2_data_de,
    output reg[XLEN-1:0] curr_pc_de,
    output reg[XLEN-1:0] next_pc_de,
    output reg[3:0] funct_alu,
    output reg[4:0] rd_sel_de,
    output reg[OPLEN-1:0] decoded_op
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
wire[6:0] inst_op = inst[6:0];

//use_rs1
wire use_rs1 = fnc_use_rs1(inst_op, inst_funct3);
function fnc_use_rs1(
    input[6:0] op,
    input[2:0] fn3
);
begin
    case (op)
        LUI, JALR, BRANCH, LOAD, STORE, OP_IMM, OP : fnc_use_rs1 = USE_RS1_RS1DATA;
        SYSTEM : fnc_use_rs1 = (fn3[2] == 1'b0) ? USE_RS1_RS1DATA : USE_RS1_PC;
        default : fnc_use_rs1 = USE_RS1_PC;
    endcase
end  
endfunction

//use_rs2
wire use_rs2 = fnc_use_rs2(inst_op);
function fnc_use_rs2(
    input[6:0] op
);
begin
    case (op)
        BRANCH, STORE, OP : fnc_use_rs2 = USE_RS2_RS2DATA;
        default : fnc_use_rs2 = USE_RS2_IMM;
    endcase
end  
endfunction
 
//rd_data_sel
wire[USE_RD_BIT_M-USE_RD_BIT_L:0] rd_data_sel = fnc_rd_data_sel(inst_op, inst_funct3);
function [USE_RD_BIT_M-USE_RD_BIT_L:0] fnc_rd_data_sel(
    input[6:0] op,
    input[2:0] fn3
);
begin
    case (op)
        JAL, JALR : fnc_rd_data_sel = USE_RD_PC;
        LOAD : fnc_rd_data_sel = USE_RD_MEMORY;
        OP_IMM : fnc_rd_data_sel = ((fn3 == FUNCT3_SLT) || (fn3 == FUNCT3_SLTU)) ? USE_RD_COMP : USE_RD_ALU; 
        default : fnc_rd_data_sel = USE_RD_ALU;
    endcase
end  
endfunction

//rd_sel
wire[4:0] inst_rd = inst[11:7];
wire[4:0] rd_sel = (inst_op == STORE) ? 5'd0 : inst_rd;

//funct3
wire[2:0] inst_funct3_raw = inst[14:12];
wire[2:0] inst_funct3 = ((inst_op == JAL) || (inst_op == JALR)) ? FUNCT3_JUMP : inst_funct3_raw;

//funct_alu
wire[6:0] inst_funct7 = inst[31:25];
wire[3:0] funct_alu_pre = {inst_funct7[5], inst_funct3_raw};

//rs1, rs2 ここはFFを通らない
assign rs1_sel = (inst_op == LUI) ? 5'd0 : inst[19:15];
assign rs2_sel = inst[24:20];

//imm
wire[XLEN-1:0] imm_pre = fnc_imm(inst_op, inst);
function [XLEN-1:0] fnc_imm(
    input[6:0] op,
    input[31:0] inst_data
);
begin
    case (op)
        LUI, AUIPC : fnc_imm = {{(XLEN-32){inst_data[31]}}, inst_data[31:12] , 12'b0000_0000_0000};
        JAL : begin
            {fnc_imm[20],fnc_imm[10:1],fnc_imm[11]} = inst_data[31:20];
            fnc_imm[19:12] = inst_data[19:12];
            fnc_imm[XLEN-1:21] = {XLEN{inst_data[31]}};
            fnc_imm[0] = 1'b0;
        end
        JALR, LOAD, OP_IMM : fnc_imm = {{(XLEN){inst_data[31]}}, inst_data[31:20]};
        BRANCH : begin
            {fnc_imm[12], fnc_imm[10:5]} = inst_data[31:25];
            {fnc_imm[4:1], fnc_imm[11]} = inst_data[11:7];
            fnc_imm[XLEN-1:13] = {XLEN{inst_data[31]}};
            fnc_imm[0] = 1'b0;
        end
        STORE : begin
            fnc_imm[11:5] = inst_data[31:25];
            fnc_imm[4:0] = inst_data[11:7];
            fnc_imm[XLEN-1:12] = {XLEN{inst_data[31]}};
        end
        OP, MISC_MEM, SYSTEM : fnc_imm = {XLEN{1'b0}};
        default : fnc_imm = {XLEN{1'b0}}; 
    endcase
end  
endfunction

//jump_en
wire jump_en = (inst_op == JAL) || (inst_op == JALR) || (inst_op == BRANCH); 

//data memory write enable
wire data_mem_we = (inst_op == STORE);

//FF
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        imm <= {XLEN{1'b0}};
        next_pc_de <= {XLEN{1'b0}};
        curr_pc_de <= {XLEN{1'b0}};
        rs1_data_de <= {XLEN{1'b0}};
        rs2_data_de <= {XLEN{1'b0}};
        funct_alu <= {XLEN{1'b0}};
        rd_sel_de <= {XLEN{1'b0}};

        decoded_op <= {OPLEN{1'b0}};
    end
    else if (decode_en) begin
        imm <= imm_pre;
        next_pc_de <= next_pc_fd;
        curr_pc_de <= curr_pc_fd;
        rs1_data_de <= rs1_data_rd;
        rs2_data_de <= rs2_data_rd;
        funct_alu <= funct_alu_pre;
        rd_sel_de <= rd_sel;

        decoded_op[USE_RS1_BIT] <= use_rs1;
        decoded_op[USE_RS2_BIT] <= use_rs2;
        decoded_op[USE_RD_BIT_M:USE_RD_BIT_L] <= rd_data_sel;
        decoded_op[FUNCT3_BIT_M:FUNCT3_BIT_L] <= inst_funct3;
        decoded_op[JUMP_EN_BIT] <= jump_en;
        decoded_op[DATA_MEM_WE_BIT] <= data_mem_we;
    end
end

endmodule

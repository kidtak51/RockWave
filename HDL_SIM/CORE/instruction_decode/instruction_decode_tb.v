/*
 * *****************************************************************
 * File: instruction_decode_tb.v
 * Category: instruction_decode
 * File Created: 2018/12/17 12:11
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/01/12 17:23
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
 
//`include param_decode.v

module instruction_decode_tb(  
);
`include "core_general.vh"

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

reg clk;
reg rst_n;
reg [31:0] inst;
reg [XLEN-1:0] rs1data_rd;
reg [XLEN-1:0] rs2data_rd;
reg [XLEN-1:0] curr_pc_fd;
reg [XLEN-1:0] next_pc_fd;
reg  phase_decode;
/**/

wire [4:0] rs1sel;
wire [4:0] rs2sel;
wire[XLEN-1:0] imm;
wire[XLEN-1:0] rs1data_de;
wire[XLEN-1:0] rs2data_de;
wire[XLEN-1:0] curr_pc_de;
wire[XLEN-1:0] next_pc_de;
wire[3:0] funct_alu;
wire[4:0] rdsel_de;
wire[OPLEN-1:0] decoded_op_de;

instruction_decode u_instruction_decode(
    .clk(clk),
    .rst_n(rst_n),
    .inst(inst),
    .rs1data_rd(rs1data_rd),
    .rs2data_rd(rs2data_rd),
    .curr_pc_fd(curr_pc_fd),
    .next_pc_fd(next_pc_fd),
    .phase_decode(phase_decode),
    .rs1sel(rs1sel),
    .rs2sel(rs2sel),
    .imm(imm),
    .rs1data_de(rs1data_de),
    .rs2data_de(rs2data_de),
    .curr_pc_de(curr_pc_de),
    .next_pc_de(next_pc_de),
    .funct_alu(funct_alu),
    .rdsel_de(rdsel_de),
    .decoded_op_de(decoded_op_de)
);




initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

//テスト正解格納用変数
reg[XLEN-1:0] ans;

initial begin
    $dumpfile("instruction_decode_tb.vcd");
    $dumpvars(0,instruction_decode_tb);
    inst = 32'd0;
    rs1data_rd = {XLEN{1'b0}};
    rs2data_rd = {XLEN{1'b0}};
    curr_pc_fd = {XLEN{1'b0}};
    next_pc_fd = {XLEN{1'b0}};
    phase_decode = 1'b1;

    @(posedge clk)
    rst_n = 1;
    //imm test
    inst=32'b11011101_11011001_11010000_01101111;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFF9DDDC, "type=J; imm=4294565340; opecode=1101111;");
    inst=32'b00110000_00000000_00000000_11100011;	@(posedge clk)#1;	assert_eq_m(imm, 32'h00000B00, "type=B; imm=2816; opecode=1100011;");
    inst=32'b10011000_00000000_00000000_11100011;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFFFF980, "type=B; imm=4294965632; opecode=1100011;");				
    inst=32'b01101000_00000000_00000000_10100011;	@(posedge clk)#1;	assert_eq_m(imm, 32'h00000681, "type=S; imm=1665; opecode=0100011;");
    inst=32'b11111000_00000000_00001011_00100011;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFFFFF96, "type=S; imm=4294967190; opecode=0100011;");
    inst=32'b00001010_00000000_00000000_01100111;	@(posedge clk)#1;	assert_eq_m(imm, 32'h000000A0, "type=I; imm=160; opecode=1100111;");
    inst=32'b00001010_00000000_00000000_00000011;	@(posedge clk)#1;	assert_eq_m(imm, 32'h000000A0, "type=I; imm=160; opecode=0000011;");
    inst=32'b00001010_00000000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(imm, 32'h000000A0, "type=I; imm=160; opecode=0010011;");
    inst=32'b10010111_01100000_00000000_01100111;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFFFF976, "type=I; imm=4294965622; opecode=1100111;");
    inst=32'b10010111_01100000_00000000_00000011;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFFFF976, "type=I; imm=4294965622; opecode=0000011;");
    inst=32'b10010111_01100000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFFFF976, "type=I; imm=4294965622; opecode=0010011;");
    inst=32'b11000010_00111101_10100000_00110111;	@(posedge clk)#1;	assert_eq_m(imm, 32'hC23DA000, "type=U; imm=3258818560; opecode=0110111;");
    inst=32'b11000010_00111101_10100000_00010111;	@(posedge clk)#1;	assert_eq_m(imm, 32'hC23DA000, "type=U; imm=3258818560; opecode=0010111;");
    inst=32'b11101001_00110000_10010000_01101111;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFF09E92, "type=J; imm=4293959314; opecode=1101111;");
    inst=32'b01110110_00000000_00000000_11100011;	@(posedge clk)#1;	assert_eq_m(imm, 32'h00000F60, "type=B; imm=3936; opecode=1100011;");
    inst=32'b11010100_00000000_00000001_00100011;	@(posedge clk)#1;	assert_eq_m(imm, 32'hFFFFFD42, "type=S; imm=4294966594; opecode=0100011;");
    inst=32'b00100100_00100000_00000000_01100111;	@(posedge clk)#1;	assert_eq_m(imm, 32'h00000242, "type=I; imm=578; opecode=1100111;");
    inst=32'b00100100_00100000_00000000_00000011;	@(posedge clk)#1;	assert_eq_m(imm, 32'h00000242, "type=I; imm=578; opecode=0000011;");
    inst=32'b00100100_00100000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(imm, 32'h00000242, "type=I; imm=578; opecode=0010011;");

    //USE_RS1 test
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=U; opecode=0110111(LUI);");
    inst=32'b00000000_00000000_00000000_00010111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_PC, "USE_RS1_TEST; type=U; opecode=0010111(AUIPC);");
    inst=32'b00000000_00000000_00000000_01101111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_PC, "USE_RS1_TEST; type=J; opecode=1101111(JAL);");
    inst=32'b00000000_00000000_00010000_01100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=B; opecode=1100011(BRANCH);");
    inst=32'b00000000_00000000_00100000_00100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00000000_00110000_01100111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00110000_00000011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00110000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00000000_01000000_00110011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_01000000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_RS1DATA, "USE_RS1_TEST; type=R; opecode=0010011(OP-IMM);");

    //USE_RS2 test
    inst=32'b00000000_00000000_00010000_01100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS2_BIT], USE_RS2_RS2DATA, "USE_RS2_TEST; type=B; opecode=1100011(BRANCH);");
    inst=32'b00000000_00000000_00100000_00100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS2_BIT], USE_RS2_RS2DATA, "USE_RS2_TEST; type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00000000_01000000_00110011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS2_BIT], USE_RS2_RS2DATA, "USE_RS2_TEST; type=R; opecode=0110011(OP);");

    //USE_RD_SEL TEST; 
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_ALU, "USE_RD_TEST;  type=U; opecode=0110111(LUI);");
    inst=32'b00000000_00000000_00000000_00010111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_ALU, "USE_RD_TEST;  type=U; opecode=0010111(AUIPC);");
    inst=32'b00000000_00000000_00000000_01101111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_PC, "USE_RD_TEST;  type=J; opecode=1101111(JAL);");
    inst=32'b00000000_00000000_00010000_01100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_ALU, "USE_RD_TEST;  type=B; opecode=1100011(BRANCH);");
    inst=32'b00000000_00000000_00100000_00100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_ALU, "USE_RD_TEST;  type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00000000_00110000_01100111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_PC, "USE_RD_TEST;  type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00110000_00000011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_MEMORY, "USE_RD_TEST;  type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_ALU, "USE_RD_TEST;  type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00000000_01000000_00110011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_ALU, "USE_RD_TEST;  type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_ALU, "USE_RD_TEST;  type=R; opecode=0010011(OP-IMM); funct3=000;");
    inst=32'b00000000_00000000_00100000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_COMP, "USE_RD_TEST;  type=R; opecode=0010011(OP-IMM); funct3=010(slti);");
    inst=32'b00000000_00000000_00110000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RD_BIT_M:USE_RD_BIT_L], USE_RD_COMP, "USE_RD_TEST;  type=R; opecode=0010011(OP-IMM); funct3=011(sltu);");

    //FUNCT3 TEST
    inst=32'b00000000_00000000_00000000_01101111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], FUNCT3_JUMP, "FUNCT3_TEST;type=J; opecode=1101111(JAL);");
    inst=32'b00000000_00000000_00010000_01100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], 1, "FUNCT3_TEST;type=B; opecode=1100011(-);");
    inst=32'b00000000_00000000_00100000_00100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], 2, "FUNCT3_TEST;type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00000000_00010000_01100111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], FUNCT3_JUMP, "FUNCT3_TEST;type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00100000_01100111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], FUNCT3_JUMP, "FUNCT3_TEST;type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_01000000_01100111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], FUNCT3_JUMP, "FUNCT3_TEST;type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00110000_00000011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], 3, "FUNCT3_TEST;type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00110000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], 3, "FUNCT3_TEST;type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00000000_01000000_00110011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], 4, "FUNCT3_TEST;type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_01000000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[FUNCT3_BIT_M:FUNCT3_BIT_L], 4, "FUNCT3_TEST;type=R; opecode=0010011(OP-IMM);");

    //DATA_MEM_WE TEST
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=U; opecode=0110111(LUI);");
    inst=32'b00000000_00000000_00000000_00010111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=U; opecode=0010111(AUIPC);");
    inst=32'b00000000_00000000_00000000_01101111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=J; opecode=1101111(JAL);");
    inst=32'b00000000_00000000_00010000_01100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=B; opecode=1100011(-);");
    inst=32'b00000000_00000000_00100000_00100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 1, "DATA_MEM_WE_TEST; type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00000000_00110000_01100111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00110000_00000011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00110000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00000000_01000000_00110011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_01000000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[DATA_MEM_WE_BIT], 0, "DATA_MEM_WE_TEST; type=R; opecode=0010011(OP-IMM);");


    //JUMP_EN TEST
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 0, "JUMP_EN_TEST; type=U; opecode=0110111(LUI);");
    inst=32'b00000000_00000000_00000000_00010111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 0, "JUMP_EN_TEST; type=U; opecode=0010111(AUIPC);");
    inst=32'b00000000_00000000_00000000_01101111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 1, "JUMP_EN_TEST; type=J; opecode=1101111(JAL);");
    inst=32'b00000000_00000000_00010000_01100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 1, "JUMP_EN_TEST; type=B; opecode=1100011(BRANCH);");
    inst=32'b00000000_00000000_00100000_00100011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 0, "JUMP_EN_TEST; type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00000000_00110000_01100111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 1, "JUMP_EN_TEST; type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00110000_00000011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 0, "JUMP_EN_TEST; type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00110000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 0, "JUMP_EN_TEST; type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00000000_01000000_00110011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 0, "JUMP_EN_TEST; type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_01000000_00010011;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[JUMP_EN_BIT], 0, "JUMP_EN_TEST; type=R; opecode=0010011(OP-IMM);");

    //rs1sel test(zero)
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=U; opecode=0110111(LUI always zero);");
    inst=32'b00000000_00000000_00010000_01100011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=B; opecode=1100011(BRANCH);");
    inst=32'b00000000_00000000_00100000_00100011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00000000_00110000_01100111;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00110000_00000011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00110000_00010011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00000000_01000000_00110011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_01000000_00010011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=R; opecode=0010011(OP-IMM);");
    //rs1sel test(0x1F)
    inst=32'b00000000_00001111_11110000_00110111;	@(posedge clk)#1;	assert_eq_m(rs1sel, 0, "rs1_sel_test type=U; opecode=0110111(LUI always zero);");
    inst=32'b00000000_00001111_10010000_01100011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 31, "rs1_sel_test type=B; opecode=1100011(BRANCH);");
    inst=32'b00000000_00001111_10100000_00100011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 31, "rs1_sel_test type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00001111_10110000_01100111;	@(posedge clk)#1;	assert_eq_m(rs1sel, 31, "rs1_sel_test type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00001111_10110000_00000011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 31, "rs1_sel_test type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00001111_10110000_00010011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 31, "rs1_sel_test type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00001111_11000000_00110011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 31, "rs1_sel_test type=R; opecode=0110011(OP);");
    inst=32'b00000000_00001111_11000000_00010011;	@(posedge clk)#1;	assert_eq_m(rs1sel, 31, "rs1_sel_test type=R; opecode=0010011(OP-IMM);");

    //rs2_sel_test zero
    inst=32'b00000000_00001111_10010000_01100011;	@(posedge clk)#1;	assert_eq_m(rs2sel, 0, "rs2_sel_test type=B; opecode=1100011(BRANCH);");
    inst=32'b00000000_00001111_10100000_00100011;	@(posedge clk)#1;	assert_eq_m(rs2sel, 0, "rs2_sel_test type=S; opecode=0100011(STORE);");
    inst=32'b00000000_00001111_11000000_00110011;	@(posedge clk)#1;	assert_eq_m(rs2sel, 0, "rs2_sel_test type=R; opecode=0110011(OP);");
    //rs2_sel_test 0x1f
    inst=32'b00000001_11111111_10010000_01100011;	@(posedge clk)#1;	assert_eq_m(rs2sel, 31, "rs2_sel_test type=B; opecode=1100011(BRANCH);");
    inst=32'b00000001_11111111_10100000_00100011;	@(posedge clk)#1;	assert_eq_m(rs2sel, 31, "rs2_sel_test type=S; opecode=0100011(STORE);");
    inst=32'b00000001_11111111_11000000_00110011;	@(posedge clk)#1;	assert_eq_m(rs2sel, 31, "rs2_sel_test type=R; opecode=0110011(OP);");

    //funct_alu test
    inst=32'b01000000_00000000_01110000_00110011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 15, "funct_alu type=R; opecode=0110011(OP);");
    inst=32'b01000000_00000000_01110000_00010011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 15, "funct_alu type=R; opecode=0010011(OP-IMM);");
    inst=32'b00000000_00000000_01110000_00110011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 7, "funct_alu type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_01110000_00010011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 7, "funct_alu type=R; opecode=0010011(OP-IMM);");
    inst=32'b01000000_00000000_00000000_00110011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 8, "funct_alu type=R; opecode=0110011(OP);");
    inst=32'b01000000_00000000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 8, "funct_alu type=R; opecode=0010011(OP-IMM);");
    inst=32'b00000000_00000000_00000000_00110011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 0, "funct_alu type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 0, "funct_alu type=R; opecode=0010011(OP-IMM);");

    //rdsel_de test(0x1F)
    inst=32'b00000000_00000000_00001111_10110111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=U; opecode=0110111(LUI);");
    inst=32'b00000000_00000000_00001111_10010111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=U; opecode=0010111(AUIPC);");
    inst=32'b00000000_00000000_00001111_11101111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=J; opecode=1101111(JAL);");
    inst=32'b00000000_00000000_00001111_10100011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=S; opecode=0100011(STORE always zero);");
    inst=32'b00000000_00000000_00001111_11100111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00001111_10000011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00001111_10010011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=I; opecode=0010011(OP-IMM);");		
    inst=32'b00000000_00000000_00001111_10110011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_00001111_10010011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 31, "rdsel_de type=R; opecode=0010011(OP-IMM);");
    //rdsel_de test(zero)
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=U; opecode=0110111(LUI);");
    inst=32'b00000000_00000000_00000000_00010111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=U; opecode=0010111(AUIPC);");
    inst=32'b00000000_00000000_00000000_01101111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=J; opecode=1101111(JAL);");
    inst=32'b00000000_00000000_00000000_00100011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=S; opecode=0100011(STORE always zero);");
    inst=32'b00000000_00000000_00000000_01100111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=I; opecode=1100111(JALR);");
    inst=32'b00000000_00000000_00000000_00000011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=I; opecode=0000011(LOAD);");
    inst=32'b00000000_00000000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=I; opecode=0010011(OP-IMM);");
    inst=32'b00000000_00000000_00000000_00110011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=R; opecode=0110011(OP);");
    inst=32'b00000000_00000000_00000000_00010011;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de type=R; opecode=0010011(OP-IMM);");

    //rs1_data test
    rs1data_rd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(rs1data_de, rs1data_rd, "rs1_data is all zeros");
    rs1data_rd = {XLEN{1'b1}}; @(posedge clk)#1; assert_eq_m(rs1data_de, rs1data_rd, "rs1_data is all ones");
    rs1data_rd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(rs1data_de, rs1data_rd, "rs1_data is all zeros");

    //rs2_data test
    rs2data_rd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(rs2data_de, rs2data_rd, "rs2_data is all zeros");
    rs2data_rd = {XLEN{1'b1}}; @(posedge clk)#1; assert_eq_m(rs2data_de, rs2data_rd, "rs2_data is all ones");
    rs2data_rd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(rs2data_de, rs2data_rd, "rs2_data is all zeros");

    //pc test
    curr_pc_fd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(curr_pc_de, curr_pc_fd, "curr_pc is all zeros");
    curr_pc_fd = {XLEN{1'b1}}; @(posedge clk)#1; assert_eq_m(curr_pc_de, curr_pc_fd, "curr_pc is all ones");
    curr_pc_fd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(curr_pc_de, curr_pc_fd, "curr_pc is all zeros");
    next_pc_fd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(next_pc_de, next_pc_fd, "curr_pc is all zeros");
    next_pc_fd = {XLEN{1'b1}}; @(posedge clk)#1; assert_eq_m(next_pc_de, next_pc_fd, "curr_pc is all ones");
    next_pc_fd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(next_pc_de, next_pc_fd, "curr_pc is all zeros");

`ifndef OUT_FLIPFLOP_REMOVE
	//////////////////////////////////////////////////////////////
	//最終出力段がFFを通過していることを確認するテスト。
	//各種decodeのテストがpassしている状態で実施すること
	//////////////////////////////////////////////////////////////
	//imm
    inst=32'b11011101_11011001_11010000_01101111;	@(posedge clk)#1;
    inst=32'b00110000_00000000_00000000_11100011;	              #1;	assert_neq_m(imm, 32'h00000B00, "imm FF is not work.");

    //USE_RS1 test
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;
    inst=32'b00000000_00000000_00000000_00010111;	              #1;	assert_neq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_PC, "decoded_op[] FF is not work.");
    //funct_alu test
    inst=32'b01000000_00000000_01110000_00110011;	@(posedge clk)#1;
    inst=32'b00000000_00000000_00000000_00010011;	              #1;	assert_neq_m(funct_alu, 0, "funct_alu FF is not work.");

    //rdsel_de test(0x1F)
    inst=32'b00000000_00000000_00001111_10110111;	@(posedge clk)#1;
    inst=32'b00000000_00000000_00001111_10100011;	              #1;	assert_neq_m(rdsel_de, 0, "rdsel_de FF is now work.");

	//rs1_data test
    rs1data_rd = {XLEN{1'b1}}; @(posedge clk)#1;
    rs1data_rd = {XLEN{1'b0}};               #1; assert_neq_m(rs1data_de, rs1data_rd, "rs1_data FF is not work.");

    //rs2_data test
    rs2data_rd = {XLEN{1'b0}}; @(posedge clk)#1;
    rs2data_rd = {XLEN{1'b1}};               #1; assert_neq_m(rs2data_de, rs2data_rd, "rs2_data FF is not work.");

    //pc test
    next_pc_fd = {XLEN{1'b1}}; @(posedge clk)#1;
    next_pc_fd = {XLEN{1'b0}};               #1; assert_neq_m(next_pc_de, next_pc_fd, "curr_pc FF is not work.");

	//////////////////////////////////////////////////////////////
	//最終出力段がFFのenableが動作（disable状態）を確認するテスト。
	//////////////////////////////////////////////////////////////
	//imm
	phase_decode = 1'b1;
    inst=32'b00110000_00000000_00000000_11100011;	@(posedge clk)#1;
    phase_decode = 1'b0;
    inst=32'b11011101_11011001_11010000_01101111;	@(posedge clk)#1;	assert_eq_m(imm, 32'h00000B00, "imm FF Enable is not work.");

    //USE_RS1 test
	phase_decode = 1'b1;
    inst=32'b00000000_00000000_00000000_00010111;	@(posedge clk)#1;
    phase_decode = 1'b0;
    inst=32'b00000000_00000000_00000000_00110111;	@(posedge clk)#1;	assert_eq_m(decoded_op_de[USE_RS1_BIT], USE_RS1_PC, "decoded_op[] FF  Enable is not work.");
    
	//funct_alu test
	phase_decode = 1'b1;
    inst=32'b00000000_00000000_00000000_00010011;	@(posedge clk)#1;
    phase_decode = 1'b0;
    inst=32'b01000000_00000000_01110000_00110011;	@(posedge clk)#1;	assert_eq_m(funct_alu, 0, "funct_alu FF Enable is not work.");

    //rdsel_de test(0x1F)
	phase_decode = 1'b1;
    inst=32'b00000000_00000000_00001111_10100011;	@(posedge clk)#1;
    phase_decode = 1'b0;
    inst=32'b00000000_00000000_00001111_10110111;	@(posedge clk)#1;	assert_eq_m(rdsel_de, 0, "rdsel_de FF Enable is now work.");

	//rs1_data test
	phase_decode = 1'b1;
    rs1data_rd = {XLEN{1'b1}}; @(posedge clk)#1;
    phase_decode = 1'b0;
    ans = rs1data_rd;
    rs1data_rd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(rs1data_de, ans, "rs1_data FF Enable is not work.");

    //rs2_data test
	phase_decode = 1'b1;
    rs2data_rd = {XLEN{1'b1}}; @(posedge clk)#1;
    phase_decode = 1'b0;
    ans = rs2data_rd;
    rs2data_rd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(rs2data_de, ans, "rs2_data FF Enable is not work.");

    //pc test
	phase_decode = 1'b1;
    next_pc_fd = {XLEN{1'b1}}; @(posedge clk)#1;
    phase_decode = 1'b0;
    ans = next_pc_fd;
    next_pc_fd = {XLEN{1'b0}}; @(posedge clk)#1; assert_eq_m(next_pc_de, ans, "curr_pc FF Enable is not work.");
`endif

    $display("All tests pass!!");
    $finish;
end

task assert_eq_m;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    input [0:8*50-1] message;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h,%s)", a, b, message);
            #14
            $finish;
        end
    end
endtask

task assert_neq_m;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    input [0:8*50-1] message;
    begin
        if(a != b) begin
        end
        else begin
            $display("Assert NG (%h,%h,%s)", a, b, message);
            #14
            $finish;
        end
    end
endtask

endmodule // instruction_decode_tb

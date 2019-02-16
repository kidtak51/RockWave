/*
 * *****************************************************************
 * File: core_tb.v
 * Category: CORE
 * File Created: 2019/01/25 07:14
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/02/05 21:38
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/25	kidtak51	First Version
 * *****************************************************************
 */
module core_tb(
);

`include "core_general.vh"

//instruction memory
wire [AWIDTH-1:0] inst_addr;//instruction memoryのアドレスを接続する
wire [XLEN-1:0] inst_data;//instruction memoryのデータを接続する

//data memory
wire [XLEN-1:0] data_mem_out;//データメモリからのデータ出力を接続する
wire [AWIDTH-1:0] data_mem_addr;//データメモリへのアドレスを接続する
wire [XLEN-1:0] data_mem_wdata;//データメモリへのデータ入力を接続する
wire [2:0] data_mem_we;//データメモリへのWriteEnable信号を接続する
reg rst_n;
reg clk;
integer i;//forループ用


//gtk wave 波形表示用
wire [XLEN-1:0] pc = u_top_core.u_top_fetch.program_counter;
wire [XLEN-1:0] x01_ra = u_top_core.u_register_file.x1out;
wire [XLEN-1:0] x02_sp = u_top_core.u_register_file.x2out;
wire [XLEN-1:0] x03_gp = u_top_core.u_register_file.x3out;
wire [XLEN-1:0] x04_tp = u_top_core.u_register_file.x4out;
wire [XLEN-1:0] x05_t0 = u_top_core.u_register_file.x5out;
wire [XLEN-1:0] x06_t1 = u_top_core.u_register_file.x6out;
wire [XLEN-1:0] x07_t2 = u_top_core.u_register_file.x7out;
wire [XLEN-1:0] x08_s0_fp = u_top_core.u_register_file.x8out;
wire [XLEN-1:0] x09_s1 = u_top_core.u_register_file.x9out;
wire [XLEN-1:0] x10_a0 = u_top_core.u_register_file.x10out;
wire [XLEN-1:0] x11_a1 = u_top_core.u_register_file.x11out;
wire [XLEN-1:0] x12_a2 = u_top_core.u_register_file.x12out;
wire [XLEN-1:0] x13_a3 = u_top_core.u_register_file.x13out;
wire [XLEN-1:0] x14_a4 = u_top_core.u_register_file.x14out;
wire [XLEN-1:0] x15_a5 = u_top_core.u_register_file.x15out;
wire [XLEN-1:0] x16_a6 = u_top_core.u_register_file.x16out;
wire [XLEN-1:0] x17_a7 = u_top_core.u_register_file.x17out;
wire [XLEN-1:0] x18_s2 = u_top_core.u_register_file.x18out;
wire [XLEN-1:0] x19_s3 = u_top_core.u_register_file.x19out;
wire [XLEN-1:0] x20_s4 = u_top_core.u_register_file.x20out;
wire [XLEN-1:0] x21_s5 = u_top_core.u_register_file.x21out;
wire [XLEN-1:0] x22_s6 = u_top_core.u_register_file.x22out;
wire [XLEN-1:0] x23_s7 = u_top_core.u_register_file.x23out;
wire [XLEN-1:0] x24_s8 = u_top_core.u_register_file.x24out;
wire [XLEN-1:0] x25_s9 = u_top_core.u_register_file.x25out;
wire [XLEN-1:0] x26_s10 = u_top_core.u_register_file.x26out;
wire [XLEN-1:0] x27_s11 = u_top_core.u_register_file.x27out;
wire [XLEN-1:0] x28_t3 = u_top_core.u_register_file.x28out;
wire [XLEN-1:0] x29_t4 = u_top_core.u_register_file.x29out;
wire [XLEN-1:0] x30_t5 = u_top_core.u_register_file.x30out;
wire [XLEN-1:0] x31_t6 = u_top_core.u_register_file.x31out;

//clock
initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

reg[AWIDTH-1:0] memDataStartAddr = 'h800;
initial begin
    //initial
    $readmemh(`INST_ROM_FILE_NAME, u_inst_memory.mem);
    $dumpfile({`INST_ROM_FILE_NAME, ".vcd"});
    $dumpvars(0,core_tb);
    
    //Start up seeqence
    //romからramにコピーする
    rst_n = 0;

    //romやram以外の回路が動作しないようにstatemachineを停止する
    force u_top_core.u_statemachine.current = 0;
    @(posedge clk) #1;
    rst_n = 1;
    @(posedge clk) #1;
    for (i = 0; i<(2**AWIDTH); i = i + 4) begin
        force u_data_memory.addr = i;
        force u_data_memory.qin = u_inst_memory.mem[memDataStartAddr + i];
        force u_data_memory.we = 'b110;
        @(posedge clk) #1;
        force u_data_memory.we = 'h00;
    end
    release u_data_memory.addr;
    release u_data_memory.qin;
    release u_data_memory.we;
    release u_top_core.u_statemachine.current;
    rst_n = 0;

    ////Core simulation start
    @(posedge clk) #1;
    #10
    rst_n = 1;
    #50000

    //time out error
    $display("%s, %2d",{"result, ", `INST_ROM_FILE_NAME}, -1);
    $finish;
end

localparam ECALL = 32'h73;

always @(posedge clk) begin
    if(u_top_core.u_instruction_decode.inst == ECALL) begin
        $display("%s, %2d",{"result, ", `INST_ROM_FILE_NAME}, u_top_core.u_top_core.u_register_file.x3out);
        //$exit(u_top_core.u_top_core.u_register_file.x3out);
        $finish;

    end
end

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

rom u_inst_memory
(
    .clk(clk),
    .rst_n(rst_n),
    .addr(inst_addr),
    .qout(inst_data)
);

ram u_data_memory(
    .clk(clk),
    .rst_n(rst_n),
    .addr(data_mem_addr),
    .qin(data_mem_wdata),
    .we(data_mem_we),
    .qout(data_mem_out)
);

endmodule // core_tb

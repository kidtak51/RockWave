/*
 * *****************************************************************
 * File: ram_tb.v
 * Category: MemoryAccess
 * File Created: 2018/12/31 05:05
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/06 05:22
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/04	Masaru Aoki	Byte / HalfWord / Wordアクセスをテスト
 * 2018/12/31	Masaru Aoki	First Version
 * *****************************************************************
 */

module ram_tb;

`include "core_general.vh"

reg clk;
reg rst_n;
reg [2:0] we;
reg [AWIDTH-1:0] addr;
reg [DWIDTH-1:0] qin;
wire [DWIDTH-1:0] qout;
integer i;

///////////////////////////////////////////////////////////////////
// インスタンス
ram test(
    .clk(clk), .rst_n(rst_n),
    .addr(addr),
    .qin(qin),
    .we(we),
    .qout(qout)
);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Sim
initial begin
    $dumpfile("ram_tb.vcd");
    $dumpvars(0,ram_tb);
    $monitor("%t: addr=%h we=%b qin=%h qout=%h",$time,addr,we,qin,qout,test.mem[0]);

    rst_n = 0;
    addr = 0;
    we = 0;
    qin = 0;
    @(posedge clk)
    rst_n = 1;
    // 初期値確認
    for(i = 0;i<4095;i=i+1) begin
        addr = i;
        @(posedge clk)
        assert_eq(qout,0,"init");
    end

    // Word Write & Read
    $display("Word Write & Read");
    for(i = 0;i<=4095;i=i+4) begin
        addr = i;
        qin = ((i&32'h00FF)<<24)+((i&32'h00FF)<<16)+((i&32'h00FF)<<8)+(i&32'h00FF);
        we = 3'b110; // Wordアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 3'b000;
        @(posedge clk);
    end
    for(i = 0;i<=4095;i=i+4) begin
        addr = i;
        @(posedge clk)
        assert_eq(qout,((i&32'h00FF)<<24)+((i&32'h00FF)<<16)+((i&32'h00FF)<<8)+(i&32'h00FF),"Word Write&Read");
    end

    // HalfWord Write & Read
    $display("HalfWord Write & Read");
    for(i = 0;i<4095;i=i+2) begin
        addr = i;
        qin = i;
        we = 3'b101; // HalfWordアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 3'b000;
        @(posedge clk);
    end
    for(i = 0;i<4095;i=i+2) begin
        addr = i;
        @(posedge clk)
        assert_eq(qout&32'h00FF,i&32'h00FF,"HalfWord Write&Read");
    end

    // Byte Write & Read
    $display("Byte Write & Read");
    for(i = 0;i<4096;i=i+1) begin
        addr = i;
        qin = i;
        we = 3'b100; // Byteアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 3'b000;
        @(posedge clk);
    end
    for(i = 0;i<4096;i=i+1) begin
        addr = i;
        @(posedge clk)
        assert_eq(qout&32'h000F,i&32'h000F,"Byte Write&Read");
    end

    $finish;
end

task assert_eq;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    input [32:0][7:0] msg;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h):%s",a,b,msg);
            $finish;
        end
    end
endtask


endmodule
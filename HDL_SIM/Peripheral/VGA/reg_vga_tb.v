/*
 * *****************************************************************
 * File: reg_vga_tb.v
 * Category: VGA
 * File Created: 2019/03/17 06:11
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/18 05:26
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   TestBench for reg_vga
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/17	Masaru Aoki	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

`define STEP 10

module reg_vga_tb;
    `include "core_general.vh"

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    // Local BUS
    reg                 sel;        // Select this Memory Block
    reg   [XLEN-1:0]    addr;       // Address
    reg   [2:0]         we;         // Write Enable
    reg   [XLEN-1:0]    wdata;      // Write Data
    wire  [XLEN-1:0]    rdata;      // Read Data

    // reg
    wire            vga_en;         // Module Enable
    reg             hblank;         // 水平帰線区間    
    reg             vblank;         // 垂直帰線区間

    reg  [XLEN-1:0]    data;      // Read Data

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    reg_vga U_reg_vga(.*);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP/2) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("reg_vga_tb.vcd");
    $dumpvars(0,reg_vga_tb);

    rst_n=0;
    addr = 32'h0000_0000;
    we = 3'b000;
    wdata = 32'h0000_0000;
    vblank = 0;
    hblank = 0;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    @(posedge clk)

    //////////////////////////////////////
    cpu_wr(32'h6000_0000,8'h01);
    @(posedge clk)
    cpu_rd(32'h6000_0000,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0001);
    assert_eq(vga_en,1);

    //////////////////////////////////////
    // vblank / hblank 
    vblank = 0;
    hblank = 0;
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0000);
    addr = 32'h0000_0000;

    vblank = 1;
    hblank = 1;
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0003);
    addr = 32'h0000_0000;

    vblank = 0;
    hblank = 1;
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0002);
    addr = 32'h0000_0000;

    vblank = 1;
    hblank = 0;
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0001);
    addr = 32'h0000_0000;



    #(`STEP*2)

    $display("All tests pass!!");
    $finish;
end

task assert_eq;
    input [15:0] a;
    input [15:0] b;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h)",a,b);
            #(`STEP*10)
            $stop;
        end
    end
endtask

task cpu_wr;
    input [31:0] address;
    input [31:0] data;
    begin
        sel = 1'b1;
        addr = address;
        wdata = data;
        we = 3'b110;
        @(posedge clk);
    end
endtask

task cpu_rd;
    input [31:0] address;
    output [31:0] data;
    begin
        sel = 1'b1;
        addr = address;
        @(posedge clk);
        data = rdata;
    end
endtask



endmodule

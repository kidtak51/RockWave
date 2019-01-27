/*
 * *****************************************************************
 * File: register_tb.v
 * Category: Common
 * File Created: 2019/01/26 17:16
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/28 06:10
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Register Block用テストベンチ
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/26	Masaru Aoki	First Version
 * *****************************************************************
 */

`define STEP 10
`timescale 1ns/1ns

module register_tb;
    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // reg_rw
    reg [5:0] wdata_rw;             // wdata   for reg_rw
    reg we_rw;                      // we      for reg_rw
    reg re_rw;                      // re      for reg_rw
    wire [5:0] rdata_rw;            // rdata   for reg_rw
    wire [5:0] dataout_rw;          // dataout for reg_rw

    // reg_ronly
    reg [7:0] datain_ronly;         // datain for reg_ronly
    reg re_ronly;                   // re     for reg_ronly
    wire [7:0] rdata_ronly;         // rdata  for ronly

    // Phase_controler
    reg phase_fetch;
    reg phase_decode;
    reg phase_execute;
    reg phase_memoryaccess;        // Fetch Phase
    reg phase_writeback;           // WriteBack Phase

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    reg_rw #(.BW(6)) U_reg_rw(
        .clk(clk),
        .rst_n(rst_n),
        .wdata(wdata_rw),
        .we(we_rw),
        .re(re_rw),
        .rdata(rdata_rw),
        .dataout(dataout_rw)
    );

    reg_ronly #(.BW(8)) U_reg_ronly(
        .clk(clk),
        .rst_n(rst_n),
        .datain(datain_ronly),
        .re(re_ronly),
        .rdata(rdata_ronly)
    );
    
    ///////////////////////////////////////////////////////////////////
    // Clock
    initial
        clk = 0;
    always begin
        #(`STEP/2) clk = ~clk;
    end

    ///////////////////////////////////////////////////////////////////
    // State Machine
    initial begin
        phase_fetch = 0;
        phase_decode = 0;
        phase_execute = 0;
        phase_memoryaccess = 0;
        phase_writeback = 0;
        @(posedge rst_n)
        phase_fetch <= 1;
    end
    always begin
        @(posedge clk)
        phase_fetch <= phase_writeback;
        phase_decode <= phase_fetch;
        phase_execute <= phase_decode;
        phase_memoryaccess  <= phase_execute;
        phase_writeback <= phase_memoryaccess;
    end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("register_tb.vcd");
    $dumpvars(0,register_tb);

    rst_n=0;
    // RW init
    wdata_rw = 6'b00_0000;
    we_rw = 1'b0;
    re_rw = 1'b0;
    // ReadOnly init
    datain_ronly = 8'h00;
    re_ronly = 1'b0;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    // リセット解除直後は 0
    assert_eq(rdata_rw      , 6'b00_0000, `__LINE__);
    assert_eq(dataout_rw    , 6'b00_0000, `__LINE__);
    assert_eq(rdata_ronly   , 8'h00     , `__LINE__);

    //////////////////////////////////////////////
    // reg_rw
    //    rdata は、phase_memoryaccessの時のみ出力
    //    dataoutは、常に出力
    // Write
    wdata_rw = 6'b11_1111;
    @(posedge phase_memoryaccess)
    we_rw = 1'b1;
    @(negedge phase_memoryaccess)
    we_rw = 1'b0;
    @(posedge phase_writeback) #(1)
    assert_eq(rdata_rw    , 6'b00_0000, `__LINE__);
    assert_eq(dataout_rw  , 6'b11_1111, `__LINE__);
    // Read
    @(posedge phase_memoryaccess)
    re_rw = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_rw    , 6'b11_1111, `__LINE__);
    assert_eq(dataout_rw  , 6'b11_1111, `__LINE__);
    re_rw = 1'b0;

    wdata_rw = 6'b10_1010;
    @(posedge phase_memoryaccess)
    we_rw = 1'b1;
    @(negedge phase_memoryaccess)
    we_rw = 1'b0;
    @(posedge phase_writeback) #(1)
    assert_eq(rdata_rw    , 6'b00_0000, `__LINE__);
    assert_eq(dataout_rw  , 6'b10_1010, `__LINE__);
    // Read
    @(posedge phase_memoryaccess)
    re_rw = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_rw    , 6'b10_1010, `__LINE__);
    assert_eq(dataout_rw  , 6'b10_1010, `__LINE__);
    re_rw = 1'b0;

    wdata_rw = 6'b01_0101;
    @(posedge phase_memoryaccess)
    we_rw = 1'b1;
    @(negedge phase_memoryaccess)
    we_rw = 1'b0;
    @(posedge phase_writeback) #(1)
    assert_eq(rdata_rw    , 6'b00_0000, `__LINE__);
    assert_eq(dataout_rw  , 6'b01_0101, `__LINE__);
    // Read
    @(posedge phase_memoryaccess)
    re_rw = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_rw    , 6'b01_0101, `__LINE__);
    assert_eq(dataout_rw  , 6'b01_0101, `__LINE__);
    re_rw = 1'b0;

    wdata_rw = 6'b00_0000;
    @(posedge phase_memoryaccess)
    we_rw = 1'b1;
    @(negedge phase_memoryaccess)
    we_rw = 1'b0;
    @(posedge phase_writeback) #(1)
    assert_eq(rdata_rw    , 6'b00_0000, `__LINE__);
    assert_eq(dataout_rw  , 6'b00_0000, `__LINE__);
    // Read
    @(posedge phase_memoryaccess)
    re_rw = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_rw    , 6'b00_0000, `__LINE__);
    assert_eq(dataout_rw  , 6'b00_0000, `__LINE__);
    re_rw = 1'b0;

    //////////////////////////////////////////////
    // reg_ronly
    //    rdata は、phase_memoryaccessの時のみ出力
    datain_ronly = 6'b11_1111;
    @(posedge phase_memoryaccess)
    re_ronly = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_ronly    , 6'b11_1111, `__LINE__);
    re_ronly = 1'b0;

    datain_ronly = 6'b10_1010;
    @(posedge phase_memoryaccess)
    re_ronly = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_ronly    , 6'b10_1010, `__LINE__);
    re_ronly = 1'b0;

    datain_ronly = 6'b01_0101;
    @(posedge phase_memoryaccess)
    re_ronly = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_ronly    , 6'b01_0101, `__LINE__);
    re_ronly = 1'b0;

    datain_ronly = 6'b00_0000;
    @(posedge phase_memoryaccess)
    re_ronly = 1'b1;
    @(negedge phase_memoryaccess)
    assert_eq(rdata_ronly    , 6'b00_0000, `__LINE__);
    re_ronly = 1'b0;

    #(`STEP*10)
    $display("All test is Green.");
    $finish;
end


task assert_eq;
    input  [15:0] a;
    input  [15:0] b;
    input integer line;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h) at %3d",a,b,line);
            #(10);
            $finish;
        end
    end
endtask

endmodule
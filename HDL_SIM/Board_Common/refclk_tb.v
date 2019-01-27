/*
 * *****************************************************************
 * File: refclk_tb.v
 * Category: Common
 * File Created: 2019/01/14 08:26
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/28 08:25
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   RefClk テストベンチ
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/14	Masaru Aoki	First Version
 * *****************************************************************
 */

`define STEP 5

module refclk_tb;
    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // From StateMachine
    reg phase_fetch;
    reg phase_decode;
    reg phase_execute;
    reg phase_memoryaccess;        // Fetch Phase
    reg phase_writeback;           // WriteBack Phase

    wire refclk2;
    wire refclk16;

    integer clkcount;
    integer clkcount2;
    integer clkcount16;

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    refclk #(.BW(2)) 
    U_refclk2 (
    .clk(clk), .rst_n(rst_n),
    .ref_st(2'h1),
    .refclk(refclk2)
    );
    refclk #(.BW(8)) 
    U_refclk16 (
    .clk(clk), .rst_n(rst_n),
    .ref_st(8'd15),
    .refclk(refclk16)
    );

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// クロック数をカウント
initial begin
    @(posedge rst_n);
    clkcount = 0;
    clkcount2 = 0;
    clkcount16 = 0;
end
always begin
    @(posedge clk);
    clkcount = clkcount + 1;
end
always begin
    @(posedge refclk2);
    clkcount2 = clkcount2 + 1;
end
always begin
    @(posedge refclk16);
    clkcount16 = clkcount16 + 1;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("refclk.vcd");
    $dumpvars(0,refclk_tb);

    rst_n=0;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    // フリーランで動かして
    #(`STEP*100)

    // 所定の分周比になっていること
    @(negedge refclk2)
    #(1)
    if(clkcount == (clkcount2*2)) begin
    end
    else begin
        $display("Assert NG (refclk2)");
        #(10);
        $finish;
    end

    @(negedge refclk16)
    #(1)
    if(clkcount == (clkcount16*16)) begin
    end
    else begin
        $display("Assert NG (refclk16)");
        #(10);
        $finish;
    end

    $display("All test is Green.");
    $finish;
end

endmodule

/*
 * *****************************************************************
 * File: dfilter_tb.v
 * Category: Common
 * File Created: 2019/01/14 08:26
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/31 05:05
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Digital Filter テストベンチ
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/14	Masaru Aoki	First Version
 * *****************************************************************
 */

`define STEP 10

module dfilter_tb;
    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // From StateMachine
    reg phase_fetch;
    reg phase_decode;
    reg phase_execute;
    reg phase_memoryaccess;        // Fetch Phase
    reg phase_writeback;           // WriteBack Phase

    reg data_in;
    reg pol;
    reg [7:0] flt_rise_st;
    reg [7:0] flt_fall_st;

    wire data_out;
    wire act_edge;
    wire inact_edge;

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    refclk #(.BW(3) )
    U_refclk3 (
    .clk(clk), .rst_n(rst_n),
    .ref_st(3'h2),
    .refclk(refclk)
    );

    dfilter #(.INIVAL(1'b0), .BW(8))
    U_dfilter (
        .clk(clk), .rst_n(rst_n),
        .data_in(data_in),
        .pol(pol),
        .refclk(refclk),
        .flt_rise_st(flt_rise_st),
        .flt_fall_st(flt_fall_st),
        .data_out(data_out),
        .act_edge(act_edge),
        .inact_edge(inact_edge)
    );

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
    $dumpfile("dfilter.vcd");
    $dumpvars(0,dfilter_tb);

    rst_n=0;

    data_in = 1'b0;
    pol     = 1'b1; // High active
    flt_rise_st = 8'h8;
    flt_fall_st = 8'h8;

    @(posedge clk)
    // 初期値が正しいこと
    assert_eq(data_out,0,"Init val");

    @(posedge clk)
    rst_n = 1;

    // 3*(8+1) clk以下はフィルタされる
    @(posedge clk)
    data_in = 1'b1;
    #(`STEP*5);
    data_in = 1'b0;
    @(posedge clk);
    assert_eq(data_out,0,"widht:5clk");

    #(`STEP*10)
    // 25 clkは通る (refclk(3) x N(8) +1 )
    // Active Edge
    @(posedge refclk)
    data_in = 1'b1;
    #(`STEP*25);
    #(1);
    assert_eq(data_out,1,"width:25clk");
    assert_eq(act_edge,1,"Active Edge");
    assert_eq(inact_edge,0,"InActive Edge");
    #(`STEP);
    data_in = 1'b0;

    #(`STEP*2);
    data_in = 1'b1;
    #(`STEP*10)
    // 25 clkは通る (refclk(3) x  N(8) +1 )
    // Inactive Edge
    @(posedge refclk)
    data_in = 1'b0;
    #(`STEP*25);
    #(1);
    assert_eq(data_out,0,"width:25clk");
    assert_eq(act_edge,0,"Active Edge");
    assert_eq(inact_edge,1,"InActive Edge");
    #(`STEP);
    data_in = 1'b1;

    #(`STEP*10);

    $display("All test is Green.");
    $finish;
end

task assert_eq;
    input a;
    input b;
    input [32:0][7:0] msg;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h):%s",a,b,msg);
            #(`STEP);
            $finish;
        end
    end
endtask


endmodule

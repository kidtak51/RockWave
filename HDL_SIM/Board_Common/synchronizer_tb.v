/*
 * *****************************************************************
 * File: synchronizer_tb.v
 * Category: Common
 * File Created: 2019/01/14 08:26
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/14 09:13
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   synchronizerテストベンチ
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/14	Masaru Aoki	First Version
 * *****************************************************************
 */

module syncronizer_tb;
    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // From StateMachine
    reg phase_fetch;
    reg phase_decode;
    reg phase_execute;
    reg phase_memoryaccess;        // Fetch Phase
    reg phase_writeback;           // WriteBack Phase

    reg async_in;
    wire sync_out;

    reg [15:0] async_in16;
    wire [15:0] sync_out16;

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    syncronizer #(.WIDTH(1), .INIVAL(0)) 
    U_sync (
    .clk(clk), .rst_n(rst_n),
    .async_in(async_in),
    .sync_out(sync_out)
    );
    syncronizer #(.WIDTH(16), .INIVAL(16'hFFFF))
     U_sync16 (
    .clk(clk), .rst_n(rst_n),
    .async_in(async_in16),
    .sync_out(sync_out16)
    );

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("syncronizer.vcd");
    $dumpvars(0,syncronizer_tb);

    rst_n=0;
    async_in = 1'b0;
    async_in16 = 16'h0000;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    // リセット解除直後はINIVAL
    assert_eq(sync_out  , 1'b0);
    assert_eq(sync_out16,16'hFFFF);

    // 2clk後に入力値
    @(posedge clk)
    @(posedge clk)
    assert_eq(sync_out  , 1'b0);
    assert_eq(sync_out16,16'h0000);

    // 入力値を変更したら2clk後に出力される
    async_in = 1'b1;
    async_in16 = 16'h5555;
    assert_eq(sync_out  , 1'b0);
    assert_eq(sync_out16,16'h0000);
    @(posedge clk)
    @(posedge clk)
    assert_eq(sync_out  , 1'b1);
    assert_eq(sync_out16,16'h5555);

    $display("All test is Green.");
    $finish;
end

task assert_eq;
    input  [15:0] a;
    input  [15:0] b;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h)",a,b);
            #(10);
            $finish;
        end
    end
endtask

endmodule
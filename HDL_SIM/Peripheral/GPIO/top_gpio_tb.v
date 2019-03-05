/*
 * *****************************************************************
 * File: top_gpio_tb.v
 * Category: GPIO
 * File Created: 2019/03/03 11:54
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/03/03 15:41
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   TestBench for fnc_gpio
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/03	Masaru Aoki	First Version
 * *****************************************************************
 */

`define STEP 10

module top_gpio_tb;

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    reg  [15:0] gpio_pin_in;   // GPIO 端子 (入力)
    wire [ 7:0] gpio_pin_out;  // GPIO 端子 (出力)

    reg           sel;        // Select this Memory Block
    reg [11:0]    addr;       // Address
    reg [2:0]     we;         // Write Enable
    reg [31:0]    wdata;      // Write Data
    wire [31:0]   rdata;      // Read Data

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    top_gpio U_top_gpio(.*);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP/5) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("top_gpio.vcd");
    $dumpvars(0,top_gpio_tb);

    rst_n=0;
    gpio_pin_in = 0;
    sel = 0;
    addr = 0;
    we = 0;
    wdata = 0;


    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    //////////////////////////////////////////////////////////////////
    // レジスタ初期値確認
    addr = 12'h000;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h004;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h010;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h020;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    //////////////////////////////////////////////////////////////////
    // Write -> Read
    // Addr 000 Half word Access
    addr = 12'h000;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h000000AA);

    addr = 12'h000;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h000000FF);

    addr = 12'h000;    sel = 1;
    wdata = 32'h00000000;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h000;    sel = 1;
    wdata = 32'h55555555;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h00000055);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    // Addr 004
    addr = 12'h004;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h000000AA);

    addr = 12'h004;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h000000FF);

    addr = 12'h004;    sel = 1;
    wdata = 32'h00000000;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h004;    sel = 1;
    wdata = 32'h55555555;
    we = 3'b1_01;
    #(`STEP)
    we = 3'b0_01;
    #(`STEP)
    assert_eq(rdata,32'h00000055);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    // GPIO out
    // Addr 020 Word Write
    addr = 12'h020;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    assert_eq(rdata,32'h000000AA);

    addr = 12'h020;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    assert_eq(rdata,32'h000000FF);

    addr = 12'h020;    sel = 1;
    wdata = 32'h00000000;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h020;    sel = 1;
    wdata = 32'h55555555;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    assert_eq(rdata,32'h00000055);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    //////////////////////////////////////////////////////////////////
    // Read
    // Addr 010 
    rst_n = 0;          // refclkを初期化
    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    // Dfilter = 0
    addr = 12'h000;    sel = 1;
    wdata = 32'h00000000;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    assert_eq(rdata,32'h00000000);
    // refclk
    addr = 12'h004;    sel = 1;
    wdata = 32'h00000000;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    gpio_pin_in = 16'hFFFF;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 12'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h0000FFFF);

    gpio_pin_in = 16'h5555;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 12'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00005555);

    gpio_pin_in = 16'hAAAA;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 12'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h0000AAAA);

    gpio_pin_in = 16'h0000;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 12'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);


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

endmodule

/*
 * *****************************************************************
 * File: reg_rw.v
 * Category: Common
 * File Created: 2019/01/26 16:45
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/27 07:35
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Read / Write Register
 *       CORE -> Peripheral
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/26	Masaru Aoki	First Version
 * *****************************************************************
 */

module reg_rw(
    input clk,                  // Global Clock
    input rst_n,                // Global Reset
    input [BW-1:0] wdata,       // Write Data
    input            we,        // Write Enable
    input            re,        // Read  Enable

    output [BW-1:0] rdata,      // Read Data for BUS
    output [BW-1:0] dataout     // Data out for Peripheral
);

    parameter BW = 1;            // BitWidth

    reg [BW-1:0] register;      // Register Block

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            register <= {BW{1'b0}};
        else if(we)
            register <= wdata;
        else
            register <= register;
    end

    assign rdata = (re ? register : {BW{1'b0}});
    assign dataout = register;

endmodule   // reg_rw
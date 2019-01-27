/*
 * *****************************************************************
 * File: reg_ronly.v
 * Category: Common
 * File Created: 2019/01/26 16:45
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/01/27 07:27
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Read only Register
 *       Peripheral -> CORE
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/26	Masaru Aoki	First Version
 * *****************************************************************
 */

module reg_ronly(
    input clk,                  // Global Clock
    input rst_n,                // Global Reset
    input [BW-1:0] datain,      // Write Data
    input            re,        // Read  Enable

    output [BW-1:0] rdata       // Read Data for BUS
);

    parameter BW = 1;            // BitWidth

    reg [BW-1:0] register;      // Register Block

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            register <= {BW{1'b0}};
        else if(re)
            register <= register;
        else
            register <= datain;
    end

    assign rdata = (re ? register : {BW{1'b0}});

endmodule   // reg_ronly
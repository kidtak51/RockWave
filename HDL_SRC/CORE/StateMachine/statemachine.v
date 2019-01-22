/*
 * *****************************************************************
 * File: statemachine.v
 * Category: StateMachine
 * File Created: 2019/01/20 21:35
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/22 12:27
 * Modified By: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/01/20	Takuya Shono	First Version
 * *****************************************************************
 */

module statemachine(

    input rst_n,
    input clk,  
  
    // For StateMachine
    input stall_fetch,              // 状態fetchをkeepする
    input stall_decode,             // 状態decodeをkeepする
    input stall_execute,            // 状態executeをkeepする
    input stall_memoryaccess,       // 状態memoryaccessをkeepする
    input stall_writeback,          // 状態writebackをkeepする
    // For state instruction
    output phase_fetch,             //状態をFETCHにする
    output phase_decode,            //状態をDECODEにする
    output phase_execute,           //状態をEXECUTEにする
    output phase_memoryaccess,      //状態をMEMORYACCESSにする
    output phase_writeback          //状態をWRITEBACKにする
    );
  
    reg  [4:0] current;         //現在の状態

    localparam INITIAL          = 5'b00000;
    localparam FETCH            = 5'b00001;
    localparam DECODE           = 5'b00010;
    localparam EXECUTE          = 5'b00100;
    localparam MEMORYACCESS     = 5'b01000;
    localparam WRITEBACK        = 5'b10000;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current <= INITIAL;
        else
            case( current ) //ステートの移動
                INITIAL: current <= FETCH;

                FETCH: if(stall_fetch)
                            current <= current;
                       else
                            current <= DECODE;
                DECODE: if(stall_decode)
                            current <= current;
                       else
                            current <= EXECUTE;
                EXECUTE: if(stall_execute)
                            current <= current;
                       else
                            current <= MEMORYACCESS;
                MEMORYACCESS: if(stall_memoryaccess)
                            current <= current;
                       else
                            current <= WRITEBACK;
                WRITEBACK: if(stall_writeback)
                            current <= current;
                       else
                            current <= FETCH;
                default: current <= INITIAL;
            endcase
    end

    assign  phase_fetch         = current[0]; 
    assign  phase_decode        = current[1];
    assign  phase_execute       = current[2];
    assign  phase_memoryaccess  = current[3];
    assign  phase_writeback     = current[4];

endmodule //statemachine



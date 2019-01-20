/*
 * *****************************************************************
 * File: statemachine.v
 * Category: StateMachine
 * File Created: 2019/01/20 21:35
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2019/01/20 23:30
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
  
    reg  [4:0] current; //現在の状態
    reg  [4:0] next;    //次の状態

//ワンホット方式
    localparam FETCH            = 5'b00001;
    localparam DECODE           = 5'b00010;
    localparam EXECUTE          = 5'b00100;
    localparam MEMORYACCESS     = 5'b01000;
    localparam WRITEBACK        = 5'b10000;

    always @(negedge rst_n) begin
        if(!rst_n)
            current <= 5'bxxxxx;
        else
            current <= FETCH;
        end

    always @( current ) begin
        case(current) //ステートの移動
            FETCH: if(stall_fetch)
                        next <= FETCH;
                   else
                        next <= DECODE;
            DECODE: if(stall_decode)
                        next <= DECODE;
                   else
                        next <= EXECUTE;
            EXECUTE: if(stall_execute)
                        next <= EXECUTE;
                   else
                        next <= MEMORYACCESS;
            MEMORYACCESS: if(stall_memoryaccess)
                        next <= MEMORYACCESS;
                   else
                        next <= WRITEBACK;
            WRITEBACK: if(stall_writeback)
                        next <= WRITEBACK;
                   else
                        next <= FETCH;
            default: next <= 5'bxxxxx;
        endcase
    end

    assign  phase_fetch         = next[0]; 
    assign  phase_decode        = next[1];
    assign  phase_execute       = next[2];
    assign  phase_memoryaccess  = next[3];
    assign  phase_writeback     = next[4];

endmodule //statemachine



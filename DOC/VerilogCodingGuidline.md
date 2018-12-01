これは、[VerilogCodingGuidline](https://github.com/NetFPGA/netfpga/wiki/VerilogCodingGuidelines "VerilogCodingGuidline")を和訳し、内容をProject RockWave向きに変更したものです。

# 名前
## module & instance名
1. 最上位階層は、top_xxxxとする  
今回は、`top_rockwave`
2. モジュールをインスタンスする場合には、インスタンス名をU_モジュール名とする
`sramif`の場合、`U_sramif`とする
* モジュール名が機能を示す場合、そのままにする  
`fifo_sram_output U_fifo_sram_output ()`
* 機能名を示す添字をモジュール名に続ける  
`reg U_reg_program_counter()`
## 信号名
* 最上位階層の信号名なすべて大文字とする
* 中間階層の信号名は全て小文字の英数字と_のみとする
* ActiveLow信号は、信号名に'_n'を追加する
## 定数名
全て大文字とする
# インデント
空白4文字を基本とする。  
エディタの設定で、TAB文字を空白に変換すること。
* begin/endステートメントのインデントは以下のようにする

        if (this) begin
            do something;
        end
        else begin
            do something else;
        end
# コメント
* コメントを書きましょう。もし半年後にコードを見たとき、それはあなたが書いたコードだとは思えないでしょう
* もし複数行のコメントを書くときは、`/*…*/`コメントを使用しましょう。 全ての行の先頭に`//`を書くよりは、編集がしやすくなります。
* 全てのソースコードの先頭に以下のようなヘッダーを記載してください


        /*
        * *****************************************************************
         * File: reg_rw_tb.v
         * Category: RegisterFile
         * File Created: 2018/11/25 06:43
         * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
         * *****
        * Last Modified: 2018/11/27 05:16
        * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
        * *****
        * Copyright 2018 - 2018  Project RockWave
        * *****************************************************************
         * Description:
         *    R/W レジスタ　テストベンチ
         *  *****************************************************************
         * HISTORY:
         * Date      	By    	    Comments
         * ----------	----------      ----------------------------------------
         * 2018/11/25	Masaru Aoki	First Version
         * *****************************************************************
        */

VS Code&psi-headerの場合、F1→header insertで入力することができます
# モジュール定義とインスタンス
* 全てのモジュールは、個別のファイルに記述します
* ポート定義はVerilog 2001 ANSI-C記述に従ってください

        output reg signal_C, 
        input clk
        );
* 入出力定義は、1信号1行としてください  
これは信号のドライブ元を検索する際にgrepしやすくなります またコメントを入力するスペースもできます
* 機能的に同じ信号はグループにしてください  
雑多な信号は信号定義の最後とすること これは、'clk' 'rst_n'や複数のモジュールに接続される高fanoutの信号を含みます
* 位置引数を使用してモジュールをインスタンス化しないでください。 常にドット形式を使用してください：
 
        my_module my_module（
         .signal（signal）,
         .a_bus（a_bus）,
         ...
        ）;
* パラメータをオーバライドするときは明示的な指定して下さい
 
        my_module my_module  '''#(.WIDTH(32))''' (
             ...
        );
# クロック
モジュールのコアクロック信号は `clk`です。
それ以外のクロックには、クロックと埋め込み周波数の記述が含まれている必要があります。これにより、合成が通りやすくなります。例： `clk_ddr_400`  
可能であれば、モジュールごとに1つのクロックとしてください。（理解しやすく、合成もはるかに高速です。）

## 同期/クロックドメイン
同期が必要な信号（非同期のクロック境界を越えている）がある場合は、 synch_\<something>とします  
例: `reg synch_stage_1,synch_stage_2;`  
これらにはシミュレーションのための特別な処理が与えられ、自動チェックを適用してすべて信号が同期していることを確認できます。  
必然性： 他のフロップ名では「synch」を使用しないでください。  
同期/ドメイン交差コードと一般ロジックを混在させないでください。大規模なモジュール内のコードを他のロジックで明確に描き、別のモジュールに配置します。
ステートメント " input "と " output "は、引数をワイヤーにデフォルト設定します。したがって、入力または出力のコードにワイヤステートメントを入れる必要はありません。

# リセット
リセット信号は：
* 信号名「rst_n」
* active low信号
* 同期

# 代入文
* 順序回路は、非ブロッキング代入（<=）のみを持たなければならない
* 組み合わせ回路はブロック割り当てのみを持つべきです（=）
* コードブロック内にブロックと非ブロックの割り当てを混在させないでください。

# パラメータ、定義、定数
必要に応じて、可読性が低下しないようにモジュールをパラメータ化します。
階層を介してパラメータを伝播します。

        #(parameter ADDR_WIDTH = 10,
           parameter DATA_WIDTH = 32)
         ( input [DATA_WIDTH-1:0] data,
           input [ADDR_WIDTH-1:0] addr,
           ...
         );
         ...
        /* instance using the same parameters */
         b_module b_module_0
         #(.ADDR_WIDTH(ADDR_WIDTH),
           .DATA_WIDTH(DATA_WIDTH))
         ( .data(data)...);
* すべてのグローバル\`defineをプロジェクトに含まれる外部定義ファイルに置きます。 
* 個々のモジュールで`define文を宣言しないでください 。
* モジュールの外から再定義してはならない定数には、localparamを使用します。  
たとえば、状態マシンの状態：

        localparam IDLE    = 3'd0; // Oven idle
        localparam RAMP_UP = 3'd1; // Oven temperature ramping up
        localparam HOLD    = 3'd2; // Hold oven at bake temperature
         ...
/*
 * *****************************************************************
 * File: top_zynqberry.v
 * Category: Zynqberry
 * File Created: 2019/10/07 21:53
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/10/08 21:25
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/10/07	kidtak51	First Version
 * *****************************************************************
 */

module top_zynqberry(
    inout [14:0] DDR_addr,//DDR
    inout [2:0] DDR_ba,//DDR
    inout DDR_cas_n,//DDR
    inout DDR_ck_n,//DDR
    inout DDR_ck_p,//DDR
    inout DDR_cke,//DDR
    inout DDR_cs_n,//DDR
    inout [1:0] DDR_dm,//DDR
    inout [15:0] DDR_dq,//DDR
    inout [1:0] DDR_dqs_n,//DDR
    inout [1:0] DDR_dqs_p,//DDR
    inout DDR_odt,//DDR
    inout DDR_ras_n,//DDR
    inout DDR_reset_n,//DDR
    inout DDR_we_n,//DDR
    inout FIXED_IO_ddr_vrn,//FIXED_IO
    inout FIXED_IO_ddr_vrp,//FIXED_IO
    inout [31:0] FIXED_IO_mio,//FIXED_IO
    inout FIXED_IO_ps_clk,//FIXED_IO
    inout FIXED_IO_ps_porb,//FIXED_IO
    inout FIXED_IO_ps_srstb,//FIXED_IO
    inout [23:0] GPIO_1_tri_io,//FIXED_IO
    output PWM_L,//FIXED_IO
    output PWM_R,//DFIXED_IO
    input Vp_Vn_v_n,//?
    input Vp_Vn_v_p,//?
    input csi_c_clk_n,//CSI
    input csi_c_clk_p,//CSI
    input csi_d_lp_n,//CSI
    input csi_d_lp_p,//CSI
    input [1:0] csi_d_n,//CSI
    input [1:0] csi_d_p,//CSI
    //output hdmi_clk_n,//HDMI
    //output hdmi_clk_p,//HDMI
    //output[2:0] hdmi_data_n,//HDMI
    //output[2:0] hdmi_data_p,//HDMI
    output led,//LED (GPIO出力 外付けLED）
    input clk_from_gpio_cn//clock(GPIO入力 外付け水晶による16MHz)
);

wire clk_pix;//hdmi pix_clk
wire clk_pix_x5;
wire locked;
clk_wiz_0 u_clk_wiz_0(
  .clk_out1(clk_pix),//hdmi pix_clk
  .clk_out2(clk_pix_x5),//hdmi pix_clk_x5
  .reset(1'b0),
  .locked(locked),//未使用
  .clk_in1(clk_from_gpio_cn)//16MHz
 );


led_test u_led_test(
      .clk(clk_pix),
	  .rst_n(1'b1),
      .led_out(led)
    );


//未使用GPIOの状態設定
//外付けの回路とショートを避けるためにhigh-zに固定
assign GPIO_1_tri_io[0] = 1'bz;
assign GPIO_1_tri_io[1] = 1'bz;
assign GPIO_1_tri_io[2] = 1'bz;
assign GPIO_1_tri_io[3] = 1'bz;
assign GPIO_1_tri_io[4] = 1'bz;
assign GPIO_1_tri_io[5] = 1'bz;
assign GPIO_1_tri_io[6] = 1'bz;
assign GPIO_1_tri_io[7] = 1'bz;
assign GPIO_1_tri_io[8] = 1'bz;
assign GPIO_1_tri_io[9] = 1'bz;
assign GPIO_1_tri_io[10] = 1'bz;
assign GPIO_1_tri_io[11] = 1'bz;
assign GPIO_1_tri_io[12] = 1'bz;
assign GPIO_1_tri_io[13] = 1'bz;
assign GPIO_1_tri_io[14] = 1'bz;
assign GPIO_1_tri_io[15] = 1'bz;//
assign GPIO_1_tri_io[16] = 1'bz;
assign GPIO_1_tri_io[17] = 1'bz;
assign GPIO_1_tri_io[18] = 1'bz;
assign GPIO_1_tri_io[19] = 1'bz;
assign GPIO_1_tri_io[20] = 1'bz;
assign GPIO_1_tri_io[21] = 1'bz;
assign GPIO_1_tri_io[22] = 1'bz;
assign GPIO_1_tri_io[23] = 1'bz;//

endmodule

//テスト用LED点滅回路
module led_test(
	input clk,//クロック
	input rst_n,//リセット
	output reg led_out//LEDに接続
);
parameter brink_interval = 32'h01FFFFFF;
reg[31:0] led_counter;
always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		led_counter <= 32'h00000000;
		led_out <= 1'b0;
	end
	else if (led_counter >= brink_interval) begin
		led_counter <= 32'h00000000;
		led_out <= ~led_out;
	end
	else begin
		led_counter <= led_counter + 1'b1;
	end
end
endmodule


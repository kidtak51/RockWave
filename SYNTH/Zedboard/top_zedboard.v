module top_zedboard(
    input clk,
    output [7:0] led
);
`include "core_general.vh"
initial begin
    //$readmemh(`INST_ROM_FILE_NAME, u_inst_memory.mem);
    $readmemh("rv32ui-p-add.hex", u_inst_memory.mem);
end

//instant reset wave generate
reg[7:0] cnt = 8'd0;
reg rst_n = 1'b0;
always @(posedge clk) begin
	if ( cnt == 8'hFF ) begin
		cnt <= cnt;
		rst_n <= 1'b1;
	end
	else begin
		cnt <= cnt + 1'b1;
		rst_n <= 1'b0;
	end
end

top_core u_top_core(
	.clk            (clk            ),
    .rst_n          (rst_n          ),
    .inst_addr      (inst_addr      ),
    .inst_data      (inst_data      ),
    .data_mem_out   (data_mem_out   ),
    .data_mem_addr  (data_mem_addr  ),
    .data_mem_wdata (data_mem_wdata ),
    .data_mem_we    (data_mem_we    )
);

rom u_inst_memory
(
    .clk(clk),
    .rst_n(rst_n),
    .addr(inst_addr),
    .qout(inst_data)
);

ram u_data_memory(
    .clk(clk),
    .rst_n(rst_n),
    .addr(data_mem_addr),
    .qin(data_mem_wdata),
    .we(data_mem_we),
    .qout(data_mem_out)
);

wire [XLEN-1:0] pc = u_top_core.u_top_fetch.program_counter;
wire [XLEN-1:0] x01_ra = u_top_core.u_register_file.x1out;
wire [XLEN-1:0] x02_sp = u_top_core.u_register_file.x2out;
wire [XLEN-1:0] x03_gp = u_top_core.u_register_file.x3out;
wire [XLEN-1:0] x04_tp = u_top_core.u_register_file.x4out;
wire [XLEN-1:0] x05_t0 = u_top_core.u_register_file.x5out;
wire [XLEN-1:0] x06_t1 = u_top_core.u_register_file.x6out;
wire [XLEN-1:0] x07_t2 = u_top_core.u_register_file.x7out;
wire [XLEN-1:0] x08_s0_fp = u_top_core.u_register_file.x8out;
wire [XLEN-1:0] x09_s1 = u_top_core.u_register_file.x9out;
wire [XLEN-1:0] x10_a0 = u_top_core.u_register_file.x10out;
wire [XLEN-1:0] x11_a1 = u_top_core.u_register_file.x11out;
wire [XLEN-1:0] x12_a2 = u_top_core.u_register_file.x12out;
wire [XLEN-1:0] x13_a3 = u_top_core.u_register_file.x13out;
wire [XLEN-1:0] x14_a4 = u_top_core.u_register_file.x14out;
wire [XLEN-1:0] x15_a5 = u_top_core.u_register_file.x15out;
wire [XLEN-1:0] x16_a6 = u_top_core.u_register_file.x16out;
wire [XLEN-1:0] x17_a7 = u_top_core.u_register_file.x17out;
wire [XLEN-1:0] x18_s2 = u_top_core.u_register_file.x18out;
wire [XLEN-1:0] x19_s3 = u_top_core.u_register_file.x19out;
wire [XLEN-1:0] x20_s4 = u_top_core.u_register_file.x20out;
wire [XLEN-1:0] x21_s5 = u_top_core.u_register_file.x21out;
wire [XLEN-1:0] x22_s6 = u_top_core.u_register_file.x22out;
wire [XLEN-1:0] x23_s7 = u_top_core.u_register_file.x23out;
wire [XLEN-1:0] x24_s8 = u_top_core.u_register_file.x24out;
wire [XLEN-1:0] x25_s9 = u_top_core.u_register_file.x25out;
wire [XLEN-1:0] x26_s10 = u_top_core.u_register_file.x26out;
wire [XLEN-1:0] x27_s11 = u_top_core.u_register_file.x27out;
wire [XLEN-1:0] x28_t3 = u_top_core.u_register_file.x28out;
wire [XLEN-1:0] x29_t4 = u_top_core.u_register_file.x29out;
wire [XLEN-1:0] x30_t5 = u_top_core.u_register_file.x30out;
wire [XLEN-1:0] x31_t6 = u_top_core.u_register_file.x31out;

assign led = x10_a0[7:0];

endmodule

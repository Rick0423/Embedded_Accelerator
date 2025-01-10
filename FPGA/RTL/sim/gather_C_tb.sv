`timescale 1ns/1ps

module gather_c_tb;

parameter W = 8;
parameter N = 16;
parameter BRAM_W = 256;
parameter BRAM_AW = 10;
parameter DATA_A_SIZE_X = 64;
parameter DATA_A_SIZE_Y = 64;
parameter DATA_B_SIZE_X = 64;
parameter DATA_B_SIZE_Y = 64;

reg                 clk;
reg                 rst;
reg                 start_cal;
wire                gather_done;

wire                bram_clk_c;
wire                bram_we_c;
wire [BRAM_AW-1:0]  bram_addr_c;
wire [BRAM_W-1:0]   bram_wrdata_c;
reg  [BRAM_W-1:0]   bram_rddata_c;

reg  [N-1:0][2*W-1:0] c_outs;
wire [N-1:0][2*W-1:0] c_ins;

wire [DATA_A_SIZE_Y-1:0][N-1:0][2*W-1:0] debug_buffer;
wire [2:0] debug_state;
wire [2:0] debug_bram_state;
wire [N-1:0]    debug_in_block_cnt;
wire [N-1:0]    debug_write_back_cnt;
wire [DATA_B_SIZE_X/N-1:0]    debug_col_cnt;
wire [DATA_B_SIZE_Y/N-1:0]    debug_row_cnt;
wire debug_write_back;
wire debug_recieve_done;
wire debug_write_back_done;

gather_c #(
    .W(W),
    .N(N),
    .BRAM_W(BRAM_W),
    .BRAM_AW(BRAM_AW),
    .DATA_A_SIZE_X(DATA_A_SIZE_X),
    .DATA_A_SIZE_Y(DATA_A_SIZE_Y),
    .DATA_B_SIZE_X(DATA_B_SIZE_X),
    .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
) dut (
    .clk(clk),
    .rst(rst),
    .start_cal(start_cal),
    .gather_done(gather_done),
    .bram_clk_c(bram_clk_c),
    .bram_we_c(bram_we_c),
    .bram_addr_c(bram_addr_c),
    .bram_wrdata_c(bram_wrdata_c),
    .bram_rddata_c(bram_rddata_c),
    .c_outs(c_outs),
    .c_ins(c_ins),
    .debug_buffer(debug_buffer),
    .debug_bram_state(debug_bram_state),
    .debug_state(debug_state),
    .debug_in_block_cnt(debug_in_block_cnt),
    .debug_write_back_cnt(debug_write_back_cnt),
    .debug_col_cnt(debug_col_cnt),
    .debug_row_cnt(debug_row_cnt),
    .debug_write_back(debug_write_back),
    .debug_recieve_done(debug_recieve_done),
    .debug_write_back_done(debug_write_back_done)
);

initial begin
    clk = 0;
    rst = 1;
    #100 rst = 0;

    for(int j =0 ;j<16;j++) begin 
    start_cal = 0;
    bram_rddata_c = 0;
    c_outs = 0;
    #100 start_cal = 1;
    
    // 模拟输入数据
    for (int i = 0; i < DATA_A_SIZE_Y; i++) begin
        for (int j = 0; j < N; j++) begin
            c_outs[j] = $random;
        end
        @(posedge clk);
    end

    start_cal = 0;
    
    // 等待gather_done信号
    while (!gather_done) begin
        @(posedge clk);
    end
    #1000;
    end
    $stop;
    
end

always #5 clk = ~clk;

endmodule
`timescale 1ns/1ps

module compute_control_tb #(
    parameter W = 8,
    parameter N = 16,
    parameter DATA_A_SIZE_X = 64,
    parameter DATA_A_SIZE_Y = 64,
    parameter DATA_B_SIZE_X = 64,
    parameter DATA_B_SIZE_Y = 64
);

reg clk;
reg rst;
reg start;
wire Finish;
wire start_cal;
reg B_load_done;
reg A_col_cal_done;
wire B_load;
reg C_gather_done;

compute_control #(
    .W(W),
    .N(N),
    .DATA_A_SIZE_X(DATA_A_SIZE_X),
    .DATA_A_SIZE_Y(DATA_A_SIZE_Y),
    .DATA_B_SIZE_X(DATA_B_SIZE_X),
    .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
) DUT (
    .clk(clk),
    .rst(rst),
    .start(start),
    .Finish(Finish),
    .start_cal(start_cal),
    .B_load_done(B_load_done),
    .A_col_cal_done(A_col_cal_done),
    .B_load(B_load),
    .C_gather_done(C_gather_done)
);

// 时钟信号生成
always #5 clk = ~clk;

// 测试用例
initial begin
    clk = 0;
    rst = 1;
    start = 0;
    B_load_done = 0;
    A_col_cal_done = 0;
    C_gather_done = 0;

    // 复位
    #20
    rst = 0;


    // 启动计算
    #10
    start = 1;
    #10
    start = 0;


    for( int  m =0; m<16;m+=1) begin 
    // 模拟 B_load_done, A_col_cal_done, C_gather_done
    #10
    B_load_done = 1;
    #10
    B_load_done = 0;

    #10
    A_col_cal_done = 1;
    #10
    A_col_cal_done = 0;

    #10
    C_gather_done = 1;
    #10
    C_gather_done = 0;
end

    // 等待计算完成
    #100
    start = 1;
    #10
    start = 0;
    #100
    $display("Test completed.");
    $stop;
end

endmodule
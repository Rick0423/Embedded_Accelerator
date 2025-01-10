`timescale 1ns/1ps

module tb_Usr_Logic;

    // 参数定义
    localparam AXIL_AW = 32;
    localparam AXIL_DW = 32;

    // 时钟与复位信号
    reg clk;
    reg resetn;

    // AXI-Lite 信号
    reg [AXIL_AW-1:0] s_axil_awaddr;
    reg s_axil_awvalid;
    wire s_axil_awready;
    reg [AXIL_DW-1:0] s_axil_wdata;
    reg [3:0] s_axil_wstrb;
    reg s_axil_wvalid;
    wire s_axil_wready;
    wire [1:0] s_axil_bresp;
    wire s_axil_bvalid;
    reg s_axil_bready;
    reg [AXIL_AW-1:0] s_axil_araddr;
    reg s_axil_arvalid;
    wire s_axil_arready;
    wire [AXIL_DW-1:0] s_axil_rdata;
    wire [1:0] s_axil_rresp;
    wire s_axil_rvalid;
    reg s_axil_rready;

    // Debug信号
    wire debug_start;
    wire debug_Finish;

    // DUT实例化
    Usr_Logic #(
        .AXIL_AW(AXIL_AW),
        .AXIL_DW(AXIL_DW)
    ) DUT (
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready),
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready),
        .user_clk(clk),
        .user_resetn(resetn),
        .debug_start(debug_start),
        .debug_Finish(debug_Finish)
    );

    // 时钟生成
    always #5 clk = ~clk; // 100MHz 时钟周期

    // Testbench逻辑
    initial begin
        // 初始化信号
        clk = 0;
        resetn = 0;
        s_axil_awaddr = 0;
        s_axil_awvalid = 0;
        s_axil_wdata = 0;
        s_axil_wstrb = 4'b1111;
        s_axil_wvalid = 0;
        s_axil_bready = 0;
        s_axil_araddr = 0;
        s_axil_arvalid = 0;
        s_axil_rready = 0;

        // 释放复位
        #20 resetn = 1;

        // 1. 写启动地址 ADDR_START (0x1000)
        @(posedge clk);
        s_axil_awaddr = 32'h0000_1000; // 启动地址
        s_axil_awvalid = 1;
        s_axil_wdata = 32'h1; // 写入启动信号
        s_axil_wvalid = 1;
        s_axil_bready = 1;
        @(posedge clk);
        while (!s_axil_awready || !s_axil_wready) @(posedge clk); // 等待写完成
        s_axil_awvalid = 0;
        s_axil_wvalid = 0;

        // 2. 轮询读取完成状态 ADDR_STATUS (0x2000)
        @(posedge clk);
        s_axil_araddr = 32'h0000_2000; // 状态地址
        s_axil_arvalid = 1;
        s_axil_rready = 1;
        @(posedge clk);
        while (!s_axil_arready) @(posedge clk); // 等待地址握手
        s_axil_arvalid = 0;

        // 读取完成状态
        @(posedge clk);
        while (!s_axil_rvalid) @(posedge clk); // 等待读数据有效
        if (s_axil_rdata == 32'h2) begin
            $display("计算完成，状态值 = %d", s_axil_rdata);
        end else begin
            $display("计算未完成，状态值 = %d", s_axil_rdata);
        end

        // 停止仿真
        #100;
        $stop;
    end
endmodule

`timescale 1ns/1ps
   parameter C_USER_MEM_SIZE = 32'h0000_0021;
   parameter C_NUM_USR_IRQ = 1;
   parameter W = 8 ;
   parameter N = 16 ;
   parameter BRAM_DW = 64;
   parameter BRAM_AW = 10;
   parameter DATA_A_SIZE_X = 64;
   parameter DATA_A_SIZE_Y = 64;
   parameter DATA_B_SIZE_X = 64;
   parameter DATA_B_SIZE_Y = 64;
   parameter AXIL_AW = 32;
   parameter AXIL_DW = 32;
   parameter AXI_DW = 64;

module tb_Usr_Logic;

    // 参数定义
    localparam ADDR_STATUS = 32'h0000_1000;


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
    reg starting ; 

    wire [N-1:0][W-1:0]   debug_a_in;
    wire [N-1:0][2*W-1:0] debug_c_out;  
    wire [N-1:0][N-1:0][2*W-1:0] debug_c_outs;
    wire [N-1:0][N-1:0][W-1:0] debug_a_data;    
    wire debug_C_gather_done;
    wire debug_start_cal;

    wire [BRAM_DW*2-1:0] debug_bram_rddata_a2;
    wire [BRAM_DW*2-1:0] debug_bram_rddata_b2;
    wire [BRAM_DW*4-1:0] debug_bram_wrdata_c2;
    
    wire [BRAM_AW-2:0] debug_bram_addr_a2;
    wire [BRAM_AW-2:0] debug_bram_addr_b2;
    wire [BRAM_AW-2:0] debug_bram_addr_c2;
    wire [DATA_A_SIZE_Y-1:0][N-1:0][2*W-1:0] debug_C_buffer;
    wire [N-1:0][N-1:0][W-1:0]  debug_B_buffer;




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
        .debug_start_cal(debug_start_cal),
        .debug_C_gather_done(debug_C_gather_done),
        .debug_a_data(debug_a_data),
        .debug_c_outs(debug_c_outs),
        .debug_c_out(debug_c_out),
        .debug_a_in(debug_a_in),

        //for debugging 
    .debug_bram_rddata_a2(debug_bram_rddata_a2),
    .debug_bram_rddata_b2(debug_bram_rddata_b2),
    .debug_bram_wrdata_c2(debug_bram_wrdata_c2),
   
    .debug_bram_addr_a2(debug_bram_addr_a2),
    .debug_bram_addr_b2(debug_bram_addr_b2),
    .debug_bram_addr_c2(debug_bram_addr_c2),
    .debug_C_buffer(debug_C_buffer),
    .debug_B_buffer(debug_B_buffer)

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
        axi_read(ADDR_STATUS,starting);
        #180_00
        // 停止仿真
        $stop;
    end

    task axi_read(input [31:0] addr, output reg [31:0] data);
        begin
            s_axil_araddr = addr;
            s_axil_arvalid = 1;

            wait(s_axil_arready);
            s_axil_arvalid = 0;

            s_axil_rready = 1;
            wait(s_axil_rvalid);
            data = s_axil_rdata;
            s_axil_rready = 0;
        end
    endtask

endmodule   
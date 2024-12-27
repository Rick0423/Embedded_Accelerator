module Usr_control (
    input wire aresetn,            // 异步复位 (低有效)
    input wire aclk,               // AXI Lite 时钟
    
    output reg start,              // 启动信号，触发计算模块开始
    input wire Finish,             // 计算完成信号，来自计算模块

    // AXI Lite 接口信号
    input wire awvalid,
    output reg awready,
    input wire [31:0] awaddr,
    input wire wvalid,
    output reg wready,
    input wire [31:0] wdata,
    input wire [3:0] wstrb,
    output reg [1:0] bresp,
    output reg bvalid,
    input wire bready,
    input wire [31:0] araddr,
    input wire arvalid,
    output reg arready,
    output reg [31:0] rdata,
    output reg [1:0] rresp,
    output reg rvalid,
    input wire rready
);

    // 地址定义
    localparam ADDR_START  = 32'h0000_1000;  // 启动信号地址
    localparam ADDR_STATUS = 32'h0000_2000;  // 计算状态地址

    // 内部寄存器
    (* mark_debug = "true" *)reg finish_reg; // 存储计算完成状态
    reg start_2;
    reg Finish_2;

    reg process;

    // 读操作
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            arready <= 0 ;
            rvalid <= 0 ;
            finish_reg <= 0 ;
            Finish_2 <= 0 ;
            start <= 0 ;
            start_2 <= 0;
            awready <= 0;
            wready <= 0;
            wready <= 0;
            bvalid <=0;
            process <= 0;
        end else begin
            Finish_2 <= Finish;
            
            if((Finish==1) && (Finish_2==0)) begin 
                finish_reg <= 1; // 计算完成
            end

            if(start) begin
                    start_2<=1;
                end

            if(start & start_2) begin 
                start<=0;
                start_2<=0;
            end

            // 处理读事务
            if (arvalid && !arready) begin
                arready <= 1; // 接受读地址
                if (araddr[13:12] == 2'b10) begin
                    if(finish_reg) begin 
                        rdata <= 32'd2; 
                        process <= 0;
                        end
                    else rdata <= 32'd0;
                end else if(araddr[13:12] == 2'b01) begin
                    rdata <= 31'd1; 
                    if(process == 0) begin
                        start <= 1;
                        finish_reg <= 0;
                        process <= 1;
                    end 
                end else begin  
                    rdata <= 32'b0; // 返回默认值
                end
            end else begin
                arready <= 0;
            end

            // 读响应
            if (arready && !rvalid) begin
                rvalid <= 1; // 读响应有效
                rresp <= 2'b00; // 返回 OKAY 响应
            end else if (rvalid && rready) begin
                rvalid <= 0;
            end
        end
    end

endmodule
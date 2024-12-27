module compute_control #(
    parameter W = 8,
    parameter N = 16,
    parameter DATA_A_SIZE_X = 64,
    parameter DATA_A_SIZE_Y = 64,
    parameter DATA_B_SIZE_X = 64,
    parameter DATA_B_SIZE_Y = 64
)
(
    input wire clk,
    input wire rst,
    input wire start,
    output reg Finish,

    output reg start_cal,
    input wire B_load_done,
    input wire A_col_cal_done,
    output reg B_load,
    input wire C_gather_done
);

// 定义状态机的状态
localparam IDLE         = 3'd0  ,
           PREPARING    = 3'd1  ,
           COMPUTING    = 3'd2  ,
           WAITING      = 3'd3  ,
           
           ROW_CNT      = DATA_A_SIZE_Y/N      ,
           COL_CNT      = DATA_B_SIZE_X/N      ;    
           

reg [2:0] state;
reg [DATA_B_SIZE_X/N-1:0] col_cnt;
reg [DATA_B_SIZE_Y/N-1:0] row_cnt;

// 状态转移逻辑和输出逻辑
always @(posedge clk ) begin
    if (rst) begin
        state <= IDLE;
        start_cal <= 0;
        B_load <= 0;
        Finish <= 0;
        row_cnt <= 0;
        col_cnt <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= PREPARING;
                    B_load <= 1;
                end else begin
                    B_load <= 0;
                    start_cal <=0 ;
                    Finish <= 0;
                end
            end
            PREPARING: begin
                if (B_load_done) begin
                    state <= COMPUTING;
                    start_cal <= 1;
                    B_load <= 0;
                end else begin
                    start_cal <= 0;
                    B_load <= 0;
                end
            end
            COMPUTING: begin
                if (C_gather_done) begin
                    if(row_cnt == ROW_CNT -1) begin 
                        row_cnt <= 0;
                        if(col_cnt == COL_CNT -1) begin 
                            col_cnt <= 0;
                            Finish <= 1;
                            state <= IDLE;
                        end else begin 
                            Finish <= 0;
                            col_cnt <= col_cnt +1;
                            state <= PREPARING;
                            B_load <= 1;
                        end
                    end else begin 
                        row_cnt <= row_cnt +1 ; 
                        Finish <= 0;
                        state <= PREPARING;
                        B_load <= 1;
                    end
                end else begin
                    Finish <= 0;
                    start_cal <= 0;
                end
            end
            default: begin
                state <= IDLE;
                Finish <= 0;
                start_cal <= 0;
                B_load <= 0;
            end
        endcase
    end
end

endmodule
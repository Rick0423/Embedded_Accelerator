module scatter_a #(
    parameter W = 8,
    parameter N = 64,
    parameter BRAM_W = 128,
    parameter BRAM_AW = 9,
    parameter DATA_A_SIZE_X = 64,
    parameter DATA_A_SIZE_Y = 64,
    parameter DATA_B_SIZE_X = 64,
    parameter DATA_B_SIZE_Y = 64
)
(
    input wire rst,
    input wire clk,
    input wire start_cal,
    
    output wire  bram_clk_a,
    output wire  bram_we_a,
    output wire [BRAM_AW-1:0] bram_addr_a,
    output reg  [BRAM_W-1:0]  bram_wrdata_a,
    input wire  [BRAM_W-1:0]  bram_rddata_a,

    output reg [N-1:0][W-1:0] a_in,
    output reg col_cal_done,
    output wire [2:0] debug_A_state,
    output wire[DATA_A_SIZE_X/N-1:0] A_col_cnt,
    output wire[N-1:0] A_in_block_cnt

);

// Address and control counters
reg [12:0] bram_addr_pointer;
reg [DATA_A_SIZE_X/N-1:0] col_cnt;
reg output_enable ;

reg  [N-1:0] in_block_cnt;
wire [12:0] base_addr_reg;

reg [2:0] state ;
localparam IDLE = 3'd0,
           CALCULATE = 3'd1,
           WAITING = 3'd2,
           DONE = 3'd4,

           ROW_CNT = DATA_A_SIZE_Y / N ,
           COL_CNT = DATA_A_SIZE_X / N ;

assign bram_clk_a = clk ; // Read on the negedge of the clk ,to make sure the data
assign bram_we_a  = 0    ; // no need to write this Bram
assign bram_addr_a = bram_addr_pointer[12:4];

// Start addr of current block
assign bram_addr_pointer = in_block_cnt * (DATA_A_SIZE_X ) + col_cnt * N;

always @(posedge clk ) begin
    if (rst) begin
        // Reset logic
        col_cnt <= 0;
        state <= IDLE; 
        bram_wrdata_a <= 0;


    end else  begin
        case(state)
            IDLE: begin
                if(start_cal) begin 
                    state <= CALCULATE ; 
                    in_block_cnt <= 0;
                end
                else begin 
                    output_enable <= 0;
                    col_cal_done <= 0;
                    state<= IDLE ;
                    in_block_cnt <= 0;
                end 
            end
            CALCULATE: begin
                if(in_block_cnt == DATA_A_SIZE_Y -1 )  begin
                    if(col_cnt == COL_CNT-1) begin 
                        col_cnt <= 0;
                        col_cal_done <= 1 ;
                        state<= IDLE ;
                    end else begin 
                        in_block_cnt <= 0 ; 
                        col_cnt += 1; 
                        state <= WAITING;
                    end
                end else begin 
                    output_enable <= 1;
                    in_block_cnt += 1;
                end
            end
            WAITING: begin 
                if(start_cal) begin 
                    state <= CALCULATE ;
                end
                else begin 
                    output_enable <= 0;
                    state <= WAITING ;
                end
            end
        endcase
    end
end



genvar j;  // 静态生成索引变量
generate
    for (j = 0; j < N; j = j + 1) begin : gen_block
        assign a_in[j] =(output_enable ) ? bram_rddata_a[W*j + W-1 : W*j]:0;
    end
endgenerate



assign debug_A_state = state;

endmodule
module scatter_b #(
    parameter W = 8,
    parameter N = 16,
    parameter BRAM_W = 128,
    parameter BRAM_AW = 10,
    parameter DATA_A_SIZE_X = 64,
    parameter DATA_A_SIZE_Y = 64,
    parameter DATA_B_SIZE_X = 64,
    parameter DATA_B_SIZE_Y = 64
)
(
    input wire rst,
    input wire clk,
    input wire load,
    
    output wire bram_clk_b,
    output wire bram_we_b,
    output wire [BRAM_AW-1:0] bram_addr_b,
    output reg  [BRAM_W-1:0] bram_wrdata_b,
    input wire  [BRAM_W-1:0] bram_rddata_b,

    output reg [N-1:0][W-1:0] b_ins,
    output reg stationaryCtrl,
    output reg load_done,

    //for debugging wires 
    output wire [2:0]debug_state,
    output wire [N-1:0]debug_in_block_cnt,
    output wire [DATA_B_SIZE_X/N-1:0]debug_col_cnt,
    output wire [DATA_B_SIZE_X/N-1:0]debug_row_cnt,
    output wire [N-1:0][N-1:0][W-1:0]  debug_B_buffer,
    output wire [N-1:0]     debug_load_cnt,
    output wire [12:0]      debug_bram_addr_pointer
);


// Address and control counters
reg [12:0] bram_addr_pointer;
(* mark_debug = "true" *)reg [N-1:0][N-1:0][W-1:0] buffer_B;
reg [DATA_B_SIZE_X/N-1:0] col_cnt;
reg [DATA_B_SIZE_X/N-1:0] row_cnt;
reg Final;

reg [N-1:0] in_block_cnt;
reg [N-1:0] load_cnt;

reg first ;
reg [2:0] state ;
localparam IDLE = 3'd0,
           PREPARING = 3'd1,
           LOADING = 3'd2,
           WAITING = 3'd3,
           DONE = 3'd4,

           ROW_CNT = DATA_A_SIZE_Y / N ,
           COL_CNT = DATA_A_SIZE_X / N ;

assign bram_clk_b = clk ; // Read on the negedge of the clk ,to make sure the data
assign bram_we_b  = 0    ; // no need to write this Bram
assign bram_addr_b = bram_addr_pointer[12:4];


// Start addr of current block
assign bram_addr_pointer = row_cnt * N  * DATA_B_SIZE_X + col_cnt * N   + in_block_cnt * (DATA_A_SIZE_X ) ;


always @(posedge clk ) begin
    if (rst) begin
        // Reset logic
        col_cnt <= 0;
        state <= 0; 
        bram_wrdata_b <= 0;
        load_cnt <=0 ;

    end else  begin
        case(state)
            IDLE: begin
                if(load) begin 
                    state <= PREPARING ;
                end
                else begin 
                    first <= 1;
                    stationaryCtrl <= 0;
                    load_done <= 0;
                    stationaryCtrl <= 0; 
                    state<= IDLE ;
                    in_block_cnt <= 0;
                    col_cnt <= 0;
                    row_cnt <= 0;  
                    load_cnt<= 0;
                end 
            end
            PREPARING: begin
                load_done <= 0;
                stationaryCtrl <= 0; 
                if(in_block_cnt == N+1)  begin
                    in_block_cnt <= 0 ;
                    
                    if(row_cnt == ROW_CNT-1) begin 
                        if(col_cnt == COL_CNT-1) begin 
                            state <= WAITING ;
                            row_cnt <= 0;
                            col_cnt <= 0;
                            Final <= 1;
                        end else begin 
                            state <= WAITING; 
                            row_cnt <= 0;
                            col_cnt <= col_cnt + 1;
                        end 
                    end else begin 
                        row_cnt <= row_cnt + 1; 
                        col_cnt <= col_cnt;
                        state <= WAITING;
                    end
                end else begin 
                    in_block_cnt += 1;
                end
            end
            WAITING: begin 
                load_done <= 0;
                if(load || first) begin 
                    state <= LOADING ;
                    stationaryCtrl <= 1;
                    first <= 0;
                end
                else begin 
                    state <= WAITING ;
                end
            end
            LOADING : begin 
                if(load_cnt == N-1) begin 
                    load_done <= 1;
                    stationaryCtrl <= 1;
                    load_cnt <= 0 ;
                    if(Final) begin 
                        state <= IDLE; 
                        Final <= 0;
                    end else begin 
                        state <= PREPARING; 
                    end
                end else begin 
                    load_cnt <= load_cnt + 1 ;
                end
            end
        endcase
    end
end



genvar j;  // 静态生成索引变量
generate
    for (j = 0; j < N; j = j + 1) begin : gen_buffer
        always_ff @(posedge clk) begin
            if (rst) begin
                integer  m;
                    for(m =0 ;m<N;m+=1) begin 
                        buffer_B[m][j] <= '0;
                    end
            end else if( state == PREPARING ) begin
                buffer_B[in_block_cnt-1][j] <= bram_rddata_b[W*j + W-1 : W*j];
            end else begin
                buffer_B[in_block_cnt-1][j] <= buffer_B[in_block_cnt-1][j];
            end
        end
    end
endgenerate

genvar i;  // 静态生成索引变量
generate
    for (i = 0; i < N; i = i + 1) begin : gen_load
        always_ff @(posedge clk) begin
            if (rst) begin
                b_ins[i] <= '0;  // 复位时置零
            end else if( state == LOADING ) begin
                b_ins[i] <= buffer_B[i][load_cnt];
            end else begin 
                b_ins[i] <= '0;
            end
        end
    end
endgenerate


assign debug_state  = state;
assign debug_in_block_cnt = in_block_cnt;
assign debug_col_cnt = col_cnt;
assign debug_row_cnt = row_cnt;
assign debug_B_buffer  = buffer_B;
assign debug_load_cnt= load_cnt;
assign debug_bram_addr_pointer = bram_addr_pointer;
endmodule

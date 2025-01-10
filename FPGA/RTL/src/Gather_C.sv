module gather_c #(
    parameter W = 8,
    parameter N = 16,
    parameter BRAM_W = 256,
    parameter BRAM_AW = 10,
    parameter DATA_A_SIZE_X = 64,
    parameter DATA_A_SIZE_Y = 64,
    parameter DATA_B_SIZE_X = 64,
    parameter DATA_B_SIZE_Y = 64
)
(
    input wire                clk            ,
    input wire                rst            ,
    input  wire               start_cal      ,
    output reg                gather_done    ,

    output wire               bram_clk_c     ,
    output reg                bram_we_c      ,
    output reg  [BRAM_AW-1:0] bram_addr_c    ,
    output wire  [BRAM_W-1:0]  bram_wrdata_c ,
    input  wire  [BRAM_W-1:0]  bram_rddata_c ,

    input  wire signed [N-1:0][2*W-1:0] c_outs      ,
    output reg  [N-1:0][2*W-1:0] c_ins       ,
    output wire [DATA_A_SIZE_Y-1:0][N-1:0][2*W-1:0] debug_buffer,
    output wire [2:0] debug_state,
    output wire [2:0] debug_bram_state,
    output wire [N-1:0]    debug_in_block_cnt,
    output wire [N-1:0]    debug_write_back_cnt,
    output wire [DATA_B_SIZE_X/N-1:0]    debug_col_cnt,
    output wire [DATA_B_SIZE_Y/N-1:0]    debug_row_cnt,
    output wire debug_write_back,
    output wire debug_recieve_done,
    output wire debug_write_back_done
);

localparam  IDLE = 3'd0,
            GATHERING = 3'd1,
            WAITING = 3'd2,

            WRITING = 3'd3,
            CLEANING = 3'd4,

            ROW_CNT = DATA_B_SIZE_Y / N ,
            COL_CNT = DATA_B_SIZE_X / N ;

reg [2:0] state ;
reg [2:0]bram_state;

// Address and control counters
reg [12:0] bram_addr_pointer;
reg [DATA_B_SIZE_X/N-1:0] col_cnt;
reg [DATA_B_SIZE_Y/N-1:0] row_cnt;

reg  [N-1:0] in_block_cnt;
reg  [N-1:0] write_back_cnt;
reg  [N-1:0] cleaning_cnt;
wire [12:0] base_addr_reg;

reg signed [DATA_A_SIZE_Y-1:0][N-1:0][2*W-1:0] buffer;

reg write_back;
reg write_back_done;
reg recieve_done;

assign bram_clk_c = clk;
assign bram_addr_c = bram_addr_pointer[12:5];
assign bram_addr_pointer = write_back_cnt * 2  * DATA_B_SIZE_X + col_cnt * 2  * N;
assign bram_we_c = (bram_state == WRITING);

assign gather_done = (bram_state == CLEANING) ? write_back_done :  recieve_done & !write_back;


always @(posedge clk ) begin 
    if (rst) begin 
        write_back_cnt <=0;
        bram_state <= IDLE; 
        write_back_done <= 1;
        //bram_we_c <= 0;
        //col_cnt <= 0;
        //row_cnt<=0;
        //in_block_cnt <= 0;
    end else begin 
        case(bram_state)
        IDLE:begin 
            if(write_back) begin 
                bram_state <= WRITING;
                write_back_done <= 0;
                //bram_we_c <= 0;
            end else begin
                write_back_cnt  <= 0;
                write_back_done <= 1;
                //bram_we_c <= 0;
            end
        end

        WRITING:begin 
            if(write_back_cnt == DATA_A_SIZE_Y -1) begin 
                bram_state <= CLEANING ;
                write_back_done <= 1;
                write_back_cnt <=  0;
                //bram_we_c <= 1;
            end else begin 
                write_back_cnt += 1;
                write_back_done <= 0;
                //bram_we_c <= 1;
            end
        end

        CLEANING :begin
            bram_state <= IDLE;
            //bram_we_c <= 0;
        end
        endcase
    end
end

always @(posedge clk) begin
    if(rst) begin 
        state <= IDLE;
        recieve_done <= 0;
        in_block_cnt <= 0;
        row_cnt <= 0;
        col_cnt <= 0;
    end else begin 
        case (state)
            IDLE: begin 
                 recieve_done <= 0;
                 write_back <= 0;
                 if(start_cal) begin 
                    state <= GATHERING;
                 end
            end

            GATHERING :begin 
                if(in_block_cnt == DATA_A_SIZE_Y+1) begin 
                    state <= WAITING ; 
                    in_block_cnt <= 0;
                    recieve_done <= 1;
                    if(row_cnt == ROW_CNT-1) begin 
                        write_back <= 1;
                        end   
                end else begin 
                    in_block_cnt <= in_block_cnt + 1 ;
                    recieve_done <= 0; 
                end
            end

            WAITING : begin 
                write_back <= 0;
                recieve_done <= 0;
                if(start_cal)begin
                    state <= GATHERING;
                end
                if(gather_done) begin 
                    if(row_cnt == ROW_CNT-1) begin
                        row_cnt <= 0;
                        if(col_cnt == COL_CNT-1) begin 
                            col_cnt <= 0;
                            state <= IDLE;
                        end else begin 
                            col_cnt <= col_cnt + 1 ;
                            state <= WAITING;
                        end 
                    end else begin 
                        state <= WAITING; 
                        row_cnt <= row_cnt + 1 ;
                    end
                end
            end
            
        endcase
    end
end



genvar j;  
generate
    for (j = 0; j < N; j = j + 1) begin : gen_block
            assign  bram_wrdata_c[2*W*(j+1)-1:2*W*j] = (bram_state == WRITING) ?  buffer[write_back_cnt][j]:0;
    end
endgenerate


genvar ji;  
generate
    for (ji = 0; ji < N; ji = ji + 1) begin : gen_block1
        always_ff @(posedge clk) begin
            if (rst || (state == IDLE) || (bram_state == CLEANING)) begin
                integer  m;
                    for(m =0 ;m<DATA_A_SIZE_X;m+=1) begin 
                        buffer[m][ji] <= 0;
                    end
            end else if(state == GATHERING) begin
                buffer[in_block_cnt-1][ji] <= buffer[in_block_cnt-1][ji]+ c_outs[ji];
            end else begin
                buffer[in_block_cnt-1][ji] <= buffer[in_block_cnt-1][ji];
            end
        end
    end
endgenerate


//genvar jk;  
//generate
//    for (jk = 0; jk < N; jk = jk + 1) begin : gen_block2
//        assign c_ins[jk] = (state == GATHERING) ? buffer[in_block_cnt][jk] : 0;
//    end
//endgenerate



assign debug_buffer = buffer;
assign debug_bram_state = bram_state;
assign debug_state = state;
assign debug_in_block_cnt = in_block_cnt;
assign debug_write_back_cnt = write_back_cnt;
assign debug_col_cnt = col_cnt;
assign debug_row_cnt = row_cnt;
assign debug_write_back = write_back;
assign debug_recieve_done = recieve_done;
assign debug_write_back_done = write_back_done;
endmodule
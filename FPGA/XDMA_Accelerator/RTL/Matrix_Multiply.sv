module Matrix_Multiply #(
    parameter W = 8,
    parameter N = 16,
    parameter BRAM_W = 64,
    parameter BRAM_AW = 10,
    parameter DATA_A_SIZE_X = 64,
    parameter DATA_A_SIZE_Y = 64,
    parameter DATA_B_SIZE_X = 64,
    parameter DATA_B_SIZE_Y = 64
)
(
    input wire clk,
    input wire rst,

    // bram interface
    output wire  bram_clk_a, bram_clk_b, bram_clk_c,
    output wire  bram_we_a , bram_we_b , bram_we_c,
    output wire [BRAM_AW-2:0]     bram_addr_a, bram_addr_b, 
    output wire [BRAM_AW-3:0]     bram_addr_c,
    output wire [BRAM_W*2-1:0]    bram_wrdata_a, bram_wrdata_b, 
    input  wire [BRAM_W*2-1:0]    bram_rddata_a, bram_rddata_b,
    input  wire [BRAM_W*4-1:0]    bram_rddata_c,
    output wire [BRAM_W*4-1:0]    bram_wrdata_c,

    input wire start,
    output wire Finish,

    output wire [N-1:0][W-1:0]   debug_a_in,
    output wire [N-1:0][W-1:0]   debug_b_in, 
    output wire [N-1:0][2*W-1:0] debug_c_in,
    output wire [N-1:0][2*W-1:0] debug_c_out,

    output wire [N-1:0][N-1:0][W-1:0] debug_a_ins,
    output wire [N-1:0][N-1:0][W-1:0] debug_a_outs,
    output wire [N-1:0][N-1:0][2*W-1:0] debug_c_outs,
    output wire [N-1:0][N-1:0][W-1:0] debug_a_data,

    output wire debug_B_load_done,
    output wire debug_B_load,
    output wire debug_stationaryCtrl,
    output wire debug_C_gather_done,
    output wire debug_start_cal,
    output wire debug_A_state,
    output wire [N-1:0][N-1:0][W-1:0] debug_B_buffer,

    output wire [DATA_B_SIZE_X/N-1:0]debug_col_cnt,
    output wire [DATA_B_SIZE_X/N-1:0]debug_row_cnt,
    output wire [2:0]debug_state,

    output wire [DATA_A_SIZE_Y-1:0][N-1:0][2*W-1:0] debug_C_buffer,
    output wire [2:0] debug_C_state,
    output wire [2:0] debug_C_bram_state,
    output wire [N-1:0]    debug_C_in_block_cnt,
    output wire [N-1:0]    debug_C_write_back_cnt,
    output wire [DATA_B_SIZE_X/N-1:0]    debug_C_col_cnt,
    output wire [DATA_B_SIZE_Y/N-1:0]    debug_C_row_cnt,
    output wire debug_C_write_back,
    output wire debug_C_recieve_done,
    output wire debug_C_write_back_done    
);

    (* mark_debug = "true" *)wire [N-1:0][W-1:0] a_ins;
    (* mark_debug = "true" *)wire [N-1:0][W-1:0] b_ins;
    wire [N-1:0][2*W-1:0] c_ins;
    (* mark_debug = "true" *)wire [N-1:0][2*W-1:0] c_outs;

    (* mark_debug = "true" *)wire    A_col_cal_done;
    (* mark_debug = "true" *)wire    B_load_done;
    (* mark_debug = "true" *)wire    B_load;
    (* mark_debug = "true" *)wire    stationaryCtrl;
    (* mark_debug = "true" *)wire    C_gather_done;
    (* mark_debug = "true" *)wire    start_cal;

scatter_a #(
    .W(W),
    .N(N),
    .BRAM_W(BRAM_W*2),
    .BRAM_AW(BRAM_AW-1),
    .DATA_A_SIZE_X(DATA_A_SIZE_X),
    .DATA_A_SIZE_Y(DATA_A_SIZE_Y),
    .DATA_B_SIZE_X(DATA_B_SIZE_X),
    .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
) scatter_a_inst
(
    .rst(rst),
    .clk(clk),
    .start_cal(start_cal),

    .bram_clk_a(bram_clk_a),
    .bram_we_a(bram_we_a),
    .bram_addr_a(bram_addr_a),
    .bram_wrdata_a(bram_wrdata_a),
    .bram_rddata_a(bram_rddata_a),

    .a_in(a_ins),
    .col_cal_done(A_col_cal_done),
    .debug_A_state(debug_A_state)
);

scatter_b #(
    .W(W),
    .N(N),
    .BRAM_W(BRAM_W*2),
    .BRAM_AW(BRAM_AW-1),
    .DATA_A_SIZE_X(DATA_A_SIZE_X),
    .DATA_A_SIZE_Y(DATA_A_SIZE_Y),
    .DATA_B_SIZE_X(DATA_B_SIZE_X),
    .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
) scatter_b_inst
(
    .rst(rst),
    .clk(clk),
    .load(B_load),

    .bram_clk_b(bram_clk_b),
    .bram_we_b(bram_we_b),
    .bram_addr_b(bram_addr_b),
    .bram_wrdata_b(bram_wrdata_b),
    .bram_rddata_b(bram_rddata_b),

    .b_ins(b_ins),
    .stationaryCtrl(stationaryCtrl),
    .load_done(B_load_done),
    .debug_B_buffer(debug_B_buffer),
    .debug_state(debug_state),
    .debug_col_cnt(debug_col_cnt),
    .debug_row_cnt(debug_row_cnt)
);

gather_c #(
    .W(W),
    .N(N),
    .BRAM_W(BRAM_W*4),
    .BRAM_AW(BRAM_AW-2),
    .DATA_A_SIZE_X(DATA_A_SIZE_X),
    .DATA_A_SIZE_Y(DATA_A_SIZE_Y),
    .DATA_B_SIZE_X(DATA_B_SIZE_X),
    .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
) gather_c_inst
(
    .clk(clk)           ,
    .rst(rst)           ,
    .start_cal(start_cal)     ,
    .gather_done(C_gather_done)   ,

    .bram_clk_c(bram_clk_c)    ,
    .bram_we_c(bram_we_c)     ,
    .bram_addr_c(bram_addr_c)   ,
    .bram_wrdata_c(bram_wrdata_c) ,
    .bram_rddata_c(bram_rddata_c) ,

    .c_outs(c_outs)     ,
    .c_ins(c_ins),
    .debug_buffer(debug_C_buffer),
    .debug_state(debug_C_state),
    .debug_bram_state(debug_C_bram_state),
    .debug_in_block_cnt(debug_C_in_block_cnt),
    .debug_write_back_cnt(debug_C_write_back_cnt),
    .debug_col_cnt(debug_C_col_cnt),
    .debug_row_cnt(debug_C_row_cnt),
    .debug_write_back(debug_C_write_back),
    .debug_recieve_done(debug_C_recieve_done),
    .debug_write_back_done(debug_C_write_back_done)
    
);

PE_array #(
    .W(W),
    .N(N)
) PE_array_inst
(
    .clk(clk), .rst(rst), .stationaryCtrl(stationaryCtrl),
    .a_in(b_ins),
    .b_in(a_ins),
    .c_in(c_in),
    .c_out(c_outs),

    .debug_a_ins(debug_a_ins),
    .debug_a_outs(debug_a_outs),
    .debug_c_outs(debug_c_outs),
    .debug_a_data(debug_a_data)
);

compute_control #(
    .W(W),
    .N(N),
    .DATA_A_SIZE_X(DATA_A_SIZE_X),
    .DATA_A_SIZE_Y(DATA_A_SIZE_Y),
    .DATA_B_SIZE_X(DATA_B_SIZE_X),
    .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
) compute_control_inst
(
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


assign debug_a_in = a_ins;
assign debug_b_in = b_ins;
assign debug_c_in = c_ins;
assign debug_c_out = c_outs ;
assign debug_B_load_done = B_load_done;
assign debug_B_load = B_load;
assign debug_stationaryCtrl = stationaryCtrl;
assign debug_C_gather_done = C_gather_done;
assign debug_start_cal = start_cal;
endmodule
module Usr_Logic #(
   parameter C_USER_MEM_SIZE = 32'h0000_0021,
   parameter C_NUM_USR_IRQ = 1,
   parameter W = 8 ,
   parameter N = 16 ,
   parameter BRAM_DW = 64,
   parameter BRAM_AW = 10,
   parameter DATA_A_SIZE_X = 64,
   parameter DATA_A_SIZE_Y = 64,
   parameter DATA_B_SIZE_X = 64,
   parameter DATA_B_SIZE_Y = 64,
   parameter AXIL_AW = 32,
   parameter AXIL_DW = 32,
   parameter AXI_DW = 64
)
(
   // AXI Lite Master Interface connections
   input  wire  [AXIL_AW-1:0]   s_axil_awaddr,
   input  wire           s_axil_awvalid,
   output wire           s_axil_awready,
   input  wire  [AXIL_DW-1:0]   s_axil_wdata,
   input  wire   [3:0]   s_axil_wstrb,
   input  wire           s_axil_wvalid,
   output wire           s_axil_wready,  // Change to wire
   output wire  [1:0]    s_axil_bresp,   // Change to wire
   output wire           s_axil_bvalid,  // Change to wire
   input  wire           s_axil_bready,
   input  wire  [AXIL_AW-1:0]   s_axil_araddr,
   input  wire           s_axil_arvalid,
   output wire           s_axil_arready,
   output wire  [AXIL_DW-1:0]   s_axil_rdata,
   output wire  [1:0]    s_axil_rresp,   // Change to wire
   output wire           s_axil_rvalid,  // Change to wire
   input  wire           s_axil_rready,
   input  wire           user_clk,
   input  wire           user_resetn,        // low active
   output reg [C_NUM_USR_IRQ-1:0] usr_irq_req,
   input wire   [C_NUM_USR_IRQ-1:0] usr_irq_ack,

   // Bram access for Externel read/write
   input wire  bram_clk1,
   input wire [BRAM_AW-1:0] bram_addr1,
   input wire [BRAM_DW-1:0] bram_wrdata1,      

   input wire  bram_en_a1,  
   input wire  bram_en_b1,  
   input wire  bram_en_c1,  

   input wire  bram_we_a1,
   input wire  bram_we_b1,
   input wire  bram_we_c1,

   output wire [BRAM_DW-1:0] bram_rddata_a1,  
   output wire [BRAM_DW-1:0] bram_rddata_b1,    
   output wire [BRAM_DW-1:0] bram_rddata_c1,

   output wire [BRAM_DW*2-1:0] debug_bram_rddata_a2,
   output wire [BRAM_DW*2-1:0] debug_bram_rddata_b2,
   output wire [BRAM_DW*4-1:0] debug_bram_wrdata_c2,
   
   output wire [BRAM_AW-2:0] debug_bram_addr_a2,
   output wire [BRAM_AW-2:0] debug_bram_addr_b2,
   output wire [BRAM_AW-2:0] debug_bram_addr_c2,

   output wire [N-1:0][W-1:0]   debug_a_in,
   output wire [N-1:0][2*W-1:0] debug_c_out,  
   output wire [N-1:0][N-1:0][2*W-1:0] debug_c_outs,
   output wire [N-1:0][N-1:0][W-1:0] debug_a_data,  
   output wire debug_C_gather_done,
   output wire debug_start_cal,

   output wire [DATA_A_SIZE_Y-1:0][N-1:0][2*W-1:0] debug_C_buffer,
   output wire [N-1:0][N-1:0][W-1:0] debug_B_buffer

);

    always @(posedge user_clk or negedge user_resetn) begin
        if (!user_resetn) begin
            usr_irq_req <= {C_NUM_USR_IRQ{1'b0}}; // 保持输出为0
        end else begin
            usr_irq_req <= {C_NUM_USR_IRQ{1'b0}}; // 始终为0
        end
    end
    // 忽略 usr_irq_ack

    //For inner connection:
    wire bram_we_a2;
    wire bram_clk_a2;
    wire [BRAM_AW-2:0] bram_addr_a2;        //BRAM_AW = 9bit, 128bit Data
    wire [BRAM_DW*2-1:0] bram_wrdata_a2;
    wire [BRAM_DW*2-1:0] bram_rddata_a2;

    wire bram_we_b2,bram_clk_b2;
    wire [BRAM_AW-2:0] bram_addr_b2;        //BRAM_AW = 9bit, 128bit Data
    wire [BRAM_DW*2-1:0] bram_wrdata_b2;
    wire [BRAM_DW*2-1:0] bram_rddata_b2;
    
    wire bram_we_c2,bram_clk_c2;
    (* mark_debug = "true" *)wire [BRAM_AW-3:0] bram_addr_c2;        //BRAM_AW = 8bit, 256bit Data
    (* mark_debug = "true" *)wire [BRAM_DW*4-1:0] bram_wrdata_c2;
    wire [BRAM_DW*4-1:0] bram_rddata_c2;

    wire start;
    wire Finish;

    Matrix_Multiply#(
    .W(W),.N(N),.BRAM_W(BRAM_DW),.BRAM_AW(BRAM_AW),
    .DATA_A_SIZE_X(DATA_A_SIZE_X), .DATA_A_SIZE_Y(DATA_A_SIZE_Y), 
    .DATA_B_SIZE_X(DATA_B_SIZE_X), .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
    )  mm 
    (
        //system
        .clk(user_clk),
        .rst(!user_resetn),

        //bram interface 
        .bram_clk_a(bram_clk_a2),
        .bram_we_a(bram_we_a2),
        .bram_addr_a(bram_addr_a2),
        .bram_wrdata_a(bram_wrdata_a2),
        .bram_rddata_a(bram_rddata_a2),

        .bram_clk_b(bram_clk_b2),
        .bram_we_b(bram_we_b2),
        .bram_addr_b(bram_addr_b2),
        .bram_wrdata_b(bram_wrdata_b2),
        .bram_rddata_b(bram_rddata_b2),

        .bram_clk_c(bram_clk_c2),
        .bram_we_c(bram_we_c2),
        .bram_addr_c(bram_addr_c2),
        .bram_wrdata_c(bram_wrdata_c2),
        .bram_rddata_c(bram_rddata_c2),

        //for control 
        .start(start),
        .Finish(Finish),

        //for debugging 
        .debug_start_cal(debug_start_cal),
        .debug_C_gather_done(debug_C_gather_done),
        .debug_a_data(debug_a_data),
        .debug_c_outs(debug_c_outs),
        .debug_c_out(debug_c_out),
        .debug_a_in(debug_a_in) ,
        .debug_C_buffer(debug_C_buffer),
        .debug_B_buffer(debug_B_buffer) 
    );
   
    Usr_control Usr_control_i (
       .aresetn(user_resetn),
       .aclk(user_clk),
       .start(start),
       .Finish(Finish),

       .awvalid(s_axil_awvalid),
       .awready(s_axil_awready),
       .awaddr(s_axil_awaddr),
       .wvalid(s_axil_wvalid),
       .wready(s_axil_wready),
       .wdata(s_axil_wdata),
       .wstrb(s_axil_wstrb),
       .bresp(s_axil_bresp),
       .bvalid(s_axil_bvalid),
       .bready(s_axil_bready),
       .araddr(s_axil_araddr),
       .arvalid(s_axil_arvalid),
       .arready(s_axil_arready),
       .rdata(s_axil_rdata),
       .rresp(s_axil_rresp),
       .rvalid(s_axil_rvalid),
       .rready(s_axil_rready)
   );

    blk_mem_gen_0 Bram_A (
      .clka(bram_clk1),    // input wire clka
      .ena(bram_en_a1),
      .wea(bram_we_a1),      // input wire [0 : 0] wea
      .addra(bram_addr1),  // input wire [9 : 0] addra
      .dina(bram_wrdata1),    // input wire [63 : 0] dina
      .douta(bram_rddata_a1),  // output wire [63 : 0] douta
      .clkb(bram_clk_a2),    // input wire clkb
      .enb(1),
      .web(bram_we_a2),      // input wire [0 : 0] web
      .addrb(bram_addr_a2),  // input wire [8 : 0] addrb
      .dinb(bram_wrdata_a2),    // input wire [127 : 0] dinb
      .doutb(bram_rddata_a2)  // output wire [127 : 0] doutb
    );   

    blk_mem_gen_0 Bram_B (
      .clka(bram_clk1),    // input wire clka
      .ena(bram_en_b1),
      .wea(bram_we_b1),      // input wire [0 : 0] wea
      .addra(bram_addr1),  // input wire [9 : 0] addra
      .dina(bram_wrdata1),    // input wire [63 : 0] dina
      .douta(bram_rddata_b1),  // output wire [63 : 0] douta
      .clkb(bram_clk_b2),    // input wire clkb
      .enb(1),
      .web(bram_we_b2),      // input wire [0 : 0] web
      .addrb(bram_addr_b2),  // input wire [8 : 0] addrb
      .dinb(bram_wrdata_b2),    // input wire [127 : 0] dinb
      .doutb(bram_rddata_b2)  // output wire [127 : 0] doutb
    );   

    blk_mem_gen_1 Bram_C (
      .clka(bram_clk1),    // input wire clka
      .ena(bram_en_c1),
      .wea(bram_we_c1),      // input wire [0 : 0] wea
      .addra(bram_addr1),  // input wire [9 : 0] addra
      .dina(bram_wrdata1),    // input wire [63 : 0] dina
      .douta(bram_rddata_c1),  // output wire [63 : 0] douta
      .clkb(bram_clk_c2),    // input wire clkb
      .enb(1),
      .web(bram_we_c2),      // input wire [0 : 0] web
      .addrb(bram_addr_c2),  // input wire [7 : 0] addrb
      .dinb(bram_wrdata_c2),    // input wire [255 : 0] dinb
      .doutb(bram_rddata_c2)  // output wire [255 : 0] doutb
    );   


  assign debug_bram_rddata_a2 = bram_rddata_a2;
  assign debug_bram_rddata_b2 = bram_rddata_b2;
  assign debug_bram_wrdata_c2 = bram_wrdata_c2;


  assign debug_bram_addr_a2 = bram_addr_a2;
  assign debug_bram_addr_b2 = bram_addr_b2;
  assign debug_bram_addr_c2 = bram_addr_c2;

  

endmodule
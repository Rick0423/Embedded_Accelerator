`timescale 1ps / 1ps

module tb_xdma_app;

  // Parameters
  parameter C_M_AXI_ID_WIDTH = 4;
  parameter C_DATA_WIDTH = 64;

  // Inputs
  reg [31:0] s_axil_awaddr;
  reg s_axil_awvalid;
  wire s_axil_awready;
  reg [31:0] s_axil_wdata;
  reg [3:0] s_axil_wstrb;
  reg s_axil_wvalid;
  wire s_axil_wready;
  wire [1:0] s_axil_bresp;
  wire s_axil_bvalid;
  reg s_axil_bready;
  reg [31:0] s_axil_araddr;
  reg s_axil_arvalid;
  wire s_axil_arready;
  wire [31:0] s_axil_rdata;
  wire [1:0] s_axil_rresp;
  wire s_axil_rvalid;
  reg s_axil_rready;

  reg [C_M_AXI_ID_WIDTH-1:0] s_axi_awid;
  reg [63:0] s_axi_awaddr;
  reg [7:0] s_axi_awlen;
  reg [2:0] s_axi_awsize;
  reg [1:0] s_axi_awburst;
  reg s_axi_awvalid;
  wire s_axi_awready;
  reg [C_DATA_WIDTH-1:0] s_axi_wdata;
  reg [(C_DATA_WIDTH/8)-1:0] s_axi_wstrb;
  reg s_axi_wlast;
  reg s_axi_wvalid;
  wire s_axi_wready;
  wire [C_M_AXI_ID_WIDTH-1:0] s_axi_bid;
  wire [1:0] s_axi_bresp;
  wire s_axi_bvalid;
  reg s_axi_bready;
  reg [C_M_AXI_ID_WIDTH-1:0] s_axi_arid;
  reg [63:0] s_axi_araddr;
  reg [7:0] s_axi_arlen;
  reg [2:0] s_axi_arsize;
  reg [1:0] s_axi_arburst;
  reg s_axi_arvalid;
  wire s_axi_arready;
  wire [C_M_AXI_ID_WIDTH-1:0] s_axi_rid;
  wire [C_DATA_WIDTH-1:0] s_axi_rdata;
  wire [1:0] s_axi_rresp;
  wire s_axi_rlast;
  wire s_axi_rvalid;
  reg s_axi_rready;

  reg user_resetn;
  reg sys_rst_n;
  reg user_clk;
  reg user_lnk_up;
  wire [0:0] usr_irq_req;
  reg [0:0] usr_irq_ack;
  wire [3:0] leds;


  //   debug signals 
  wire[63:0] debug_bram_rddata_a;
  wire[63:0] debug_bram_rddata_b;
  wire[63:0] debug_bram_rddata_c;

  // Instantiate the Unit Under Test (UUT)
  xdma_app uut (
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
    .s_axi_awid(s_axi_awid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awlen(s_axi_awlen),
    .s_axi_awsize(s_axi_awsize),
    .s_axi_awburst(s_axi_awburst),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wlast(s_axi_wlast),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bid(s_axi_bid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_arid(s_axi_arid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arlen(s_axi_arlen),
    .s_axi_arsize(s_axi_arsize),
    .s_axi_arburst(s_axi_arburst),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rid(s_axi_rid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rlast(s_axi_rlast),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .user_resetn(user_resetn),
    .sys_rst_n(sys_rst_n),
    .user_clk(user_clk),
    .user_lnk_up(user_lnk_up),
    .usr_irq_req(usr_irq_req),
    .usr_irq_ack(usr_irq_ack),
    .leds(leds),
    .debug_bram_rddata_a(debug_bram_rddata_a),
    .debug_bram_rddata_b(debug_bram_rddata_b),
    .debug_bram_rddata_c(debug_bram_rddata_c)
  );

  // Clock generation
  initial begin
    user_clk = 0;
    forever #5 user_clk = ~user_clk; // 100MHz clock
  end

  // Test sequence
  initial begin
    // Initialize Inputs
    sys_rst_n = 0;
    user_resetn = 0;
    user_lnk_up = 0;
    s_axil_awaddr = 0;
    s_axil_awvalid = 0;
    s_axil_wdata = 0;
    s_axil_wstrb = 0;
    s_axil_wvalid = 0;
    s_axil_bready = 0;
    s_axil_araddr = 0;
    s_axil_arvalid = 0;
    s_axil_rready = 0;
    s_axi_awid = 0;
    s_axi_awaddr = 0;
    s_axi_awlen = 0;
    s_axi_awsize = 0;
    s_axi_awburst = 0;
    s_axi_awvalid = 0;
    s_axi_wdata = 0;
    s_axi_wstrb = 0;
    s_axi_wlast = 0;
    s_axi_wvalid = 0;
    s_axi_bready = 0;
    s_axi_arid = 0;
    s_axi_araddr = 0;
    s_axi_arlen = 0;
    s_axi_arsize = 0;
    s_axi_arburst = 0;
    s_axi_arvalid = 0;
    s_axi_rready = 0;
    usr_irq_ack = 0;

    // Wait for global reset
    #100;
    sys_rst_n = 1;
    user_resetn = 1;
    user_lnk_up = 1;

    // Write to BRAM A
    s_axi_awaddr = 64'h0000_0000_0000_0000; // Address for BRAM A
    s_axi_awvalid = 1;
    s_axi_wdata = 64'hDEAD_BEEF_CAFE_BABE;
    s_axi_wstrb = 8'hFF;
    s_axi_wvalid = 1;
    s_axi_wlast = 1;
    #10;
    s_axi_awvalid = 0;
    s_axi_wvalid = 0;

    // Read from BRAM A
    s_axi_araddr = 64'h0000_0000_0000_0000; // Address for BRAM A
    s_axi_arvalid = 1;
    #10;
    s_axi_arvalid = 0;
    s_axi_rready = 1;
    #10;
    s_axi_rready = 0;

    // Write to BRAM B
    s_axi_awaddr = 64'h4000_0000_0000_0000; // Address for BRAM B
    s_axi_awvalid = 1;
    s_axi_wdata = 64'h1234_5678_9ABC_DEF0;
    s_axi_wstrb = 8'hFF;
    s_axi_wvalid = 1;
    s_axi_wlast = 1;
    #10;
    s_axi_awvalid = 0;
    s_axi_wvalid = 0;

    // Read from BRAM B
    s_axi_araddr = 64'h4000_0000_0000_0000; // Address for BRAM B
    s_axi_arvalid = 1;
    #10;
    s_axi_arvalid = 0;
    s_axi_rready = 1;
    #10;
    s_axi_rready = 0;

    // Write to BRAM C
    s_axi_awaddr = 64'h8000_0000_0000_0000; // Address for BRAM C
    s_axi_awvalid = 1;
    s_axi_wdata = 64'hFEDC_BA98_7654_3210;
    s_axi_wstrb = 8'hFF;
    s_axi_wvalid = 1;
    s_axi_wlast = 1;
    #10;
    s_axi_awvalid = 0;
    s_axi_wvalid = 0;

    // Read from BRAM C
    s_axi_araddr = 64'h8000_0000_0000_0000; // Address for BRAM C
    s_axi_arvalid = 1;
    #10;
    s_axi_arvalid = 0;
    s_axi_rready = 1;
    #10;
    s_axi_rready = 0;

    // Finish simulation
    #100;
    $finish;
  end

endmodule

//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
//
// Project    : The Xilinx PCI Express DMA 
// File       : xdma_app.v
// Version    : 4.1
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps
module xdma_app #(
  parameter TCQ                         = 1,
  parameter C_M_AXI_ID_WIDTH            = 4,
  parameter PL_LINK_CAP_MAX_LINK_WIDTH  = 1,
  parameter C_DATA_WIDTH                = 64,
  parameter C_M_AXI_DATA_WIDTH          = C_DATA_WIDTH,
  parameter C_S_AXI_DATA_WIDTH          = C_DATA_WIDTH,
  parameter C_S_AXIS_DATA_WIDTH         = C_DATA_WIDTH,
  parameter C_M_AXIS_DATA_WIDTH         = C_DATA_WIDTH,
  parameter C_M_AXIS_RQ_USER_WIDTH      = ((C_DATA_WIDTH == 512) ? 137 : 62),
  parameter C_S_AXIS_CQP_USER_WIDTH     = ((C_DATA_WIDTH == 512) ? 183 : 88),
  parameter C_M_AXIS_RC_USER_WIDTH      = ((C_DATA_WIDTH == 512) ? 161 : 75),
  parameter C_S_AXIS_CC_USER_WIDTH      = ((C_DATA_WIDTH == 512) ?  81 : 33),
  parameter C_S_KEEP_WIDTH              = C_S_AXI_DATA_WIDTH / 32,
  parameter C_M_KEEP_WIDTH              = (C_M_AXI_DATA_WIDTH / 32),
  parameter C_XDMA_NUM_CHNL             = 2
)
(

  // AXI Lite Master Interface connections
  input  wire  [31:0] s_axil_awaddr,
  input  wire         s_axil_awvalid,
  output wire         s_axil_awready,
  input  wire  [31:0] s_axil_wdata,
  input  wire   [3:0] s_axil_wstrb,
  input  wire         s_axil_wvalid,
  output wire         s_axil_wready,
  output wire   [1:0] s_axil_bresp,
  output wire         s_axil_bvalid,
  input  wire         s_axil_bready,
  input  wire  [31:0] s_axil_araddr,
  input  wire         s_axil_arvalid,
  output wire         s_axil_arready,
  output wire  [31:0] s_axil_rdata,
  output wire   [1:0] s_axil_rresp,
  output wire         s_axil_rvalid,
  input  wire         s_axil_rready,


//VU9P_TUL_EX_String= FALSE

  // AXI Memory Mapped interface
  input  wire  [C_M_AXI_ID_WIDTH-1:0] s_axi_awid,
  input  wire  [64-1:0] s_axi_awaddr,
  input  wire   [7:0] s_axi_awlen,
  input  wire   [2:0] s_axi_awsize,
  input  wire   [1:0] s_axi_awburst,
  input  wire         s_axi_awvalid,
  output wire         s_axi_awready,
  input  wire [C_M_AXI_DATA_WIDTH-1:0]        s_axi_wdata,
  input  wire [(C_M_AXI_DATA_WIDTH/8)-1:0]    s_axi_wstrb,
  input  wire         s_axi_wlast,
  input  wire         s_axi_wvalid,
  output wire         s_axi_wready,
  output reg [C_M_AXI_ID_WIDTH-1:0]          s_axi_bid,
  output wire   [1:0] s_axi_bresp,
  output wire         s_axi_bvalid,
  input  wire         s_axi_bready,
  input  wire [C_M_AXI_ID_WIDTH-1:0]          s_axi_arid,
  input  wire  [64-1:0] s_axi_araddr,
  input  wire   [7:0] s_axi_arlen,
  input  wire   [2:0] s_axi_arsize,
  input  wire   [1:0] s_axi_arburst,
  input  wire         s_axi_arvalid,
  output wire         s_axi_arready,
  output reg   [C_M_AXI_ID_WIDTH-1:0]        s_axi_rid,
  output wire   [C_M_AXI_DATA_WIDTH-1:0]      s_axi_rdata,
  output wire   [1:0] s_axi_rresp,
  output wire         s_axi_rlast,
  output wire         s_axi_rvalid,
  input  wire         s_axi_rready,

  // System IO signals
  input  wire         user_resetn,
  input  wire         sys_rst_n,
 
  input  wire         user_clk,
  input  wire         user_lnk_up,
  output wire       [1 -1:0] usr_irq_req,
  input  wire   [1 -1:0] usr_irq_ack,
  output wire   [3:0] leds

);

  // wire/reg declarations
  wire            sys_reset;
  reg  [25:0]     user_clk_heartbeat;

  //Bram IO signals 
  wire bram_clk_a;
  wire bram_en_a; 
  wire [7:0] bram_we_a; 
  wire [9:0] real_bram_addr_a;
  wire [63:0] bram_wrdata_a;
  wire [63:0] bram_rddata_a;

  wire bram_clk_b;
  wire bram_en_b; 
  wire [7:0] bram_we_b; 
  wire [9:0] real_bram_addr_b;
  wire [63:0] bram_wrdata_b;
  wire [63:0] bram_rddata_b;

  wire bram_clk_c;
  wire bram_en_c; 
  wire [7:0] bram_we_c; 
  wire [9:0] real_bram_addr_c;
  wire [63:0] bram_wrdata_c;
  wire [63:0] bram_rddata_c;

  wire [12:0] bram_addr_a;
  wire [12:0] bram_addr_b;
  wire [12:0] bram_addr_c;


  // The sys_rst_n input is active low based on the core configuration
  assign sys_resetn = sys_rst_n;

  // Create a Clock Heartbeat
  always @(posedge user_clk) begin
    if(!sys_resetn) begin
      user_clk_heartbeat <= #TCQ 26'd0;
    end else begin
      user_clk_heartbeat <= #TCQ user_clk_heartbeat + 1'b1;
    end
  end

  // LEDs for observation
  assign leds[0] = sys_resetn;
  assign leds[1] = user_resetn;
  assign leds[2] = user_lnk_up;
  assign leds[3] = user_clk_heartbeat[25];


  wire bram_clk;    // input wire clka
  wire bram_en_a;     // input wire ena
  wire bram_we_a      ;// input wire [0 : 0] wea
  wire bram_en_b;     // input wire ena
  wire bram_we_b      ;// input wire [0 : 0] wea
  wire bram_en_c;     // input wire ena
  wire bram_we_c      ;// input wire [0 : 0] wea

  wire [12:0]bram_addr  ;// input wire [9 : 0] addra
  wire [63:0]bram_wrdata;    // input wire [63 : 0] dina
  wire [63:0]bram_rddata ; // output wire [63 : 0] douta
  wire [63:0]bram_rddata_a ; // output wire [63 : 0] douta
  wire [63:0]bram_rddata_b ; // output wire [63 : 0] douta
  wire [63:0]bram_rddata_c ; // output wire [63 : 0] douta

  wire [1:0] s_axi_waddr_val;
  wire [1:0] s_axi_raddr_val;

  assign s_axi_waddr_val = s_axi_awaddr[14:13]; 
  assign s_axi_raddr_val = s_axi_araddr[14:13]; 

  axi_bram_ctrl_0 AXI_BRAM_A (
    .s_axi_aclk(user_clk),        // input wire s_axi_aclk
    .s_axi_aresetn(user_resetn),  // input wire s_axi_aresetn
    .s_axi_awaddr(s_axi_awaddr[12:0]),    // input wire [12 : 0] s_axi_awaddr
    .s_axi_awlen(s_axi_awlen),      // input wire [7 : 0] s_axi_awlen
    .s_axi_awsize(s_axi_awsize),    // input wire [2 : 0] s_axi_awsize
    .s_axi_awburst(s_axi_awburst),  // input wire [1 : 0] s_axi_awburst
    //.s_axi_awlock(s_axi_awlock),    // input wire s_axi_awlock
    //.s_axi_awcache(s_axi_awcache),  // input wire [3 : 0] s_axi_awcache
    //.s_axi_awprot(s_axi_awprot),    // input wire [2 : 0] s_axi_awprot
    .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
    .s_axi_awready(s_axi_awready),  // output wire s_axi_awready
    .s_axi_wdata(s_axi_wdata),      // input wire [63 : 0] s_axi_wdata
    .s_axi_wstrb(s_axi_wstrb),      // input wire [7 : 0] s_axi_wstrb
    .s_axi_wlast(s_axi_wlast),      // input wire s_axi_wlast
    .s_axi_wvalid(s_axi_wvalid),    // input wire s_axi_wvalid
    .s_axi_wready(s_axi_wready),    // output wire s_axi_wready
    .s_axi_bresp(s_axi_bresp),      // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid(s_axi_bvalid),    // output wire s_axi_bvalid
    .s_axi_bready(s_axi_bready),    // input wire s_axi_bready
    .s_axi_araddr(s_axi_araddr[12:0]),    // input wire [12 : 0] s_axi_araddr
    .s_axi_arlen(s_axi_arlen),      // input wire [7 : 0] s_axi_arlen
    .s_axi_arsize(s_axi_arsize),    // input wire [2 : 0] s_axi_arsize
    .s_axi_arburst(s_axi_arburst),  // input wire [1 : 0] s_axi_arburst
    //.s_axi_arlock(s_axi_arlock),    // input wire s_axi_arlock
    //.s_axi_arcache(s_axi_arcache),  // input wire [3 : 0] s_axi_arcache
    //.s_axi_arprot(s_axi_arprot),    // input wire [2 : 0] s_axi_arprot
    .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
    .s_axi_arready(s_axi_arready),  // output wire s_axi_arready
    .s_axi_rdata(s_axi_rdata),      // output wire [63 : 0] s_axi_rdata
    .s_axi_rresp(s_axi_rresp),      // output wire [1 : 0] s_axi_rresp
    .s_axi_rlast(s_axi_rlast),      // output wire s_axi_rlast
    .s_axi_rvalid(s_axi_rvalid),    // output wire s_axi_rvalid
    .s_axi_rready(s_axi_rready),    // input wire s_axi_rready
    .bram_rst_a(bram_rst),        // output wire bram_rst_a
    .bram_clk_a(bram_clk),        // output wire bram_clk_a
    .bram_en_a(bram_en),          // output wire bram_en_a
    .bram_we_a(bram_we),          // output wire [7 : 0] bram_we_a
    .bram_addr_a(bram_addr),      // output wire [12 : 0] bram_addr_a
    .bram_wrdata_a(bram_wrdata),  // output wire [63 : 0] bram_wrdata_a
    .bram_rddata_a(bram_rddata)  // input wire [63 : 0] bram_rddata_a
  );


  assign bram_rddata =  (s_axi_raddr_val == 2'b00) ? bram_rddata_a : (s_axi_raddr_val == 2'b01) ? bram_rddata_b : bram_rddata_c ;

  assign bram_en_a   =    ((s_axi_raddr_val == 2'b00) || (s_axi_waddr_val == 2'b00) ) ? bram_en : 0;
  assign bram_en_b   =    ((s_axi_raddr_val == 2'b01) || (s_axi_waddr_val == 2'b01) ) ? bram_en : 0;
  assign bram_en_c   =    ((s_axi_raddr_val == 2'b11) || (s_axi_waddr_val == 2'b11) ) ? bram_en : 0;

  assign bram_we_a   =  (s_axi_waddr_val == 2'b00) ? bram_we :0 ;
  assign bram_we_b   =  (s_axi_waddr_val == 2'b01) ? bram_we :0 ;
  assign bram_we_c   =  (s_axi_waddr_val == 2'b11) ? bram_we :0 ;



  Usr_Logic Usr_Logic_i ( 
  //AXI-Lite Logic
    .s_axil_awaddr  (s_axil_awaddr[31:0]),
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awready (s_axil_awready),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wstrb   (s_axil_wstrb),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wready  (s_axil_wready),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bready  (s_axil_bready),
    .s_axil_araddr  (s_axil_araddr[31:0]),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_arready (s_axil_arready),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rready  (s_axil_rready),
    .user_clk       (user_clk),
    .user_resetn    (user_resetn),
    .usr_irq_req    (usr_irq_req),
    .usr_irq_ack    (usr_irq_ack),

  //Bram interface for Computing part

  //Common part 
    .bram_clk1(bram_clk),
    .bram_addr1(bram_addr[12:3]),
    .bram_wrdata1(bram_wrdata),

  //individual part
    .bram_en_a1(bram_en_a),
    .bram_en_b1(bram_en_b),
    .bram_en_c1(bram_en_c),

    .bram_we_a1(bram_we_a),
    .bram_we_b1(bram_we_b),
    .bram_we_c1(bram_we_c),

    .bram_rddata_a1(bram_rddata_a),
    .bram_rddata_b1(bram_rddata_b),
    .bram_rddata_c1(bram_rddata_c)
  );



endmodule

module tb_scatter_a();

    // Testbench parameters
    parameter W = 8;
    parameter N = 16;
    parameter BRAM_W = 128;
    parameter BRAM_AW = 9;
    parameter DATA_A_SIZE_X = 64;
    parameter DATA_A_SIZE_Y = 64;
    parameter DATA_B_SIZE_X = 64;
    parameter DATA_B_SIZE_Y = 64;

    // Testbench signals
    reg rst;
    reg clk;
    reg start_cal;
    
    wire bram_clk_a;
    wire bram_we_a;
    wire [BRAM_AW-1:0] bram_addr_a;
    wire [BRAM_W-1:0] bram_rddata_a;
    reg [BRAM_W-1:0] bram_wrdata_a;

    wire [N-1:0][W-1:0] a_in;
    wire col_cal_done;

    // Instantiate the scatter_a module
    scatter_a #(
        .W(W),
        .N(N),
        .BRAM_W(BRAM_W),
        .BRAM_AW(BRAM_AW),
        .DATA_A_SIZE_X(DATA_A_SIZE_X),
        .DATA_A_SIZE_Y(DATA_A_SIZE_Y),
        .DATA_B_SIZE_X(DATA_B_SIZE_X),
        .DATA_B_SIZE_Y(DATA_B_SIZE_Y)
    ) uut (
        .rst(rst),
        .clk(clk),
        .start_cal(start_cal),
        .bram_clk_a(bram_clk_a),
        .bram_we_a(bram_we_a),
        .bram_addr_a(bram_addr_a),
        .bram_wrdata_a(bram_wrdata_a),
        .bram_rddata_a(bram_rddata_a),
        .a_in(a_in),
        .col_cal_done(col_cal_done)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    blk_mem_gen_0 Bram_A (
      .clka(),    // input wire clka
      .ena(),
      .wea(),      // input wire [0 : 0] wea
      .addra(),  // input wire [9 : 0] addra
      .dina(),    // input wire [63 : 0] dina
      .douta(),  // output wire [63 : 0] douta
      .clkb(bram_clk_a),    // input wire clkb
      .enb(1),
      .web(bram_we_a),      // input wire [0 : 0] web
      .addrb(bram_addr_a),  // input wire [8 : 0] addrb
      .dinb(bram_wrdata_a),    // input wire [127 : 0] dinb
      .doutb(bram_rddata_a)  // output wire [127 : 0] doutb
    ); 


    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start_cal = 0;

        // Apply reset
        #10 rst = 0;

        // Start calculation
        #10 start_cal = 1;

        // Wait for some time
        #100 start_cal = 0;

        // Monitor results
        #500;
        start_cal =1 ;
        #10 ;
        start_cal = 0;
        $display("BRAM Address: %h, BRAM Read Data: %h", bram_addr_a, bram_rddata_a);
        $display("a_in: %h", a_in);
        $display("Column calculation done: %b", col_cal_done);

        // Finish simulation
        #1000 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time = %0t, a_in = %h, col_cal_done = %b, bram_addr_a = %h", $time, a_in, col_cal_done, bram_addr_a);
    end

endmodule

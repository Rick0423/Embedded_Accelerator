module tb_scatter_b;

    // Testbench parameters
    parameter W = 8;
    parameter N = 16;
    parameter BRAM_W = 128;
    parameter BRAM_AW = 10;
    parameter DATA_A_SIZE_X = 64;
    parameter DATA_A_SIZE_Y = 64;
    parameter DATA_B_SIZE_X = 64;
    parameter DATA_B_SIZE_Y = 64;

    // Testbench signals
    reg rst;
    reg clk;
    reg load;
    wire bram_clk_b;
    wire bram_we_b;
    wire [BRAM_AW-1:0] bram_addr_b;
    reg [BRAM_W-1:0] bram_rddata_b; // Assuming this is a read from BRAM
    reg [BRAM_W-1:0] bram_wrdata_b;
    wire [N-1:0][W-1:0] b_ins;
    wire stationaryCtrl;
    wire load_done;

    wire [2:0]debug_state;
    wire [N-1:0]debug_in_block_cnt;
    wire [DATA_B_SIZE_X/N-1:0]debug_col_cnt;
    wire [DATA_B_SIZE_X/N-1:0]debug_row_cnt;
    wire [N-1:0][N-1:0][W-1:0]  debug_buffer;


    // Instantiate the module under test
    scatter_b #(
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
        .load(load),
        .bram_clk_b(bram_clk_b),
        .bram_we_b(bram_we_b),
        .bram_addr_b(bram_addr_b),
        .bram_wrdata_b(bram_wrdata_b),
        .bram_rddata_b(bram_rddata_b),
        .b_ins(b_ins),
        .stationaryCtrl(stationaryCtrl),
        .load_done(load_done),
        .debug_state(debug_state),
        .debug_in_block_cnt(debug_in_block_cnt),
        .debug_col_cnt(debug_col_cnt),
        .debug_row_cnt(debug_row_cnt),
        .debug_buffer(debug_buffer)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Clock period of 10 time units
    end

    // Stimulus process
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        load = 0;

        // Apply reset
        rst = 1;
        #10 rst = 0;  // Release reset after 10 time units

        // Load data and drive the load signal
        #10 load = 1; // Activate load signal at time 20
        #10 load = 0; // Deactivate load after one clock cycle

        // Apply some values to bram_rddata_b for simulation purposes
        // For example, we can assign values to simulate the BRAM data
        bram_rddata_b = 128'h123456789abcdef0123456789abcdef0; // Example 128-bit data

        // Wait for a few cycles to observe outputs
        #100;
        
        // Test with a different load signal
        load = 0;
        #10 load = 0;

        // Observe the state changes and output signals
        #500;
        load =1 ;
        #10
        load =0 ;

        #1000;

        // Finish simulation
        $finish;
    end

    // Monitor output signals
    initial begin
        $monitor("At time %t, rst = %b, load = %b, bram_clk_b = %b, bram_we_b = %b, bram_addr_b = %h, bram_rddata_b = %h, b_ins = %h, stationaryCtrl = %b, load_done = %b",
                 $time, rst, load, bram_clk_b, bram_we_b, bram_addr_b, bram_rddata_b, b_ins, stationaryCtrl, load_done);
    end

endmodule

module tb_PE;

    // Parameters
    parameter W = 8;  // Width of the inputs and outputs

    // Testbench signals
    logic clk, rst, stationaryCtrl;
    logic [W-1:0] a_in, b_in;
    logic [W-1:0] a_out, c_out, debug_a_data;
    logic overflow;

    // Instantiate the PE module
    PE #(
        .W(W)
    ) uut (
        .clk(clk),
        .rst(rst),
        .stationaryCtrl(stationaryCtrl),
        .a_in(a_in),
        .b_in(b_in),
        .a_out(a_out),
        .c_out(c_out),
        .overflow(overflow),
        .debug_a_data(debug_a_data)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 10 ns period, 50 MHz clock
    end

    // Stimulus block
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        stationaryCtrl = 0;
        a_in = 0;
        b_in = 0;

        // Apply reset
        rst = 1;
        #10;
        rst = 0;

        // Test 1: Normal operation without overflow
        a_in = 8'h10;  // 16 in decimal
        b_in = 8'h04;  // 4 in decimal
        stationaryCtrl = 1;  // Apply stationary mode for a_in
        #10;
        stationaryCtrl = 0;  // End stationary mode

        // Test 2: Check overflow condition
        a_in = 8'h10;  // -128 in decimal (two's complement)
        b_in = 8'h20;  // -128 in decimal (two's complement)
        stationaryCtrl = 1;
        #10;
        stationaryCtrl = 0;

        // Test 3: Test with another set of inputs
        a_in = 8'h08;  // 127 in decimal
        b_in = 8'h02;  // 2 in decimal
        stationaryCtrl = 1;
        #10;
        stationaryCtrl = 0;

        // Test 4: Test with zero inputs
        a_in = 8'h01;  // 0 in decimal
        b_in = 8'h20;  // 0 in decimal  
        stationaryCtrl = 1;
        #10;
        stationaryCtrl = 0;

        // Finish the simulation
        $finish;
    end

    // Monitor the outputs
    initial begin
        $monitor("Time = %0t | a_in = %h, b_in = %h, a_out = %h, c_out = %h, overflow = %b, debug_a_data = %h",
                 $time, a_in, b_in, a_out, c_out, overflow, debug_a_data);
    end

endmodule

`timescale 10ns / 1ps

module tb_PE_array;

parameter W = 8;
parameter N = 16;

reg [N-1:0][W-1:0] a_in;
reg [N-1:0][W-1:0] b_in;
wire [N-1:0][2*W-1:0] c_out;
reg [N-1:0][2*W-1:0] c_in;
reg clk;
reg rst;
reg stationaryCtrl;

wire [N-1:0][N-1:0][W-1:0] debug_a_ins;
wire [N-1:0][N-1:0][W-1:0] debug_a_outs;
wire [N-1:0][N-1:0][2*W-1:0] debug_c_outs;
wire [N-1:0][N-1:0][W-1:0] debug_a_data;
// Instantiate the PE_array module
PE_array #(
    .W(W),
    .N(N)
) uut (
    .a_in(a_in),
    .b_in(b_in),
    .c_out(c_out),
    .c_in(c_in),
    .clk(clk),
    .rst(rst),
    .stationaryCtrl(stationaryCtrl),
    .debug_a_data(debug_a_data),
    .debug_a_ins(debug_a_ins),
    .debug_a_outs(debug_a_outs),
    .debug_c_outs(debug_c_outs)
);

// Clock generation
initial begin
    clk = 0;
    forever #10 clk = ~clk; // 10ns clock period
end

// Test procedure
initial begin
    rst = 1; // Assert reset
    #20;      // Wait for a few clock cycles
    rst = 0; // Deassert reset
    stationaryCtrl = 1;
    c_in = '{
        8'h06, 8'h02, 8'h04, 8'h03,
        8'h07, 8'h08, 8'h03, 8'h02,
        8'h01, 8'h04, 8'h09, 8'h02,
        8'h01, 8'h02, 8'h03, 8'h03
    };
    b_in = 0; 
    // Initialize inputs
    a_in = '{
        8'h06, 8'h02, 8'h04, 8'h03,
        8'h07, 8'h08, 8'h03, 8'h02,
        8'h01, 8'h04, 8'h09, 8'h02,
        8'h01, 8'h02, 8'h03, 8'h03
    };
    repeat (N-1) begin
        #20; // Wait for one clock cycle
        // Update inputs every cycle
        a_in += 1 ;
    end
    #20;
    stationaryCtrl =0 ;
    b_in = '{
        8'h01, 8'h01, 8'h01, 8'h05,
        8'h01, 8'h01, 8'h01, 8'h01,
        8'h01, 8'h02, 8'h03, 8'h04,
        8'h01, 8'h01, 8'h01, 8'h01
    };
    repeat (N-1) begin
        #20; // Wait for one clock cycle
        // Update inputs every cycle
        for (int i = 0; i < N; i++) begin
            b_in[i] = b_in[i] + 1; // Increment each byte
        end
    end

    // Finish the simulation
    $finish;
end 
endmodule
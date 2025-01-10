module PE #(
    parameter W = 8
)
(
    input  logic clk,rst,stationaryCtrl,
    input  logic signed [W-1:0] a_in,
    input  logic signed [W-1:0] b_in,
    output logic signed [W-1:0]a_out,
    output logic signed [2*W-1:0]c_out,

    output logic signed [W-1:0] debug_a_data
);

// generate input Logic 
    reg signed [W-1:0] a_data; // Systolic   (1,0,1)
    assign debug_a_data = a_data;
    //a input stationary 
    reg signed [W-1:0] r_a_input;
    always @(posedge clk) begin 
        if(rst) r_a_input<=0;
        else if (stationaryCtrl) r_a_input <= a_in;
        else r_a_input <= r_a_input;
    end
    assign a_out = r_a_input ;
    assign a_data = r_a_input ;

// generate Compute Logic 
    assign c_out = a_data * b_in ;

//generate output Logic 
    
endmodule

//module PE #(
//    parameter W = 8
//)
//(
//    input logic clk, rst, stationaryCtrl,
//    input logic [W-1:0] a_in,
//    input logic [W-1:0] b_in,
//    output logic [W-1:0] a_out,
//    output logic [W-1:0] c_out,
//    output logic overflow,
//
//    output logic [W-1:0] debug_a_data
//);
//
//// generate input Logic 
//    logic [W-1:0] a_data; // Systolic   (1,0,1)
//    assign debug_a_data = a_data;
//    //a input stationary 
//    always @(posedge clk) begin 
//        if(rst) 
//            a_data <= 0;
//        else if (stationaryCtrl) 
//            a_data <= a_in;
//        else 
//            a_data <= a_data;
//    end
//    assign a_out = a_data;
//
////// generate Compute Logic 
//    logic [2*W-1:0] compute_result;
//    // 计算 a_data 和 b_in 的乘积
//    assign compute_result = a_data * b_in;
//
//    // 判断是否溢出：有符号数乘法的溢出情况
//    assign overflow = (compute_result >= 128) ;
//
//    always @(*) begin
//        if (overflow) begin
//            // 输入为 32 * 16, 结果为 512, 超出 8 位有符号整数的范围
//            // 因此应该输出 8 位有符号整数的最大值或最小值
//            if (compute_result[2*W-1]) // 如果溢出且结果为负
//                c_out = -128; // 输出最小值
//            else
//                c_out = 127; // 输出最大值
//        end else begin
//            c_out = compute_result[W-1:0]; // 正常情况下输出计算结果的低 W 位
//        end
//    end
//
//endmodule
//
module PE_array #(
    parameter W = 8,
    parameter N = 16
)(
    input logic clk, rst, stationaryCtrl,
    input  logic signed [N-1:0][W-1:0] a_in,
    input  logic signed [N-1:0][W-1:0] b_in,
    input  logic signed [N-1:0][2*W-1:0] c_in,
    output logic signed [N-1:0][2*W-1:0] c_out,

    output logic signed [N-1:0][N-1:0][W-1:0] debug_a_ins,
    output logic signed [N-1:0][N-1:0][W-1:0] debug_a_outs,
    output logic signed [N-1:0][N-1:0][2*W-1:0] debug_c_outs,
    output logic signed [N-1:0][N-1:0][W-1:0] debug_a_data
);

    // generate PE elements :
    logic signed [N-1:0][N-1:0][W-1:0] a_ins , a_outs;
    logic signed [N-1:0][N-1:0][2*W-1:0] c_outs;
    assign debug_a_ins = a_ins ;
    assign debug_a_outs = a_outs ;
    assign debug_c_outs = c_outs ;

    generate for (genvar i=0 ;i< N ;i+=1) begin : gen_i
        for (genvar j=0;j<N;j+=1) begin : gen_j
            PE #(.W(W)) pe
                (.a_in(a_ins[i][j]),.a_out(a_outs[i][j]),
                 .b_in(b_in[j]),.c_out(c_outs[i][j]),.debug_a_data(debug_a_data[i][j])
                 ,.clk(clk),.rst(rst),.stationaryCtrl(stationaryCtrl));
        end
    end
    endgenerate

    // generate inter-PE connections :   
            //input_a
    for (genvar m=1;m<N;m+=1) begin : gen_input_ai
        for(genvar n=0 ;n<N;n+=1) begin : gen_input_aj
                assign a_ins[m][n] = a_outs[m-1][n];
        end
    end

    // connection between the PE-Array and outside 
    for(genvar i=0;i<N;i+=1) begin : gen_outside_a 
        assign a_ins[0][i] = a_in[i];
    end
// Optimized Adder Tree for c_out
    for (genvar j = 0; j < N; j = j + 1) begin : gen_c_out
        logic signed [2*W-1:0] sum_level1 [7:0];
        logic signed [2*W-1:0] sum_level2 [3:0];
        logic signed [2*W-1:0] sum_level3 [1:0];
        logic signed [2*W-1:0] final_sum;

        // First level of addition: Pairwise addition
        assign sum_level1[0] = c_outs[j][0] + c_outs[j][1];
        assign sum_level1[1] = c_outs[j][2] + c_outs[j][3];
        assign sum_level1[2] = c_outs[j][4] + c_outs[j][5];
        assign sum_level1[3] = c_outs[j][6] + c_outs[j][7];
        assign sum_level1[4] = c_outs[j][8] + c_outs[j][9];
        assign sum_level1[5] = c_outs[j][10] + c_outs[j][11];
        assign sum_level1[6] = c_outs[j][12] + c_outs[j][13];
        assign sum_level1[7] = c_outs[j][14] + c_outs[j][15];

        // Second level of addition: Adding results from first level
        assign sum_level2[0] = sum_level1[0] + sum_level1[1];
        assign sum_level2[1] = sum_level1[2] + sum_level1[3];
        assign sum_level2[2] = sum_level1[4] + sum_level1[5];
        assign sum_level2[3] = sum_level1[6] + sum_level1[7];

        // Third level of addition: Adding results from second level
        assign sum_level3[0] = sum_level2[0] + sum_level2[1];
        assign sum_level3[1] = sum_level2[2] + sum_level2[3];

        // Final addition: Adding results from third level
        assign final_sum = sum_level3[0] + sum_level3[1];

        // Final output: Adding the initial c_in[j] value
        assign c_out[j] = final_sum ;
    end

endmodule
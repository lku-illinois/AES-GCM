// // Code your design here
module top #(
    parameter int DATA_WIDTH = 128
)(
    input   logic                       clk,
    input   logic                       rst,
    input   logic   [DATA_WIDTH-1:0]    h_i,
    input   logic   [DATA_WIDTH-1:0]    a_i,
  	output  logic   [DATA_WIDTH-1:0]    x_o,
  	output  logic   [DATA_WIDTH-1:0]    compute_hh_o  [DATA_WIDTH]
);
    localparam irreducible_poly = 128'he1000000000000000000000000000000;

    logic   [DATA_WIDTH-1:0]    x_tmp;
    logic   [DATA_WIDTH-1:0]    compute_hh  [DATA_WIDTH];
    logic   LSB;


    always_comb begin 
      	x_tmp = '0;
        compute_hh[0] = h_i;

        for(int i=1; i<DATA_WIDTH; i++) begin
            LSB = compute_hh[i-1][0];
            compute_hh[i] = LSB ? ((compute_hh[i-1] >> 1) ^ irreducible_poly) : (compute_hh[i-1] >> 1);
        end
      
        for(int i=0; i<DATA_WIDTH; i++) begin
          if(a_i[i])
            x_tmp = x_tmp ^ compute_hh[127-i];
        end
    end
	
    assign x_o = x_tmp;
    assign compute_hh_o = compute_hh;
endmodule
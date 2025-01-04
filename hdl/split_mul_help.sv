module split_mul_1 #(
    parameter int DATA__WIDTH = 128,
    parameter int SPLIT_WIDTH = 32 
)(
    input   logic   [SPLIT_WIDTH-1:0]   ha_i,   // H[127:96]
    input   logic   [DATA__WIDTH-1:0]   a_i,
    output  logic   [DATA__WIDTH-1:0]   AA_o,
  	output  logic   [DATA__WIDTH-1:0]   x1_o
);
    localparam irreducible_poly = 128'he1000000000000000000000000000000;

    logic   [DATA__WIDTH-1:0]    x_tmp;
    logic   [DATA__WIDTH-1:0]   compute_aa_1  [SPLIT_WIDTH];
    logic   LSB;

    always_comb begin 
        x_tmp = '0;
        compute_aa_1[0] = a_i;

        for(int i=1 ;i<SPLIT_WIDTH; i++) begin
            LSB = compute_aa_1[i-1][0];
            compute_aa_1[i] = LSB ? ((compute_aa_1[i-1] >> 1) ^ irreducible_poly) : (compute_aa_1[i-1] >> 1);
        end

        for(int i=0; i<SPLIT_WIDTH; i++) begin
          if(ha_i[31-i])
            x_tmp = x_tmp ^ compute_aa_1[i];
        end
    end

    assign AA_o = compute_aa_1[SPLIT_WIDTH-1];
    assign x1_o = x_tmp;

endmodule


module split_mul_2 #(
    parameter int DATA__WIDTH = 128,
    parameter int SPLIT_WIDTH = 32 
)(
    input   logic   [SPLIT_WIDTH-1:0]   hb_i,   // H[95:64]
    input   logic   [DATA__WIDTH-1:0]   a_2,
    output  logic   [DATA__WIDTH-1:0]   AA_o,
    output  logic   [DATA__WIDTH-1:0]   x2_o
);
    localparam irreducible_poly = 128'he1000000000000000000000000000000;

    logic   [DATA__WIDTH-1:0]   compute_aa_2  [SPLIT_WIDTH];
    logic   [DATA__WIDTH-1:0]   x_tmp;
    logic   LSB;

    always_comb begin 
        x_tmp = '0;
        compute_aa_2[0] = a_2[0] ? ((a_2 >> 1) ^ irreducible_poly) : (a_2 >> 1);

        for(int i=1 ;i<SPLIT_WIDTH; i++) begin
            LSB = compute_aa_2[i-1][0];
            compute_aa_2[i] = LSB ? ((compute_aa_2[i-1] >> 1) ^ irreducible_poly) : (compute_aa_2[i-1] >> 1);
        end

        for(int i=0; i<SPLIT_WIDTH; i++) begin
          if(hb_i[31-i])
            x_tmp = x_tmp ^ compute_aa_2[i];
        end
    end

    assign AA_o = compute_aa_2[SPLIT_WIDTH-1];
    assign x2_o = x_tmp;

endmodule

module split_mul_3 #(
    parameter int DATA__WIDTH = 128,
    parameter int SPLIT_WIDTH = 32 
)(
    input   logic   [SPLIT_WIDTH-1:0]   hc_i,   // H[63:32]
    input   logic   [DATA__WIDTH-1:0]   a_3,
    output  logic   [DATA__WIDTH-1:0]   AA_o,
    output  logic   [DATA__WIDTH-1:0]   x3_o
);
    localparam irreducible_poly = 128'he1000000000000000000000000000000;

    logic   [DATA__WIDTH-1:0]   compute_aa_3  [SPLIT_WIDTH];
    logic   [DATA__WIDTH-1:0]   x_tmp;
    logic   LSB;

    always_comb begin 
        x_tmp = '0;
        compute_aa_3[0] = a_3[0] ? ((a_3 >> 1) ^ irreducible_poly) : (a_3 >> 1);

        for(int i=1 ;i<SPLIT_WIDTH; i++) begin
            LSB = compute_aa_3[i-1][0];
            compute_aa_3[i] = LSB ? ((compute_aa_3[i-1] >> 1) ^ irreducible_poly) : (compute_aa_3[i-1] >> 1);
        end

        for(int i=0; i<SPLIT_WIDTH; i++) begin
          if(hc_i[31-i])
            x_tmp = x_tmp ^ compute_aa_3[i];
        end
    end

    assign AA_o = compute_aa_3[SPLIT_WIDTH-1];
    assign x3_o = x_tmp;

endmodule

module split_mul_4 #(
    parameter int DATA__WIDTH = 128,
    parameter int SPLIT_WIDTH = 32 
)(
    input   logic   [SPLIT_WIDTH-1:0]   hd_i,   // H[31:0]
    input   logic   [DATA__WIDTH-1:0]   a_4,
    output  logic   [DATA__WIDTH-1:0]   AA_o,
    output  logic   [DATA__WIDTH-1:0]   x4_o
);
    localparam irreducible_poly = 128'he1000000000000000000000000000000;

    logic   [DATA__WIDTH-1:0]   compute_aa_4  [SPLIT_WIDTH];
    logic   [DATA__WIDTH-1:0]   x_tmp;
    logic   LSB;

    always_comb begin 
        x_tmp = '0;
        compute_aa_4[0] = a_4[0] ? ((a_4 >> 1) ^ irreducible_poly) : (a_4 >> 1);

        for(int i=1 ;i<SPLIT_WIDTH; i++) begin
            LSB = compute_aa_4[i-1][0];
            compute_aa_4[i] = LSB ? ((compute_aa_4[i-1] >> 1) ^ irreducible_poly) : (compute_aa_4[i-1] >> 1);
        end

        for(int i=0; i<SPLIT_WIDTH; i++) begin
          if(hd_i[31-i])
            x_tmp = x_tmp ^ compute_aa_4[i];
        end
    end

    assign AA_o = compute_aa_4[SPLIT_WIDTH-1];
    assign x4_o = x_tmp;

endmodule
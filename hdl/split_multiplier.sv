module split_multiplier #(
    parameter int DATA__WIDTH = 128,
    parameter int SPLIT_WIDTH = 32 
)(
    input   logic                       clk,
    input   logic                       rst,
    input   logic                       flush,
    input   logic   [SPLIT_WIDTH-1:0]   ha_i,   // H[127:96]
    input   logic   [SPLIT_WIDTH-1:0]   hb_i,   // H[95:64]
    input   logic   [SPLIT_WIDTH-1:0]   hc_i,   // H[63:32]
    input   logic   [SPLIT_WIDTH-1:0]   hd_i,   // H[31:0]
    input   logic   [DATA__WIDTH-1:0]   a_i,    // Choose Ai or Zd or Ai^Zd
  	output  logic   [DATA__WIDTH-1:0]   mul_o  // Feeds into Zd
    // output  logic   [DATA__WIDTH-1:0]   AA_o    // Debug
);
    // Multiply output
    logic   [DATA__WIDTH-1:0]   mul1_, mul2_, mul3_, mul4_;
    // computeAA[31] output
    logic   [DATA__WIDTH-1:0]   AAa_, AAb_, AAc_; //, AAd_;
    // Multiply register
    logic   [DATA__WIDTH-1:0]   Za_q, Zb_q, Zc_q, Zd_q;
    logic   [DATA__WIDTH-1:0]   Aa_q, Ab_q, Ac_q;
    // logic   [DATA__WIDTH-1:0]   AA_o;
    
    always_ff @( posedge clk ) begin 
        if(rst || flush) begin
            Za_q <= '0;
            Zb_q <= '0;
            Zc_q <= '0;
            Zd_q <= '0;
        end
        else begin
            Za_q <= mul1_;
            Zb_q <= mul2_ ^ Za_q;
            Zc_q <= mul3_ ^ Zb_q;
            Zd_q <= mul4_ ^ Zc_q;
        end
    end

    always_ff @( posedge clk ) begin 
        if(rst || flush) begin
            Aa_q <= '0;
            Ab_q <= '0;
            Ac_q <= '0;
        end
        else begin
            Aa_q <= AAa_;
            Ab_q <= AAb_;
            Ac_q <= AAc_;
        end
    end

    split_mul_1 #(.DATA__WIDTH(DATA__WIDTH), .SPLIT_WIDTH(SPLIT_WIDTH)) 
    sub_mul1 (
        .ha_i(ha_i),
        .a_i(a_i),
        .AA_o(AAa_),
        .x1_o(mul1_)
    );
    split_mul_2 #(.DATA__WIDTH(DATA__WIDTH), .SPLIT_WIDTH(SPLIT_WIDTH)) 
    sub_mul2 (
        .hb_i(hb_i),
        .a_2(Aa_q),
        .AA_o(AAb_),
        .x2_o(mul2_)
    );
    split_mul_3 #(.DATA__WIDTH(DATA__WIDTH), .SPLIT_WIDTH(SPLIT_WIDTH)) 
    sub_mul3 (
        .hc_i(hc_i),
        .a_3(Ab_q),
        .AA_o(AAc_),
        .x3_o(mul3_)
    );
    split_mul_4 #(.DATA__WIDTH(DATA__WIDTH), .SPLIT_WIDTH(SPLIT_WIDTH)) 
    sub_mul4 (
        .hd_i(hd_i),
        .a_4(Ac_q),
        // .AA_o(AAd_),
        .x4_o(mul4_)
    );

    assign mul_o = Zd_q;
    // assign AA_o = AAd_;

endmodule
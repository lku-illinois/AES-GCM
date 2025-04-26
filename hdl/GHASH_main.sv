// this is the GHASH MODULE with testbench test_GHASH_main.sv
module GHASH_main(
    input   logic               clk,
    input   logic               rst,

    // GHASH CONTROL 
    input   int                 input_num,
    input   logic               start,
    
    input   logic   [127:0]     h1,
    input   logic   [127:0]     h2,
    input   logic   [127:0]     h4,
    input   logic               h_valid,        // all h is valid
    input   logic   [127:0]     A_i,
    output  logic               busy,
    output  logic               error_o,
    output  logic               A_req,
    // MULTIPLIER
  	output  logic   [127:0]     XI_o,  // Zd feed into XI
    output  logic               GHASH_done

);
    logic               flush_mul;
    logic   [31:0]      ha_o;
    logic   [31:0]      hb_o;
    logic   [31:0]      hc_o;
    logic   [31:0]      hd_o;
    logic               xor_o;
    logic   [127:0]     A_o;
    logic   [127:0]     mul_o;
    logic   [127:0]     XI_q;  

    ghash_control ghash_control(
        .clk(clk),
        .rst(rst),
        .input_num(input_num),
        .start(start),
        .busy(busy),
        .flush_mul(flush_mul),
        .error_o(error_o),
        .h1(h1),
        .h2(h2),
        .h4(h4),
        .h_valid(h_valid),
        .ha_o(ha_o),
        .hb_o(hb_o),
        .hc_o(hc_o),
        .hd_o(hd_o),
        .xor_o(xor_o),
        .GHASH_done(GHASH_done),
        .A_req(A_req),
        .A_i(A_i),
        .A_o(A_o),
        .Zd_fb(mul_o)
    );

    split_multiplier #(.DATA__WIDTH(128), .SPLIT_WIDTH(32)) 
    split_multiplier(
        .clk(clk),
        .rst(rst),
        .flush(flush_mul),
        .ha_i(ha_o),
        .hb_i(hb_o),
        .hc_i(hc_o),
        .hd_i(hd_o),
        .a_i(A_o),
        .mul_o(mul_o)
    );

    always_ff @( posedge clk ) begin 
        if(rst || flush_mul) begin
            XI_q <= '0;
        end
        else if(xor_o) begin
            XI_q <= XI_q ^ mul_o;
        end
        else begin
            XI_q <= XI_q;
        end
    end

    assign XI_o = XI_q;

endmodule
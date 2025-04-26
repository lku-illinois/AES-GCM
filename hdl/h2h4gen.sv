module h2h4_gen(
    input   logic               clk,
    input   logic               rst,

    // FROM H1 generation
    input   logic               GHASH_done,
    input   logic   [127:0]     h1_i,
    input   logic               h1_valid_i,

    // TO GHASH CONTROL
    output  logic   [127:0]     h1,
    output  logic   [127:0]     h2,
    output  logic   [127:0]     h4,
    output  logic               h_valid
);
    logic               h1_valid_q, h1_valid_edge;
    logic   [127:0]     h1_q, h2_q, h4_q;
    logic   [127:0]     h2_w, h4_w;
    int                 count;

    always_ff @( posedge clk ) begin 
        if(rst) 
            h1_valid_q <= '0;
        else
            h1_valid_q <= h1_valid_i;
    end   
    assign h1_valid_edge = (~h1_valid_q) && h1_valid_i;   

    always_ff @( posedge clk ) begin 
        if(rst || GHASH_done || ~h1_valid_i) begin
            count <= '0;
        end
        else begin
            count <= count + 1;
        end
    end


    always_ff @( posedge clk ) begin 
        if(rst || GHASH_done) begin
            h1_q <= '0;
        end
        else if(h1_valid_edge) begin
            h1_q <= h1_i;
        end
        else begin
            h1_q <= h1_q;
        end
    end
    always_ff @( posedge clk ) begin 
        if(rst || GHASH_done) begin
            h2_q <= '0;
        end
        else if(count==5) begin
            h2_q <= h2_w;
        end
        else begin
            h2_q <= h2_q;
        end
    end
    always_ff @( posedge clk ) begin 
        if(rst || GHASH_done) begin
            h4_q <= '0;
        end
        else if(count==10) begin
            h4_q <= h4_w;
        end
        else begin
            h4_q <= h4_q;
        end
    end

    split_multiplier h2_gen(
        .clk(clk),
        .rst(rst),
        .flush(h1_valid_edge),
        .ha_i(h1_q[127:96]),
        .hb_i(h1_q[95:64]),
        .hc_i(h1_q[63:32]),
        .hd_i(h1_q[31:0]),
        .a_i(h1_q),
        .mul_o(h2_w)
    );
    split_multiplier h4_gen(
        .clk(clk),
        .rst(rst),
        .flush(count==5),
        .ha_i(h2_q[127:96]),
        .hb_i(h2_q[95:64]),
        .hc_i(h2_q[63:32]),
        .hd_i(h2_q[31:0]),
        .a_i(h2_q),
        .mul_o(h4_w)
    );

    // OUTPUT
    assign h1 = h1_q;
    assign h2 = h2_q;
    assign h4 = h4_q;
    always_ff @( posedge clk ) begin 
        if(rst || GHASH_done) begin
            h_valid <= '0;
        end
        else if(count==10) begin
            h_valid <= '1;
        end
        else begin
            h_valid <= h_valid;
        end
    end
endmodule
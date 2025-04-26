module AES_main(
    input   logic               clk,
    input   logic               rst,
    input   logic   [127:0]     data_in,
    input   logic               start,
    input   int                 data_total,     // total number of 128bit blocks (this is Y0, Y1...) 
    input   int                 AAD_total,
    input   logic   [127:0]     key,
    output  logic               GHASH_start,
    output  logic               AES_first_block_finish,
    output  logic               AES_final_block_finish,
    output  logic   [127:0]     data_out
);
    logic   [4:0] counter; 
    logic   [4:0] data_total_q, AAD_total_q;
    // int           data_total_q;
    logic [127:0] key_s, key_s0, key_s1, key_s2, key_s3, key_s4, key_s5, key_s6, key_s7, key_s8, key_s9;
    logic [127:0] r_data_out, r0_data_out, r1_data_out, r2_data_out, r3_data_out, r4_data_out, r5_data_out, r6_data_out, r7_data_out, r8_data_out, r9_data_out;

    // ------------------------------------------------------
    // ------------------------------------------------------
    // Generate Ending Signals
    // ------------------------------------------------------
    // ------------------------------------------------------   
    always_ff @( posedge clk ) begin 
        if(rst) 
            counter <= '0;
        // else if(counter == (5'b10010 + data_total_q[4:0]))
        //     counter <= '0;
        else if(start)
            counter <= 1;
        else if (counter != 0)
            counter <= counter + 1;
    end
    always_ff @( posedge clk ) begin 
        data_total_q <= data_total[4:0];
        AAD_total_q <= AAD_total[4:0];
    end

    // assign AES_first_block_finish = (counter == 19);
    // assign AES_final_block_finish = (counter == 18+data_total);
    assign GHASH_start            = (counter == (5'b10101 - AAD_total_q[4:0]));
    assign AES_first_block_finish = (counter == 5'b10011);
    assign AES_final_block_finish = (counter == (5'b10010 + data_total_q[4:0]));
    // ------------------------------------------------------
    // ------------------------------------------------------
    // AES ENCRYPTION
    // ------------------------------------------------------
    // ------------------------------------------------------
    assign r_data_out = data_in ^ key_s;

    aes_key_expand_128 a0(
        .clk(clk),
        .rst(rst),
        .key(key),
        .key_s0(key_s),
        .key_s1(key_s0),
        .key_s2(key_s1),
        .key_s3(key_s2),
        .key_s4(key_s3),
        .key_s5(key_s4),
        .key_s6(key_s5),
        .key_s7(key_s6),
        .key_s8(key_s7),
        .key_s9(key_s8),
        .key_s10(key_s9)
    );
    round r0(
        .clk(clk),
        .rst(rst),
        .data_in(r_data_out),
        .key_in(key_s0),
        .data_out(r0_data_out)
    );
    round r1(
        .clk(clk),
        .rst(rst),
        .data_in(r0_data_out),
        .key_in(key_s1),
        .data_out(r1_data_out)
    );
    round r2(
        .clk(clk),
        .rst(rst),
        .data_in(r1_data_out),
        .key_in(key_s2),
        .data_out(r2_data_out)
    );
    round r3(
        .clk(clk),
        .rst(rst),
        .data_in(r2_data_out),
        .key_in(key_s3),
        .data_out(r3_data_out)
    );
    round r4(
        .clk(clk),
        .rst(rst),
        .data_in(r3_data_out),
        .key_in(key_s4),
        .data_out(r4_data_out)
    );
    round r5(
        .clk(clk),
        .rst(rst),
        .data_in(r4_data_out),
        .key_in(key_s5),
        .data_out(r5_data_out)
    );
    round r6(
        .clk(clk),
        .rst(rst),
        .data_in(r5_data_out),
        .key_in(key_s6),
        .data_out(r6_data_out)
    );
    round r7(
        .clk(clk),
        .rst(rst),
        .data_in(r6_data_out),
        .key_in(key_s7),
        .data_out(r7_data_out)
    );
    round r8(
        .clk(clk),
        .rst(rst),
        .data_in(r7_data_out),
        .key_in(key_s8),
        .data_out(r8_data_out)
    );
    last_round r9(
        .clk(clk),
        .rst(rst),
        .data_in(r8_data_out),
        .key_in(key_s9),
        .data_out_last(r9_data_out)
    );

    assign data_out = r9_data_out;

endmodule
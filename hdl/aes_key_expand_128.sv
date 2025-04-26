module aes_key_expand_128(
    input   logic           clk,
    input   logic           rst,
    input   logic   [127:0] key,
    output  logic   [127:0] key_s0,
    output  logic   [127:0] key_s1,
    output  logic   [127:0] key_s2,
    output  logic   [127:0] key_s3,
    output  logic   [127:0] key_s4,
    output  logic   [127:0] key_s5,
    output  logic   [127:0] key_s6,
    output  logic   [127:0] key_s7,
    output  logic   [127:0] key_s8,
    output  logic   [127:0] key_s9,
    output  logic   [127:0] key_s10
);
    localparam             rcon     = 8'h01;
    localparam             rcon2    = 8'h02; 
    localparam             rcon3    = 8'h04;
    localparam             rcon4    = 8'h08;
    localparam             rcon5    = 8'h10;
    localparam             rcon6    = 8'h20;
    localparam             rcon7    = 8'h40; 
    localparam             rcon8    = 8'h80;
    localparam             rcon9    = 8'h1b;
    localparam             rcon10   = 8'h36;	

    localparam logic [7:0] sbox_mem [0:255] = '{
        8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5,
        8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76,
        8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0,
        8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0,
        8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc,
        8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,
        8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a,
        8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75,
        8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0,
        8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84,
        8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b,
        8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf,
        8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85,
        8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8,
        8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5,
        8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2,
        8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17,
        8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73,
        8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88,
        8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb,
        8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c,
        8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79,
        8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9,
        8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08,
        8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6,
        8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a,
        8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e,
        8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e,
        8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94,
        8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf,
        8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68,
        8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16
    };

    logic   [31:0]	w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, 
                    w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, 
                    w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, 
                    w30, w31, w32, w33, w34, w35, w36, w37, w38, w39, 
                    w40, w41, w42, w43;
    logic   [31:0]	w0_q, w1_q, w2_q, w3_q, w4_q, w5_q, w6_q, w7_q, w8_q, w9_q, 
                    w10_q, w11_q, w12_q, w13_q, w14_q, w15_q, w16_q, w17_q, w18_q, w19_q, 
                    w20_q, w21_q, w22_q, w23_q, w24_q, w25_q, w26_q, w27_q, w28_q, w29_q, 
                    w30_q, w31_q, w32_q, w33_q, w34_q, w35_q, w36_q, w37_q, w38_q, w39_q, 
                    w40_q, w41_q, w42_q, w43_q;
    logic   [31:0]  subword, subword2, subword3, subword4, subword5, subword6, subword7, subword8, subword9, subword10;			
    // logic	[7:0]	rcon, rcon2, rcon3, rcon4, rcon5, rcon6, rcon7, rcon8, rcon9, rcon10;	

    // for initial RoundKey
    assign    w0 =  key[127:096];
    assign    w1 =  key[095:064];
    assign    w2 =  key[063:032];
    assign    w3 =  key[031:000];

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w0_q <= '0;
            w1_q <= '0;
            w2_q <= '0;
            w3_q <= '0;
        end
        else begin
            w0_q <= w0;
            w1_q <= w1;
            w2_q <= w2;
            w3_q <= w3;
        end
    end

    // Round 1 key
    assign    w4 =  w0_q^subword^{8'h01,24'b0};
    assign    w5 =  w0_q^w1_q^subword^{8'h01,24'b0};
    assign    w6 =  w0_q^w1_q^w2_q^subword^{8'h01,24'b0}; 
    assign    w7 =  w0_q^w1_q^w2_q^w3_q^subword^{8'h01,24'b0};
    // assign    w4 =  key[127:096]^subword^{8'h01,24'b0};
    // assign    w5 =  key[127:096]^key[095:064]^subword^{8'h01,24'b0};
    // assign    w6 =  key[127:096]^key[095:064]^key[063:032]^subword^{8'h01,24'b0}; 
    // assign    w7 =  key[127:096]^key[095:064]^key[063:032]^key[031:000]^subword^{8'h01,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w4_q <= '0;
            w5_q <= '0;
            w6_q <= '0;
            w7_q <= '0;
        end
        else begin
            w4_q <= w4;
            w5_q <= w5;
            w6_q <= w6;
            w7_q <= w7;
        end
    end

    // Round 2 key
    assign    w8  =  w4_q^subword2^{rcon2,24'b0};
    assign    w9  =  w5_q^w4_q^subword2^{rcon2,24'b0};
    assign    w10 =  w6_q^w5_q^w4_q^subword2^{rcon2,24'b0}; 
    assign    w11 =  w7_q^w6_q^w5_q^w4_q^subword2^{rcon2,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w8_q <= '0;
            w9_q <= '0;
            w10_q <= '0;
            w11_q <= '0;
        end
        else begin
            w8_q <= w8;
            w9_q <= w9;
            w10_q <= w10;
            w11_q <= w11;
        end
    end

    // Round 3 key
    assign    w12  =  w8_q^subword3^{rcon3,24'b0};
    assign    w13  =  w8_q^w9_q^subword3^{rcon3,24'b0};
    assign    w14  =  w8_q^w9_q^w10_q^subword3^{rcon3,24'b0}; 
    assign    w15  =  w8_q^w9_q^w10_q^w11_q^subword3^{rcon3,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w12_q <= '0;
            w13_q <= '0;
            w14_q <= '0;
            w15_q <= '0;
        end
        else begin
            w12_q <= w12;
            w13_q <= w13;
            w14_q <= w14;
            w15_q <= w15;
        end
    end

    // Round 4 key
    assign    w16  =  w12_q^subword4^{rcon4,24'b0};
    assign    w17  =  w12_q^w13_q^subword4^{rcon4,24'b0};
    assign    w18  =  w12_q^w13_q^w14_q^subword4^{rcon4,24'b0}; 
    assign    w19  =  w12_q^w13_q^w14_q^w15_q^subword4^{rcon4,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w16_q <= '0;
            w17_q <= '0;
            w18_q <= '0;
            w19_q <= '0;
        end
        else begin
            w16_q <= w16;
            w17_q <= w17;
            w18_q <= w18;
            w19_q <= w19;
        end
    end

    // Round 5 key
    assign    w20  =  w16_q^subword5^{rcon5,24'b0};
    assign    w21  =  w16_q^w17_q^subword5^{rcon5,24'b0};
    assign    w22  =  w16_q^w17_q^w18_q^subword5^{rcon5,24'b0}; 
    assign    w23  =  w16_q^w17_q^w18_q^w19_q^subword5^{rcon5,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w20_q <= '0;
            w21_q <= '0;
            w22_q <= '0;
            w23_q <= '0;
        end
        else begin
            w20_q <= w20;
            w21_q <= w21;
            w22_q <= w22;
            w23_q <= w23;
        end
    end

    // Round 6 key
    assign    w24  =  w20_q^subword6^{rcon6,24'b0};
    assign    w25  =  w20_q^w21_q^subword6^{rcon6,24'b0};
    assign    w26  =  w20_q^w21_q^w22_q^subword6^{rcon6,24'b0}; 
    assign    w27  =  w20_q^w21_q^w22_q^w23_q^subword6^{rcon6,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w24_q <= '0;
            w25_q <= '0;
            w26_q <= '0;
            w27_q <= '0;
        end
        else begin
            w24_q <= w24;
            w25_q <= w25;
            w26_q <= w26;
            w27_q <= w27;
        end
    end

    // Round 7 key
    assign    w28  =  w24_q^subword7^{rcon7,24'b0};
    assign    w29  =  w24_q^w25_q^subword7^{rcon7,24'b0};
    assign    w30  =  w24_q^w25_q^w26_q^subword7^{rcon7,24'b0}; 
    assign    w31  =  w24_q^w25_q^w26_q^w27_q^subword7^{rcon7,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w28_q <= '0;
            w29_q <= '0;
            w30_q <= '0;
            w31_q <= '0;
        end
        else begin
            w28_q <= w28;
            w29_q <= w29;
            w30_q <= w30;
            w31_q <= w31;
        end
    end

    // Round 8 key
    assign    w32  =  w28_q^subword8^{rcon8,24'b0};
    assign    w33  =  w28_q^w29_q^subword8^{rcon8,24'b0};
    assign    w34  =  w28_q^w29_q^w30_q^subword8^{rcon8,24'b0}; 
    assign    w35  =  w28_q^w29_q^w30_q^w31_q^subword8^{rcon8,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w32_q <= '0;
            w33_q <= '0;
            w34_q <= '0;
            w35_q <= '0;
        end
        else begin
            w32_q <= w32;
            w33_q <= w33;
            w34_q <= w34;
            w35_q <= w35;
        end
    end

    // Round 9 key
    assign    w36  =  w32_q^subword9^{rcon9,24'b0};
    assign    w37  =  w32_q^w33_q^subword9^{rcon9,24'b0};
    assign    w38  =  w32_q^w33_q^w34_q^subword9^{rcon9,24'b0}; 
    assign    w39  =  w32_q^w33_q^w34_q^w35_q^subword9^{rcon9,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w36_q <= '0;
            w37_q <= '0;
            w38_q <= '0;
            w39_q <= '0;
        end
        else begin
            w36_q <= w36;
            w37_q <= w37;
            w38_q <= w38;
            w39_q <= w39;
        end
    end

    // Round 10 key (last round)
    assign    w40  =  w36_q^subword10^{rcon10,24'b0};
    assign    w41  =  w36_q^w37_q^subword10^{rcon10,24'b0};
    assign    w42  =  w36_q^w37_q^w38_q^subword10^{rcon10,24'b0}; 
    assign    w43  =  w36_q^w37_q^w38_q^w39_q^subword10^{rcon10,24'b0};

    always_ff @( posedge clk ) begin 
        if(rst) begin
            w40_q <= '0;
            w41_q <= '0;
            w42_q <= '0;
            w43_q <= '0;
        end
        else begin
            w40_q <= w40;
            w41_q <= w41;
            w42_q <= w42;
            w43_q <= w43;
        end
    end

    assign subword[31:24]   = sbox_mem[w3_q[23:16]];
    assign subword[23:16]   = sbox_mem[w3_q[15:8]];
    assign subword[15:8]    = sbox_mem[w3_q[7:0]];
    assign subword[7:0]     = sbox_mem[w3_q[31:24]];
    // assign subword[31:24]   = sbox_mem[key[23:16]];
    // assign subword[23:16]   = sbox_mem[key[15:8]];
    // assign subword[15:8]    = sbox_mem[key[7:0]];
    // assign subword[7:0]     = sbox_mem[key[31:24]];

    assign subword2[31:24]  = sbox_mem[w7_q[23:16]];
    assign subword2[23:16]  = sbox_mem[w7_q[15:8]];
    assign subword2[15:8]   = sbox_mem[w7_q[7:0]];
    assign subword2[7:0]    = sbox_mem[w7_q[31:24]];

    assign subword3[31:24]  = sbox_mem[w11_q[23:16]];
    assign subword3[23:16]  = sbox_mem[w11_q[15:8]];
    assign subword3[15:8]   = sbox_mem[w11_q[7:0]];
    assign subword3[7:0]    = sbox_mem[w11_q[31:24]];

    assign subword4[31:24]  = sbox_mem[w15_q[23:16]];
    assign subword4[23:16]  = sbox_mem[w15_q[15:8]];
    assign subword4[15:8]   = sbox_mem[w15_q[7:0]];
    assign subword4[7:0]    = sbox_mem[w15_q[31:24]];

    assign subword5[31:24]  = sbox_mem[w19_q[23:16]];
    assign subword5[23:16]  = sbox_mem[w19_q[15:8]];
    assign subword5[15:8]   = sbox_mem[w19_q[7:0]];
    assign subword5[7:0]    = sbox_mem[w19_q[31:24]];

    assign subword6[31:24]  = sbox_mem[w23_q[23:16]];
    assign subword6[23:16]  = sbox_mem[w23_q[15:8]];
    assign subword6[15:8]   = sbox_mem[w23_q[7:0]];
    assign subword6[7:0]    = sbox_mem[w23_q[31:24]];

    assign subword7[31:24]  = sbox_mem[w27_q[23:16]];
    assign subword7[23:16]  = sbox_mem[w27_q[15:8]];
    assign subword7[15:8]   = sbox_mem[w27_q[7:0]];
    assign subword7[7:0]    = sbox_mem[w27_q[31:24]];

    assign subword8[31:24]  = sbox_mem[w31_q[23:16]];
    assign subword8[23:16]  = sbox_mem[w31_q[15:8]];
    assign subword8[15:8]   = sbox_mem[w31_q[7:0]];
    assign subword8[7:0]    = sbox_mem[w31_q[31:24]];

    assign subword9[31:24]  = sbox_mem[w35_q[23:16]];
    assign subword9[23:16]  = sbox_mem[w35_q[15:8]];
    assign subword9[15:8]   = sbox_mem[w35_q[7:0]];
    assign subword9[7:0]    = sbox_mem[w35_q[31:24]];

    assign subword10[31:24] = sbox_mem[w39_q[23:16]];
    assign subword10[23:16] = sbox_mem[w39_q[15:8]];
    assign subword10[15:8]  = sbox_mem[w39_q[7:0]];
    assign subword10[7:0]   = sbox_mem[w39_q[31:24]];

    assign key_s0={w0,w1,w2,w3};
    assign key_s1={w4,w5,w6,w7};
    assign key_s2={w8,w9,w10,w11};
    assign key_s3={w12,w13,w14,w15};
    assign key_s4={w16,w17,w18,w19};
    assign key_s5={w20,w21,w22,w23};
    assign key_s6={w24,w25,w26,w27};
    assign key_s7={w28,w29,w30,w31};
    assign key_s8={w32,w33,w34,w35};
    assign key_s9={w36,w37,w38,w39};
    assign key_s10={w40,w41,w42,w43};

endmodule


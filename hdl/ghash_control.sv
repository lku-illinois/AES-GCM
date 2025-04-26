module ghash_control(
    input   logic               clk,
    input   logic               rst,

    //////////////////////////////////////////////////////////
    /// Multiplier trigger signal
    //////////////////////////////////////////////////////////
    // total input #AAD + #CT + 1(lenAC)
    input   int                 input_num,  // from AES
    input   logic               start,      // from AES A_i{len, AAD, C} is ready
    output  logic               busy,       // to distribute module
    output  logic               flush_mul,  // to multiplier
    output  logic               error_o,    // for debug 

    //////////////////////////////////////////////////////////
    /// Multiplier control signal
    //////////////////////////////////////////////////////////
    // from h generation
    input   logic   [127:0]     h1,
    input   logic   [127:0]     h2,
    input   logic   [127:0]     h4,
    input   logic               h_valid,        // all h is valid
    // to multiplier
    output  logic   [31:0]      ha_o,
    output  logic   [31:0]      hb_o,
    output  logic   [31:0]      hc_o,
    output  logic   [31:0]      hd_o,
    output  logic               xor_o,
    output  logic               GHASH_done,

    //////////////////////////////////////////////////////////
    /// Multiplier A_input/output 
    //////////////////////////////////////////////////////////
    output  logic               A_req,  // request distribute module to send in new A_i
    input   logic   [127:0]     A_i,    // from distribute module       
    output  logic   [127:0]     A_o,    // to multuplier input     

    //////////////////////////////////////////////////////////
    /// Multiplier Zd feedback 
    ////////////////////////////////////////////////////////// 
    input   logic   [127:0]     Zd_fb    
);
    // enum int unsigned{
    //     idle, error, finish,
    //     s1_1, s1_2, s1_3, s1_4, s1_5,
    //     s2_1, s2_2, s2_3, s2_4, s2_5, s2_6,
    //     s3_1, s3_2, s3_3, s3_4, s3_5, s3_6, s3_7, s3_8, s3_9,
    //     s4_1, s4_2, s4_3, s4_4, s4_5, s4_6, s4_7, s4_8, s4_9, s4_10,
    //     s5_1, s5_2, s5_3, s5_4, s5_5, s5_6, s5_7, s5_8, s5_9, s5_10, s5_11,
    //     s6_1, s6_2, s6_3, s6_4, s6_5, s6_6, s6_7, s6_8, s6_9, s6_10, s6_11, s6_12,
    //     s7_1, s7_2, s7_3, s7_4, s7_5, s7_6, s7_7, s7_8, s7_9, s7_10, s7_11, s7_12, s7_13
    // }state, next_state;
    typedef enum int unsigned{
        idle, error, finish,
        s1_1, s1_2, s1_3, s1_4, s1_5,
        s2_1, s2_2, s2_3, s2_4, s2_5, s2_6,
        s3_1, s3_2, s3_3, s3_4, s3_5, s3_6, s3_7, s3_8, s3_9,
        s4_1, s4_2, s4_3, s4_4, s4_5, s4_6, s4_7, s4_8, s4_9, s4_10,
        s5_1, s5_2, s5_3, s5_4, s5_5, s5_6, s5_7, s5_8, s5_9, s5_10, s5_11,
        s6_1, s6_2, s6_3, s6_4, s6_5, s6_6, s6_7, s6_8, s6_9, s6_10, s6_11, s6_12,
        s7_1, s7_2, s7_3, s7_4, s7_5, s7_6, s7_7, s7_8, s7_9, s7_10, s7_11, s7_12, s7_13
    }state_t;
    state_t state, next_state;
    state_t state_lut [7:0];
    always_comb begin 
        state_lut[0] = idle;
        state_lut[1] = s1_1;
        state_lut[2] = s2_1;
        state_lut[3] = s3_1;
        state_lut[4] = s4_1;
        state_lut[5] = s5_1;
        state_lut[6] = s6_1;
        state_lut[7] = s7_1;
    end

    always_ff @( posedge clk ) begin 
        if(rst) begin
            state <= idle;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin 
        next_state = state;
        flush_mul = '0;
        error_o = '0;
        A_o = '0;
        ha_o = '0;
        hb_o = '0;
        hc_o = '0;
        hd_o = '0;
        xor_o = '0;
        GHASH_done = '0;
        A_req = '0;

        case(state)
            /////////////////////////////
            /// IDLE
            /////////////////////////////
            idle: begin
                flush_mul = 1'b1;
                if(h_valid && start) begin
                    next_state = state_lut[input_num];
                    A_req = 1'b1;
                    // case(input_num)
                    //     1:  begin
                    //         next_state = s1_1;
                    //         A_req = 1'b1;
                    //     end
                    //     2: begin
                    //         next_state = s2_1;
                    //         A_req = 1'b1;
                    //     end
                    //     3: begin
                    //         next_state = s3_1;
                    //         A_req = 1'b1;
                    //     end
                    //     4: begin
                    //         next_state = s4_1;
                    //         A_req = 1'b1;
                    //     end
                    //     5: begin
                    //         next_state = s5_1;
                    //         A_req = 1'b1;
                    //     end
                    //     6: begin
                    //         next_state = s6_1;
                    //         A_req = 1'b1;
                    //     end
                    //     7: begin
                    //         next_state = s7_1;
                    //         A_req = 1'b1;
                    //     end
                    // endcase
                end
            end
            /////////////////////////////
            /// 1 Input
            /////////////////////////////
            s1_1: begin
                A_o = A_i;
                ha_o = h1[127:96];
                next_state = s1_2;
            end
            s1_2: begin
                hb_o = h1[95:64];
                next_state = s1_3;
            end
            s1_3: begin
                hc_o = h1[63:32];
                next_state = s1_4;
            end
            s1_4: begin
                hd_o = h1[31:0];
                next_state = s1_5;
            end
            s1_5: begin
                xor_o = 1'b1;
                next_state = finish;
            end
            /////////////////////////////
            /// 2 Input
            /////////////////////////////
            s2_1: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                next_state = s2_2;
            end
            s2_2: begin
                A_o = A_i;
                ha_o = h1[127:96];
                hb_o = h2[95:64];
                next_state = s2_3;
            end
            s2_3: begin
                hb_o = h1[95:64];
                hc_o = h2[63:32];
                next_state = s2_4;
            end
            s2_4: begin
                hc_o = h1[63:32];
                hd_o = h2[31:0];
                next_state = s2_5;
            end
            s2_5: begin
                hd_o = h1[31:0];
                xor_o = 1'b1;
                next_state = s2_6;
            end
            s2_6: begin
                xor_o = 1'b1;
                next_state = finish;
            end
            /////////////////////////////
            /// 3 Input
            /////////////////////////////
            s3_1: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                next_state = s3_2;
            end
            s3_2: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h2[95:64];
                next_state = s3_3;
            end
            s3_3: begin
                A_o = A_i;
                ha_o = h1[127:96];
                hb_o = h2[95:64];
                hc_o = h2[63:32];
                next_state = s3_4;
            end
            s3_4: begin
                hb_o = h1[95:64];
                hc_o = h2[63:32];
                hd_o = h2[31:0];
                next_state = s3_5;
            end
            s3_5: begin
                A_o = Zd_fb;
                ha_o = h1[127:96];
                hc_o = h1[63:32];
                hd_o = h2[31:0];
                next_state = s3_6;
            end
            s3_6: begin
                hb_o = h1[95:64];
                hd_o = h1[31:0];
                xor_o = 1'b1;
                next_state = s3_7;
            end
            s3_7: begin
                hc_o = h1[63:32];
                xor_o = 1'b1;
                next_state = s3_8;
            end
            s3_8: begin
                hd_o = h1[31:0];
                next_state = s3_9;
            end
            s3_9: begin
                xor_o = 1'b1;
                next_state = finish;
            end
            /////////////////////////////
            /// 4 Input
            /////////////////////////////
            s4_1: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                next_state = s4_2;
            end
            s4_2:begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h4[95:64];
                next_state = s4_3;
            end
            s4_3:begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h2[95:64];
                hc_o = h4[63:32];
                next_state = s4_4;
            end
            s4_4:begin
                A_o = A_i;
                ha_o = h1[127:96];
                hb_o = h2[95:64];
                hc_o = h2[63:32];
                hd_o = h4[31:0];
                next_state = s4_5;
            end
            s4_5:begin
                hb_o = h1[95:64];
                hc_o = h2[63:32];
                hd_o = h2[31:0];
                xor_o = 1'b1;
                next_state = s4_6;
            end
            s4_6:begin
                A_o = Zd_fb;
                ha_o = h1[127:96];
                hc_o = h1[63:32];
                hd_o = h2[31:0];
                next_state = s4_7;
            end
            s4_7:begin
                hb_o = h1[95:64];
                hd_o = h1[31:0];
                xor_o = 1'b1;
                next_state = s4_8;
            end
            s4_8:begin
                hc_o = h1[63:32];
                xor_o = 1'b1;
                next_state = s4_9;
            end
            s4_9:begin
                hd_o = h1[31:0];
                next_state = s4_10;
            end
            s4_10:begin
                xor_o = 1'b1;
                next_state = finish;
            end
            /////////////////////////////
            /// 5 Input
            /////////////////////////////
            s5_1: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                next_state = s5_2;
            end
            s5_2: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                hb_o = h4[95:64];
                next_state = s5_3;
            end 
            s5_3: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h4[95:64];
                hc_o = h4[63:32];
                next_state = s5_4;
            end 
            s5_4: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h2[95:64];
                hc_o = h4[63:32];
                hd_o = h4[31:0];
                next_state = s5_5;
            end 
            s5_5: begin
                A_o = Zd_fb ^ A_i;
                ha_o = h1[127:96];
                hb_o = h2[95:64];
                hc_o = h2[63:32];
                hd_o = h4[31:0];
                next_state = s5_6;
            end  
            s5_6: begin
                hb_o = h1[95:64];
                hc_o = h2[63:32];
                hd_o = h2[31:0];
                xor_o = 1'b1;
                next_state = s5_7;
            end  
            s5_7: begin
                A_o = Zd_fb;
                ha_o = h1[127:96];
                hc_o = h1[63:32];
                hd_o = h2[31:0];
                next_state = s5_8;
            end  
            s5_8: begin
                hb_o = h1[95:64];
                hd_o = h1[31:0];
                xor_o = 1'b1;
                next_state = s5_9;
            end  
            s5_9: begin
                hc_o = h1[63:32];
                xor_o = 1'b1;
                next_state = s5_10;
            end  
            s5_10: begin
                hd_o = h1[31:0];
                next_state = s5_11;
            end  
            s5_11: begin
                xor_o = 1'b1;
                next_state = finish;
            end
            /////////////////////////////
            /// 6 Input
            /////////////////////////////
            s6_1: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                next_state = s6_2;
            end
            s6_2: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                hb_o = h4[95:64];
                next_state = s6_3;
            end 
            s6_3: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                hb_o = h4[95:64];
                hc_o = h4[63:32];
                next_state = s6_4;
            end
            s6_4: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h4[95:64];
                hc_o = h4[63:32];
                hd_o = h4[31:0];
                next_state = s6_5;
            end 
            s6_5: begin
                A_o = Zd_fb ^ A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h2[95:64];
                hc_o = h4[63:32];
                hd_o = h4[31:0];
                next_state = s6_6;
            end 
            s6_6: begin
                A_o = Zd_fb ^ A_i;
                ha_o = h1[127:96];
                hb_o = h2[95:64];
                hc_o = h2[63:32];
                hd_o = h4[31:0];
                next_state = s6_7;
            end 
            s6_7: begin
                hb_o = h1[95:64];
                hc_o = h2[63:32];
                hd_o = h2[31:0];
                xor_o = 1'b1;
                next_state = s6_8;
            end
            s6_8: begin
                A_o = Zd_fb;
                ha_o = h1[127:96];
                hc_o = h1[63:32];
                hd_o = h2[31:0];
                next_state = s6_9;
            end
            s6_9: begin
                hb_o = h1[95:64];
                hd_o = h1[31:0];
                xor_o = 1'b1;
                next_state = s6_10;
            end
            s6_10: begin
                hc_o = h1[63:32];
                xor_o = 1'b1;
                next_state = s6_11;
            end 
            s6_11: begin
                hd_o = h1[31:0];
                next_state = s6_12;
            end 
            s6_12: begin
                xor_o = 1'b1;
                next_state = finish;
            end
            /////////////////////////////
            /// 7 Input
            /////////////////////////////
            s7_1: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                next_state = s7_2;
            end
            s7_2: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                hb_o = h4[95:64];
                next_state = s7_3;
            end 
            s7_3: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                hb_o = h4[95:64];
                hc_o = h4[63:32];
                next_state = s7_4;
            end
            s7_4: begin
                A_o = A_i;
                A_req = 1'b1;
                ha_o = h4[127:96];
                hb_o = h4[95:64];
                hc_o = h4[63:32];
                hd_o = h4[31:0];
                next_state = s7_5;
            end 
            s7_5: begin
                A_o = Zd_fb ^ A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h4[95:64];
                hc_o = h4[63:32];
                hd_o = h4[31:0];
                next_state = s7_6;
            end 
            s7_6: begin
                A_o = Zd_fb ^ A_i;
                A_req = 1'b1;
                ha_o = h2[127:96];
                hb_o = h2[95:64];
                hc_o = h4[63:32];
                hd_o = h4[31:0];
                next_state = s7_7;
            end
            s7_7: begin
                A_o = Zd_fb ^ A_i;
                ha_o = h1[127:96];
                hb_o = h2[95:64];
                hc_o = h2[63:32];
                hd_o = h4[31:0];
                next_state = s7_8;
            end 
            s7_8: begin
                hb_o = h1[95:64];
                hc_o = h2[63:32];
                hd_o = h2[31:0];
                xor_o = 1'b1;
                next_state = s7_9;
            end
            s7_9: begin
                A_o = Zd_fb;
                ha_o = h1[127:96];
                hc_o = h1[63:32];
                hd_o = h2[31:0];
                next_state = s7_10;
            end
            s7_10: begin
                hb_o = h1[95:64];
                hd_o = h1[31:0];
                xor_o = 1'b1;
                next_state = s7_11;
            end
            s7_11: begin
                hc_o = h1[63:32];
                xor_o = 1'b1;
                next_state = s7_12;
            end
            s7_12: begin
                hd_o = h1[31:0];
                next_state = s7_13;
            end
            s7_13: begin
                xor_o = 1'b1;
                next_state = finish;
            end
            /////////////////////////////
            /// FINISH
            /////////////////////////////
            finish: begin
                GHASH_done = 1'b1;
                next_state = idle;
            end
            /////////////////////////////
            /// ERROR
            /////////////////////////////
            error: begin
                error_o = 1'b1;
            end
            /////////////////////////////
            /// DEFAULT
            /////////////////////////////
            default: begin
            end
        endcase
    end

    assign busy = !(next_state inside {idle});

endmodule
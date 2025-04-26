// this is the GHASH MODULE with testbench test_GHASH_main.sv
module top(
    input   logic               clk,
    input   logic               rst,
    // AES_GCM Start
    input   logic               start,
    // Key
    input   logic   [127:0]     Key_in,
    // Initialization Vector
    input   logic   [127:0]     IV_in,    
    input   int                 IV_byte_len,      
    input   int                 IV_total,       // How many 128bit blocks does IV have
    // Plain Text
    input   logic   [127:0]     PText_in,      
    input   int                 PText_byte_len,     // how long is each block? normally its 128 bits, but the last block can be lesser (96bits in test 6)   
    input   int                 PText_total,
    // Additional Authenticated Data
    input   logic   [127:0]     AAD_in,
    input   int                 AAD_byte_len,
    input   int                 AAD_total,   
    // Hash Key (H, H^2, H^4)
    input   logic   [127:0]     H,
    input   logic   [127:0]     H2,
    input   logic   [127:0]     H4,
    // To top_tb
    output  logic               IV_req,         // request new IV block
    output  logic               PText_req,      // request new PText block
    output  logic               AAD_req,        // request new AAD block
    // Cipher Text
    output  logic   [127:0]     CText, 
    output  logic               CText_valid,       
    output  int                 CText_total,
    // Authentication tag
    output  logic   [127:0]     AuthTag,
    output  logic               AuthTag_valid
);
    logic   [127:0]     PText_in_q;  
    int                 PText_byte_len_q, PText_total_q;
    int                 IV_total_q, IV_byte_len_q;
    int                 counter;
    logic   [127:0]     IV_in_q, Len_IV;

    int             GHASH_inputnum;
    logic           GHASH_start, GHASH_busy;
    logic           A_req;
    logic           GHASH_error, GHASH_finish;
    logic   [127:0] GHASH_in, GHASH_out, GHASH_out_q, y0_q;

    logic   [127:0] AES_in, AES_out, AES_out_q;
    logic           AES_start, AES_first_block_finish, AES_final_block_finish;
    logic           AES_first_block_finish_q, AES_final_block_finish_q;

    logic   [127:0] CText_q;

    logic           Xi_gen_start;
    int             Xi_inputnum;
    logic   [127:0] Xi_in;

    GHASH_main GHASH_core(
        .clk(clk),
        .rst(rst),
        // .input_num(Xi_gen_start ? Xi_inputnum : GHASH_inputnum),
        // .start(GHASH_start || Xi_gen_start),
        .input_num(GHASH_inputnum | Xi_inputnum),
        .start(GHASH_start | Xi_gen_start),
        .busy(GHASH_busy),
        .error_o(GHASH_error),
        .h1(H),
        .h2(H2),
        .h4(H4),
        .h_valid(1'b1), // assume H, H2, H4 is precomputed
        .A_req(A_req),  // not realy used
        .A_i(GHASH_in | Xi_in),
        .XI_o(GHASH_out), 
        .GHASH_done(GHASH_finish)
    );
    AES_main AES_core(
        .clk(clk),
        .rst(rst),
        .data_in(AES_in),
        .key(Key_in),
        .AAD_total(AAD_total),
        .GHASH_start(Xi_gen_start),
        .data_out(AES_out),
        .start(AES_start),
        .data_total(PText_total+1),        // Plain Text total = i for Yi, but we also feed Y0
        .AES_first_block_finish(AES_first_block_finish),
        .AES_final_block_finish(AES_final_block_finish)
    );

    always_ff @( posedge clk ) begin 
        AES_final_block_finish_q <= AES_final_block_finish;
        AES_first_block_finish_q <= AES_first_block_finish;
    end
    always_ff @( posedge clk ) begin
        AES_out_q <= AES_out;
    end
    // Y0 increment -> Yi
    always_ff @( posedge clk ) begin
        if(rst)                                    GHASH_out_q <= '0;
        else if(AES_start)                         GHASH_out_q <= AES_in + 1'b1;    // start with Y1 = Y0 + 1
        else if(GHASH_out_q != 0)                  GHASH_out_q <= GHASH_out_q + 1'b1;  // Y2, Y3 ...
    end
    always_ff @( posedge clk ) begin 
        PText_in_q <= PText_in;
        PText_byte_len_q <= PText_byte_len;
        PText_total_q <= PText_total;
    end
    always_ff @( posedge clk ) begin 
        IV_byte_len_q <= IV_byte_len;
        IV_total_q <= IV_total;
        IV_in_q <= IV_in;
    end
    


    enum int unsigned{
        idle, Y0_gen, Ei_gen, Ci_gen
    }state, next_state;

    always_ff @( posedge clk ) begin 
        if(rst) begin
            state <= idle;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin 
        next_state      = state;
        IV_req          = '0;
        PText_req       = '0;
        GHASH_inputnum  = '0;
        GHASH_start     = '0;
        GHASH_in        = '0;
        AES_in          = '0;
        AES_start       = '0;
        CText           = '0;
        CText_valid     = '0;
        CText_total     = '0;

        case(state)
            idle: begin
                if(!rst && start) begin
                    GHASH_inputnum = IV_total+1;        // IV + len(IV)
                    GHASH_start = ((IV_total == 1) && (IV_byte_len == 12)) ? 1'b0 : 1'b1;
                    next_state = Y0_gen;
                end
            end
            Y0_gen: begin
                IV_req = (IV_total_q == 1) ? 1'b0 : 1'b1;
                GHASH_in = (counter != 0) ? IV_in : Len_IV;
                if(GHASH_finish) begin
                    AES_in = GHASH_out;     // pass Y0 to AES
                    AES_start = 1'b1;
                    next_state = Ei_gen;
                end
                else if((IV_total_q == 1) && (IV_byte_len_q == 12)) begin
                    AES_in = {IV_in_q[127:32], 32'h00000001};;     // pass Y0 to AES
                    AES_start = 1'b1;
                    next_state = Ei_gen;
                end
            end
            Ei_gen: begin
                AES_in = GHASH_out_q;                   // Pass Y1, Y2 ...
                if(AES_first_block_finish_q) begin
                    next_state = Ci_gen;
                    PText_req = 1'b1;                   // request new plain text
                end
            end
            Ci_gen: begin
                CText_valid = (PText_total_q != 0);
                CText_total = PText_total_q;
                // generate Cipher Text   
                // for(int i=0; i<PText_byte_len && i<16; i++) begin
                //     CText[127-8*i -: 8] = PText_in[127-8*i -: 8] ^ AES_out_q[127-8*i -: 8];
                // end
                CText[127:120] = (PText_byte_len_q > 0)  ? PText_in_q[127:120] ^ AES_out_q[127:120] : 8'd0;
                CText[119:112] = (PText_byte_len_q > 1)  ? PText_in_q[119:112] ^ AES_out_q[119:112] : 8'd0;
                CText[111:104] = (PText_byte_len_q > 2)  ? PText_in_q[111:104] ^ AES_out_q[111:104] : 8'd0;
                CText[103:96]  = (PText_byte_len_q > 3)  ? PText_in_q[103:96]  ^ AES_out_q[103:96]  : 8'd0;
                CText[95:88]   = (PText_byte_len_q > 4)  ? PText_in_q[95:88]   ^ AES_out_q[95:88]   : 8'd0;
                CText[87:80]   = (PText_byte_len_q > 5)  ? PText_in_q[87:80]   ^ AES_out_q[87:80]   : 8'd0;
                CText[79:72]   = (PText_byte_len_q > 6)  ? PText_in_q[79:72]   ^ AES_out_q[79:72]   : 8'd0;
                CText[71:64]   = (PText_byte_len_q > 7)  ? PText_in_q[71:64]   ^ AES_out_q[71:64]   : 8'd0;
                CText[63:56]   = (PText_byte_len_q > 8)  ? PText_in_q[63:56]   ^ AES_out_q[63:56]   : 8'd0;
                CText[55:48]   = (PText_byte_len_q > 9)  ? PText_in_q[55:48]   ^ AES_out_q[55:48]   : 8'd0;
                CText[47:40]   = (PText_byte_len_q > 10) ? PText_in_q[47:40]   ^ AES_out_q[47:40]   : 8'd0;
                CText[39:32]   = (PText_byte_len_q > 11) ? PText_in_q[39:32]   ^ AES_out_q[39:32]   : 8'd0;
                CText[31:24]   = (PText_byte_len_q > 12) ? PText_in_q[31:24]   ^ AES_out_q[31:24]   : 8'd0;
                CText[23:16]   = (PText_byte_len_q > 13) ? PText_in_q[23:16]   ^ AES_out_q[23:16]   : 8'd0;
                CText[15:8]    = (PText_byte_len_q > 14) ? PText_in_q[15:8]    ^ AES_out_q[15:8]    : 8'd0;
                CText[7:0]     = (PText_byte_len_q > 15) ? PText_in_q[7:0]     ^ AES_out_q[7:0]     : 8'd0;
                // set next state
                if(AES_final_block_finish_q || (PText_total == 0)) begin      // this should be just next_state = HASHING AUTH TAG
                    next_state = idle;
                end
            end
            default: begin
            end
        endcase
    end


    // A different FSM to Feed AAD, CText, Length(A+C) to generate Authentication Tag T
    logic   [63:0]      Len_P, Len_A;
    int                 counter1, counter2;
    logic               Auth_length_done;
    logic   [127:0]     final_encrypt_y;


    enum int unsigned{
        Auth_idle, Auth_AAD, Auth_CText, Auth_Length
    }Auth_state, Auth_next_state;

    always_ff @( posedge clk ) begin 
        if(rst) begin
            Auth_state <= Auth_idle;
        end
        else begin
            Auth_state <= Auth_next_state;
        end
    end

    always_comb begin 
        Xi_inputnum = '0;
        Xi_in = '0;
        Auth_next_state = Auth_state;
        AAD_req = '0;

        case(Auth_state)
            Auth_idle: begin
                if(Xi_gen_start) begin
                    Xi_inputnum = AAD_total + PText_total + 1;
                    Auth_next_state = (AAD_total != 0) ? Auth_AAD : ((PText_total != 0) ? Auth_CText : Auth_Length);
                end
            end
            Auth_AAD: begin
                AAD_req = 1'b1;
                Xi_in = AAD_in;
                if(counter1==1) begin
                    Auth_next_state = Auth_CText;
                end
            end
            Auth_CText: begin
                Xi_in = CText_q;
                if(counter2==1) begin
                    Auth_next_state = Auth_Length;
                end  
            end
            Auth_Length: begin
                Xi_in = {Len_A,Len_P};
                Auth_next_state = Auth_idle;
            end
        endcase
    end
    
    always_ff @( posedge clk ) begin 
        if(rst) counter <= '0;
        else if(counter != 0) counter <= counter - 1;
        else if(next_state == Y0_gen && state == idle) counter <= IV_total;
    end
    always_ff @( posedge clk ) begin 
        if(rst) counter1 <= '0;
        else if(counter1 != 0) counter1 <= counter1 - 1;
        else if(Auth_next_state == Auth_AAD) counter1 <= AAD_total;
    end
    always_ff @( posedge clk ) begin 
        if(rst) counter2 <= '0;
        else if(counter2 != 0) counter2 <= counter2 - 1;
        else if(Auth_next_state == Auth_CText) counter2 <= PText_total;
    end
    always_ff @( posedge clk ) begin
        if(rst) begin
            CText_q <= '0;
        end
        else begin
            CText_q <= CText;
        end
    end
    always_ff @( posedge clk ) begin 
        if(rst) Len_P <= '0;
        else if(state == Ci_gen) Len_P <= Len_P + (PText_byte_len_q*8);
    end
    always_ff @( posedge clk ) begin 
        if(rst) Len_A <= '0;
        else if(Auth_state == Auth_AAD) Len_A <= Len_A + (AAD_byte_len*8);
    end
    always_ff @( posedge clk ) begin 
        if(rst) Len_IV <= '0;
        else if (counter != '0) Len_IV <= Len_IV + (IV_byte_len*8);
    end
    always_ff @( posedge clk ) begin 
        if(rst) Auth_length_done <= '0;
        else if(Auth_next_state == Auth_Length) Auth_length_done <= 1'b1;
    end
    always_ff @( posedge clk ) begin 
        if(rst) final_encrypt_y <= '0;
        else if(AES_first_block_finish_q) final_encrypt_y <= AES_out_q;
    end
    assign AuthTag_valid = Auth_length_done && GHASH_finish;
    assign AuthTag       = (Auth_length_done && GHASH_finish) ? (GHASH_out^final_encrypt_y) : '0;


endmodule
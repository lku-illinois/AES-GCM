module shiftrows(
    input   logic           clk,
    input   logic   [127:0] data_in,
    output  logic   [127:0] data_out
);
    logic [127:0] tmp_out;

    // Row 0 (no shift)
    assign tmp_out[127:120] = data_in[127:120]; // s0,0
    assign tmp_out[95:88]   = data_in[95:88];   // s0,1
    assign tmp_out[63:56]   = data_in[63:56];   // s0,2
    assign tmp_out[31:24]   = data_in[31:24];   // s0,3

    // Row 1 (shift left by 1)
    assign tmp_out[119:112] = data_in[87:80];   // s1,1 ← s1,2
    assign tmp_out[87:80]   = data_in[55:48];   // s1,2 ← s1,3
    assign tmp_out[55:48]   = data_in[23:16];   // s1,3 ← s1,0
    assign tmp_out[23:16]   = data_in[119:112]; // s1,0 ← s1,1

    // Row 2 (shift left by 2)
    assign tmp_out[111:104] = data_in[47:40];   // s2,2 ← s2,0
    assign tmp_out[79:72]   = data_in[15:8];    // s2,3 ← s2,1
    assign tmp_out[47:40]   = data_in[111:104]; // s2,0 ← s2,2
    assign tmp_out[15:8]    = data_in[79:72];   // s2,1 ← s2,3

    // // Row 3 (shift left by 3)
    // assign tmp_out[103:96]  = data_in[39:32];   // s3,3 ← s3,0
    // assign tmp_out[71:64]   = data_in[103:96];  // s3,0 ← s3,1
    // assign tmp_out[39:32]   = data_in[71:64];   // s3,1 ← s3,2
    // assign tmp_out[7:0]     = data_in[7:0];     // s3,2 ← s3,3

    // Row 3: shift left by 3
    assign tmp_out[103:96]  = data_in[7:0];       // s15
    assign tmp_out[71:64]   = data_in[103:96];    // s3
    assign tmp_out[39:32]   = data_in[71:64];     // s7
    assign tmp_out[7:0]     = data_in[39:32];     // s11


    always_ff @( posedge clk ) begin 
        data_out <= tmp_out;
    end

endmodule
// before
// 0 4 8  12    <- dont shift
// 1 5 9  13    <- left shift 1
// 2 6 10 14    <- left shift 2
// 3 7 11 15    <- left shift 3

// after
// 0  4  8  12
// 5  9  13 1
// 10 14 2  6
// 15 3  7  11




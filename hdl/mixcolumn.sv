// we combined MixColumn with AddRoundKey
// data_out <= {n_tmp_out1,n_tmp_out2,n_tmp_out3,n_tmp_out4} ^ key_i;
// {n_tmp_out1,n_tmp_out2,n_tmp_out3,n_tmp_out4} this is the output of MixColumn
// ^ key_i, this is doing AddRoundKey
module mixcolumn(
    input   logic           clk,
    input   logic           rst,
    // input   logic   [127:0] key_i,
    input   logic   [127:0] data_in,
    output  logic   [127:0] data_out
);
    logic  [31:0] n1, n2, n3, n4;
    logic  [31:0] n_tmp_out1, n_tmp_out2, n_tmp_out3, n_tmp_out4;

    assign n1 = data_in[127:96];
    assign n2 = data_in[95:64];
    assign n3 = data_in[63:32];
    assign n4 = data_in[31:0];

    mul_32 m1 (
        // .clk(clk),
        .m_data_in(n1),
        .m_data_out(n_tmp_out1)
    );
    mul_32 m2 (
        // .clk(clk),
        .m_data_in(n2),
        .m_data_out(n_tmp_out2)
    );
    mul_32 m3 (
        // .clk(clk),
        .m_data_in(n3),
        .m_data_out(n_tmp_out3)
    );
    mul_32 m4 (
        // .clk(clk),
        .m_data_in(n4),
        .m_data_out(n_tmp_out4)
    );

    // assign data_out={n_tmp_out1,n_tmp_out2,n_tmp_out3,n_tmp_out4};
    always_ff @( posedge clk ) begin 
        if(rst) 
            data_out <= '0;
        else
            // data_out <= {n_tmp_out1,n_tmp_out2,n_tmp_out3,n_tmp_out4} ^ key_i;
            data_out <= {n_tmp_out1,n_tmp_out2,n_tmp_out3,n_tmp_out4};
    end

endmodule

module mul_2(
    // input                   clk,
    input   logic   [7:0]   data_in,
    output  logic   [7:0]   data_out
);
    // always_ff @( posedge clk ) begin
    //     data_out <= {data_in[6:0],1'b0} ^ (8'h1b & {8{data_in[7]}});
    // end
    assign data_out = {data_in[6:0],1'b0} ^ (8'h1b & {8{data_in[7]}});

endmodule


module mul_3(
    // input   logic           clk,
    input   logic   [7:0]   data_in,
    output  logic   [7:0]   data_out
);
    logic [7:0] tmp_out;

    mul_2  m1(
        // .clk(clk),
        .data_in(data_in),
        .data_out(tmp_out)
    );
    assign  data_out = tmp_out^data_in;

endmodule



module mul_32(
    // input   logic           clk,
    input   logic   [31:0]  m_data_in,
    output  logic   [31:0]  m_data_out
);

    logic [7:0] tmp1, tmp2, tmp3, tmp4;
    logic [7:0] ma0, ma1, ma2, ma3;
    logic [7:0] m2_tmp_out1, m2_tmp_out2, m2_tmp_out3, m2_tmp_out4;
    logic [7:0] m3_tmp_out1, m3_tmp_out2, m3_tmp_out3, m3_tmp_out4;

    assign tmp1 = m_data_in[31:24];
    assign tmp2 = m_data_in[23:16];
    assign tmp3 = m_data_in[15:8];
    assign tmp4 = m_data_in[7:0];

    mul_2 m1 (
        // .clk(clk),
        .data_in(tmp1),
        .data_out(m2_tmp_out1)
    );
    mul_2 m2 (
        // .clk(clk),
        .data_in(tmp2),
        .data_out(m2_tmp_out2)
    );
    mul_2 m3 (
        // .clk(clk),
        .data_in(tmp3),
        .data_out(m2_tmp_out3)
    );
    mul_2 m4 (
        // .clk(clk),
        .data_in(tmp4),
        .data_out(m2_tmp_out4)
    );


    mul_3 m5(
        // .clk(clk),
        .data_in(tmp1),
        .data_out(m3_tmp_out1)
    );
    mul_3 m6(
        // .clk(clk),
        .data_in(tmp2),
        .data_out(m3_tmp_out2)
    );
    mul_3 m7(
        // .clk(clk),
        .data_in(tmp3),
        .data_out(m3_tmp_out3)
    );
    mul_3 m8(
        // .clk(clk),
        .data_in(tmp4),
        .data_out(m3_tmp_out4)
    );

    assign ma0 = m2_tmp_out1 ^m3_tmp_out2^tmp3^tmp4;
    assign ma1 = tmp1 ^m2_tmp_out2 ^m3_tmp_out3 ^ tmp4;
    assign ma2 = tmp1^tmp2 ^ m2_tmp_out3 ^m3_tmp_out4;
    assign ma3 = m3_tmp_out1 ^tmp2^tmp3^m2_tmp_out4;

    assign m_data_out = {ma0,ma1,ma2,ma3};
endmodule
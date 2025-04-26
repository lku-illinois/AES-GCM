module round(
    input   logic           clk,
    input   logic           rst,
    input   logic   [127:0] data_in,
    input   logic   [127:0] key_in,
    output  logic   [127:0] data_out
);
    // logic [127:0]   sub_data_out, shift_data_out, mix_data_out;
    logic [127:0]   shift_data_out, mix_data_out; 
    logic [127:0]   key_q;
    // subbytes a1(
    //     .clk(clk),
    //     .data(data_in),
    //     .s_data_out(sub_data_out)
    // );
    // shiftrows a2(
    //     .clk(clk),
    //     .data_in(sub_data_out),
    //     .data_out(shift_data_out)
    // );
    always_ff @( posedge clk ) begin 
        if(rst)
            key_q <= '0;
        else 
            key_q <= key_in;
    end
    // ShiftSub is sequential, output comes in next cycle
    ShiftSub a2(
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(shift_data_out)
    );
    // mixcolumn is combinational, output comes in same cycle
    mixcolumn a3(
        .clk(clk),
        .rst(rst),
        // .key_i(key_q),
        .data_in(shift_data_out),
        .data_out(mix_data_out)
    );
    assign data_out = mix_data_out ^ key_q;
endmodule

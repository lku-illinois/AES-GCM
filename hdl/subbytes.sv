module subbytes(
    input   logic           clk,
    input   logic   [127:0] data,
    output  logic   [127:0] s_data_out
);
	logic [127:0] tmp_out;
		
	sbox q0( .data(data[127:120]),.dout(tmp_out[127:120]) );
    sbox q1( .data(data[119:112]),.dout(tmp_out[119:112]) );
    sbox q2( .data(data[111:104]),.dout(tmp_out[111:104]) );
    sbox q3( .data(data[103:96]),.dout(tmp_out[103:96]) );
    
    sbox q4( .data(data[95:88]),.dout(tmp_out[95:88]) );
    sbox q5( .data(data[87:80]),.dout(tmp_out[87:80]) );
    sbox q6( .data(data[79:72]),.dout(tmp_out[79:72]) );
    sbox q7( .data(data[71:64]),.dout(tmp_out[71:64]) );
    
    sbox q8( .data(data[63:56]),.dout(tmp_out[63:56]) );
    sbox q9( .data(data[55:48]),.dout(tmp_out[55:48]) );
    sbox q10(.data(data[47:40]),.dout(tmp_out[47:40]) );
    sbox q11(.data(data[39:32]),.dout(tmp_out[39:32]) );
    
    sbox q12(.data(data[31:24]),.dout(tmp_out[31:24]) );
    sbox q13(.data(data[23:16]),.dout(tmp_out[23:16]) );
    sbox q14(.data(data[15:8]),.dout(tmp_out[15:8]) );
    sbox q15(.data(data[7:0]),.dout(tmp_out[7:0]) );
	  
    always_ff @( posedge clk ) begin 
        s_data_out<=tmp_out;
    end

endmodule
// this testbench is to verify split multiplier is working
//  it includes computing h^2, h^3, h^4, h^5

module top_tb;

  timeunit 1ps;
  timeprecision 1ps;

  //----------------------------------------------------------------------
  // Waveforms.
  //----------------------------------------------------------------------
  initial begin
      $fsdbDumpfile("dump.fsdb");
      $fsdbDumpvars(0, "+all");
  end

  //----------------------------------------------------------------------
  // Generate the clock.
  //----------------------------------------------------------------------
  bit clk;
  initial clk = 1'b1;
  always #5ns clk = ~clk; // Always drive clocks with blocking assignment.

  //----------------------------------------------------------------------
  // Generate the reset.
  //----------------------------------------------------------------------
  bit rst;

  task do_reset();
      rst = 1'b1; // Special case: using a blocking assignment to set rst
                  // to 1'b1 at time 0.

      repeat (4) @(posedge clk); // Wait for 4 clock cycles.

      rst <= 1'b0; // Generally, non-blocking assignments when driving DUT
                  // signals.
  endtask : do_reset

  //----------------------------------------------------------------------
  // Generate dut.
  //----------------------------------------------------------------------
  // input
  logic               start;
  logic   [127:0]     Key_in;
  logic   [127:0]     IV_in;
  int                 IV_byte_len;
  int                 IV_total;
  logic   [127:0]     PText_in;
  int                 PText_byte_len;
  int                 PText_total;
  logic   [127:0]     AAD_in;
  int                 AAD_byte_len;
  int                 AAD_total;    
  logic   [127:0]     H;
  logic   [127:0]     H2;
  logic   [127:0]     H4;
  // output
  logic               IV_req;
  logic               PText_req;
  logic               AAD_req;
  logic   [127:0]     CText;
  logic               CText_valid;
  int                 CText_total;  
  logic   [127:0]     AuthTag;
  logic               AuthTag_valid;
  

  top dut(
    .clk(clk),
    .rst(rst),
    .*
  );

  //----------------------------------------------------------------------
  // Generate testbench.
  //----------------------------------------------------------------------
  initial begin

    do_reset();
    // ----------------------------------------------------------
    // ----------------  test 6  --------------------------------
    // ----------------------------------------------------------
    start           <= 1'b1;
    Key_in          <= 128'hfeffe9928665731c6d6a8f9467308308;

    IV_in           <= 128'h9313225df88406e555909c5aff5269aa;   // first block of IV
    IV_byte_len     <= 16;
    IV_total        <= 4;

    PText_in        <= 128'hd9313225f88406e5a55909c5aff5269a;
    PText_byte_len  <= 16;
    PText_total     <= 4;

    AAD_in          <= 128'hfeedfacedeadbeeffeedfacedeadbeef;
    AAD_byte_len    <= 16;
    AAD_total       <= 2;

    H               <= 128'hb83b533708bf535d0aa6e52980d53b78;
    H2              <= 128'h8a6ff5aca561c0d865805055eb728397;
    H4              <= 128'h3c4b0daa91e6b35f9b9e89d8510dd431;
    fork
      begin
        @(posedge clk);
        start <= 1'b0;
      end
      begin
        @(posedge IV_req);
        @(posedge clk);
        IV_in <= 128'h6a7a9538534f7da1e4c303d2a318a728;    // IV block 2
        IV_byte_len     <= 16;
        @(posedge clk);
        IV_in <= 128'hc3c0c95156809539fcf0e2429a6b5254;    // IV block 3
        IV_byte_len     <= 16;
        @(posedge clk);
        IV_in <= 128'h16aedbf5a0de6a57a637b39b00000000;    // IV block 4
        IV_byte_len     <= 12;
      end
      begin
        @(posedge PText_req);
        @(posedge clk);
        PText_in <= 128'h86a7a9531534f7da2e4c303d8a318a72;    // Plain Text block 2
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'h1c3c0c95956809532fcf0e2449a6b525;    // Plain Text block 3
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'hb16aedf5aa0de657ba637b3900000000;    // Plain Text block 4
        PText_byte_len  <= 12;
      end
      begin
        @(posedge CText_valid);
        @(posedge clk);
        check(128'h8ce24998625615b603a033aca13fb894);
        @(posedge clk);
        check(128'hbe9112a5c3a211a8ba262a3cca7e2ca7);
        @(posedge clk);
        check(128'h01e4a9a4fba43c90ccdcb281d48c7c6f);
        @(posedge clk);
        check(128'hd62875d2aca417034c34aee500000000);
      end
      begin
        @(posedge AAD_req);
        @(posedge clk);
        AAD_in <= 128'habaddad2000000000000000000000000;    // AAD block 2
        AAD_byte_len    <= 4;
      end
      begin
        @(posedge AuthTag_valid);
        @(posedge clk);
        checktag(128'h619cc5aefffe0bfa462af43c1699d050);
      end
    join




    do_reset();
    // ----------------------------------------------------------
    // ----------------  test 5  --------------------------------
    // ----------------------------------------------------------
    start           <= 1'b1;
    Key_in          <= 128'hfeffe9928665731c6d6a8f9467308308;
    IV_in           <= 128'hcafebabefacedbad0000000000000000;   // first block of IV
    IV_byte_len     <= 8;
    IV_total        <= 1;
    PText_in        <= 128'hd9313225f88406e5a55909c5aff5269a;
    PText_byte_len  <= 16;
    PText_total     <= 4;
    AAD_in          <= 128'hfeedfacedeadbeeffeedfacedeadbeef;
    AAD_byte_len    <= 16;
    AAD_total       <= 2;
    H               <= 128'hb83b533708bf535d0aa6e52980d53b78;
    H2              <= 128'h8a6ff5aca561c0d865805055eb728397;
    H4              <= 128'h3c4b0daa91e6b35f9b9e89d8510dd431;
    fork
      begin
        @(posedge clk);
        start <= 1'b0;
      end
      begin
        @(posedge PText_req);
        @(posedge clk);
        PText_in <= 128'h86a7a9531534f7da2e4c303d8a318a72;    // Plain Text block 2
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'h1c3c0c95956809532fcf0e2449a6b525;    // Plain Text block 3
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'hb16aedf5aa0de657ba637b3900000000;    // Plain Text block 4
        PText_byte_len  <= 12;
      end
      begin
        @(posedge CText_valid);
        @(posedge clk);
        check(128'h61353b4c2806934a777ff51fa22a4755);
        @(posedge clk);
        check(128'h699b2a714fcdc6f83766e5f97b6c7423);
        @(posedge clk);
        check(128'h73806900e49f24b22b097544d4896b42);
        @(posedge clk);
        check(128'h4989b5e1ebac0f07c23f459800000000);
      end
      begin
        @(posedge AAD_req);
        @(posedge clk);
        AAD_in <= 128'habaddad2000000000000000000000000;    // AAD block 2
        AAD_byte_len    <= 4;
      end
      begin
        @(posedge AuthTag_valid);
        @(posedge clk);
        checktag(128'h3612d2e79e3b0785561be14aaca2fccb);
      end
    join





    do_reset();
    // ----------------------------------------------------------
    // ----------------  test 4  --------------------------------
    // ----------------------------------------------------------
    start           <= 1'b1;
    Key_in          <= 128'hfeffe9928665731c6d6a8f9467308308;

    IV_in           <= 128'hcafebabefacedbaddecaf88800000000;   // first block of IV
    IV_byte_len     <= 12;
    IV_total        <= 1;

    PText_in        <= 128'hd9313225f88406e5a55909c5aff5269a;
    PText_byte_len  <= 16;
    PText_total     <= 4;

    AAD_in          <= 128'hfeedfacedeadbeeffeedfacedeadbeef;
    AAD_byte_len    <= 16;
    AAD_total       <= 2;

    H               <= 128'hb83b533708bf535d0aa6e52980d53b78;
    H2              <= 128'h8a6ff5aca561c0d865805055eb728397;
    H4              <= 128'h3c4b0daa91e6b35f9b9e89d8510dd431;
    fork
      begin
        @(posedge clk);
        start <= 1'b0;
      end
      begin
        @(posedge PText_req);
        @(posedge clk);
        PText_in <= 128'h86a7a9531534f7da2e4c303d8a318a72;    // Plain Text block 2
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'h1c3c0c95956809532fcf0e2449a6b525;    // Plain Text block 3
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'hb16aedf5aa0de657ba637b3900000000;    // Plain Text block 4
        PText_byte_len  <= 12;
      end
      begin
        @(posedge CText_valid);
        @(posedge clk);
        check(128'h42831ec2217774244b7221b784d0d49c);
        @(posedge clk);
        check(128'he3aa212f2c02a4e035c17e2329aca12e);
        @(posedge clk);
        check(128'h21d514b25466931c7d8f6a5aac84aa05);
        @(posedge clk);
        check(128'h1ba30b396a0aac973d58e09100000000);
      end
      begin
        @(posedge AAD_req);
        @(posedge clk);
        AAD_in <= 128'habaddad2000000000000000000000000;    // AAD block 2
        AAD_byte_len    <= 4;
      end
      begin
        @(posedge AuthTag_valid);
        @(posedge clk);
        checktag(128'h5bc94fbc3221a5db94fae95ae7121a47);
      end
    join





    do_reset();
    // ----------------------------------------------------------
    // ----------------  test 3  --------------------------------
    // ----------------------------------------------------------
    start           <= 1'b1;
    Key_in          <= 128'hfeffe9928665731c6d6a8f9467308308;

    IV_in           <= 128'hcafebabefacedbaddecaf88800000000;   // first block of IV
    IV_byte_len     <= 12;
    IV_total        <= 1;

    PText_in        <= 128'hd9313225f88406e5a55909c5aff5269a;
    PText_byte_len  <= 16;
    PText_total     <= 4;

    AAD_in          <= '0;
    AAD_byte_len    <= 0;
    AAD_total       <= 0;

    H               <= 128'hb83b533708bf535d0aa6e52980d53b78;
    H2              <= 128'h8a6ff5aca561c0d865805055eb728397;
    H4              <= 128'h3c4b0daa91e6b35f9b9e89d8510dd431;
    fork
      begin
        @(posedge clk);
        start <= 1'b0;
      end
      begin
        @(posedge PText_req);
        @(posedge clk);
        PText_in <= 128'h86a7a9531534f7da2e4c303d8a318a72;    // Plain Text block 2
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'h1c3c0c95956809532fcf0e2449a6b525;    // Plain Text block 3
        PText_byte_len  <= 16;
        @(posedge clk);
        PText_in <= 128'hb16aedf5aa0de657ba637b391aafd255;    // Plain Text block 4
        PText_byte_len  <= 16;
      end
      begin
        @(posedge CText_valid);
        @(posedge clk);
        check(128'h42831ec2217774244b7221b784d0d49c);
        @(posedge clk);
        check(128'he3aa212f2c02a4e035c17e2329aca12e);
        @(posedge clk);
        check(128'h21d514b25466931c7d8f6a5aac84aa05);
        @(posedge clk);
        check(128'h1ba30b396a0aac973d58e091473f5985);
      end
      begin
        @(posedge AuthTag_valid);
        @(posedge clk);
        checktag(128'h4d5c2af327cd64a62cf35abd2ba6fab4);
      end
    join






    do_reset();
    // ----------------------------------------------------------
    // ----------------  test 2  --------------------------------
    // ----------------------------------------------------------
    start           <= 1'b1;
    Key_in          <= '0;

    IV_in           <= '0;   // first block of IV
    IV_byte_len     <= 12;
    IV_total        <= 1;

    PText_in        <= '0;
    PText_byte_len  <= 16;
    PText_total     <= 1;

    AAD_in          <= '0;
    AAD_byte_len    <= 0;
    AAD_total       <= 0;

    H               <= 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
    H2              <= 128'ha569901bb4b18906f5059d24465c904d;
    H4              <= 128'hca45ecb9a45ec8a2f256e11f220638b2;
    fork
      begin
        @(posedge clk);
        start <= 1'b0;
      end
      begin
        @(posedge CText_valid);
        @(posedge clk);
        check(128'h0388dace60b6a392f328c2b971b2fe78);
      end
      begin
        @(posedge AuthTag_valid);
        @(posedge clk);
        checktag(128'hab6e47d42cec13bdf53a67b21257bddf);
      end
    join





    do_reset();
    // ----------------------------------------------------------
    // ----------------  test 1  --------------------------------
    // ----------------------------------------------------------
    start           <= 1'b1;
    Key_in          <= '0;

    IV_in           <= '0;   // first block of IV
    IV_byte_len     <= 12;
    IV_total        <= 1;

    PText_in        <= '0;
    PText_byte_len  <= 0;
    PText_total     <= 0;

    AAD_in          <= '0;
    AAD_byte_len    <= 0;
    AAD_total       <= 0;

    H               <= 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
    H2              <= 128'ha569901bb4b18906f5059d24465c904d;
    H4              <= 128'hca45ecb9a45ec8a2f256e11f220638b2;
    fork
      begin
        @(posedge clk);
        start <= 1'b0;
      end
      begin
        @(posedge AuthTag_valid);
        @(posedge clk);
        checktag(128'h58e2fccefa7e3061367f1d57a4e7455a);
      end
    join


    repeat (100) @(posedge clk);
    #10 $finish;
  end

  //----------------------------------------------------------------------
  // Timeout.
  //----------------------------------------------------------------------
  initial begin
      #1s;
      $fatal("Timeout!");
  end


  //----------------------------------------------------------------------
  // Define Task
  //----------------------------------------------------------------------
  task check(input logic [127:0] answer);
    assert(CText === answer)
      $display("\033[1;32m✔ Test PASSED! CIPHER TEXT = %h\033[0m", CText);
    else 
      $error("\033[1;31m✘ Test FAILED! CIPHER TEXT Expected: %h, Got: %h\033[0m", answer, CText);
  endtask

  task checktag(input logic [127:0] answer);
    assert(AuthTag === answer)
      $display("\033[1;32m✔ Test PASSED! AUTH TAG = %h\033[0m", AuthTag);
    else 
      $error("\033[1;31m✘ Test FAILED! AUTH TAG Expected: %h, Got: %h\033[0m", answer, AuthTag);
  endtask

 
endmodule
    



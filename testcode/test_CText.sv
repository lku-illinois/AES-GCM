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
  logic   [127:0]     Key_in;
  logic   [127:0]     IV_in;
  int                 IV_total;
  logic   [127:0]     PText_in;
  int                 PText_byte_len;
  int                 PText_total;
  logic   [127:0]     AAD_in;
  int                 AAD_total;    
  logic   [127:0]     H;
  logic   [127:0]     H2;
  logic   [127:0]     H4;
  // output
  logic               IV_req;
  logic               PText_req;
  logic               AAD_req;
  logic   [127:0]     CText;
  int                 CText_total;   
  

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

    Key_in          <= 128'hfeffe9928665731c6d6a8f9467308308;
    IV_in           <= 128'h9313225df88406e555909c5aff5269aa;   // first block of IV
    IV_total        <= 4;
    PText_in        <= 128'hd9313225f88406e5a55909c5aff5269a;
    PText_byte_len  <= 16;
    PText_total     <= 4;
    AAD_in          <= 128'hfeedfacedeadbeeffeedfacedeadbeef;
    AAD_total       <= 2;
    H               <= 128'hb83b533708bf535d0aa6e52980d53b78;
    H2              <= 128'h8a6ff5aca561c0d865805055eb728397;
    H4              <= 128'h3c4b0daa91e6b35f9b9e89d8510dd431;
    fork
      begin
        @(posedge IV_req);
        @(posedge clk);
        IV_in <= 128'h6a7a9538534f7da1e4c303d2a318a728;    // IV block 2
        @(posedge clk);
        IV_in <= 128'hc3c0c95156809539fcf0e2429a6b5254;    // IV block 3
        @(posedge clk);
        IV_in <= 128'h16aedbf5a0de6a57a637b39b00000000;    // IV block 4
        @(posedge clk);
        IV_in <= 128'h000000000000000000000000000001e0;    // len(IV)
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
      // begin
      //   @(posedge AAD_req);
      //   @(posedge clk);
      //   AAD_in <= 128'habaddad2000000000000000000000000;    // AAD block 2
      // end
    join



    repeat (40) @(posedge clk);
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
  // task check(input logic [127:0] answer);
  //   assert(data_out === answer)
  //     $display("\033[1;32m✔ Test PASSED! FINAL ANSWER = %h\033[0m", data_out);
  //   else 
  //     $error("\033[1;31m✘ Test FAILED! Expected: %h, Got: %h\033[0m", answer, data_out);
  // endtask

 
endmodule
    



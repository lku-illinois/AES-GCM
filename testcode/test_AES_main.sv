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
  logic   [127:0]     data_in;
  logic   [127:0]     key;
  logic   [127:0]     data_out;
  logic               start;
  int                 data_total;
  logic               AES_first_block_finish;
  logic               AES_final_block_finish;
  

  AES_main dut(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .key(key),
    .data_out(data_out),
    .start(start),
    .data_total(data_total),
    .AES_first_block_finish(AES_first_block_finish),
    .AES_final_block_finish(AES_final_block_finish)
  );

  //----------------------------------------------------------------------
  // Generate testbench.
  //----------------------------------------------------------------------
  initial begin
    do_reset();


    // Test 1
    // key <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
    // data_in <= 128'h3243f6a8885a308d313198a2e0370734;
    // data_total <= 1;
    // start <= 1'b1;
    // @(posedge clk);
    // start <= 1'b0;
    // @(posedge AES_first_block_finish);
    // check(128'h3925841d02dc09fbdc118597196a0b32);


    // Test 2
    // SINGLE DATA_IN TESTS
    // // AES NIPS document Apendix B
    // key <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
    // data_in <= 128'h3243f6a8885a308d313198a2e0370734;
    // data_total <= 1;
    // start <= 1'b1;
    // @(posedge clk);
    // start <= 1'b0;
    // @(posedge AES_first_block_finish);
    // check(128'h3925841d02dc09fbdc118597196a0b32);

    // // GCM Spec Test Case 6
    // @(posedge clk);
    // key <= 128'hfeffe9928665731c6d6a8f9467308308;
    // data_in <= 128'h3bab75780a31c059f83d2a44752f9864;
    // data_total <= 1;
    // start <= 1'b1;
    // @(posedge clk);
    // start <= 1'b0;
    // @(posedge AES_first_block_finish);
    // check(128'h7dc63b399f2d98d57ab073b6baa4138e);

    // @(posedge clk);
    // key <= 128'hfeffe9928665731c6d6a8f9467308308;
    // data_in <= 128'h3bab75780a31c059f83d2a44752f9865;
    // data_total <= 1;
    // start <= 1'b1;
    // @(posedge clk);
    // start <= 1'b0;
    // @(posedge AES_first_block_finish);
    // check(128'h55d37bbd9ad21353a6f93a690eca9e0e);

    // @(posedge clk);
    // key <= 128'hfeffe9928665731c6d6a8f9467308308;
    // data_in <= 128'h3bab75780a31c059f83d2a44752f9866;
    // data_total <= 1;
    // start <= 1'b1;
    // @(posedge clk);
    // start <= 1'b0;
    // @(posedge AES_first_block_finish);
    // check(128'h3836bbf6d696e672946a1a01404fa6d5);

    // @(posedge clk);
    // key <= 128'hfeffe9928665731c6d6a8f9467308308;
    // data_in <= 128'h3bab75780a31c059f83d2a44752f9867;
    // data_total <= 1;
    // start <= 1'b1;
    // @(posedge clk);
    // start <= 1'b0;
    // @(posedge AES_first_block_finish);
    // check(128'h1dd8a5316ecc35c3e313bca59d2ac94a);

    // @(posedge clk);
    // key <= 128'hfeffe9928665731c6d6a8f9467308308;
    // data_in <= 128'h3bab75780a31c059f83d2a44752f9868;
    // data_total <= 1;
    // start <= 1'b1;
    // @(posedge clk);
    // start <= 1'b0;
    // @(posedge AES_first_block_finish);
    // check(128'h6742982706a9f154f657d5dc94b746db);
  
    
    // Test 3
    // setup
    key <= 128'hfeffe9928665731c6d6a8f9467308308;
    data_in <= 128'h3bab75780a31c059f83d2a44752f9864;
    data_total <= 5;
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;
    data_in <= 128'h3bab75780a31c059f83d2a44752f9865;
    @(posedge clk);
    data_in <= 128'h3bab75780a31c059f83d2a44752f9866;
    @(posedge clk);
    data_in <= 128'h3bab75780a31c059f83d2a44752f9867;
    @(posedge clk);
    data_in <= 128'h3bab75780a31c059f83d2a44752f9868;
    // check
    @(posedge AES_first_block_finish);
    @(posedge clk);
    check(128'h7dc63b399f2d98d57ab073b6baa4138e);
    @(posedge clk);
    check(128'h55d37bbd9ad21353a6f93a690eca9e0e);
    @(posedge clk);
    check(128'h3836bbf6d696e672946a1a01404fa6d5);
    @(posedge clk);
    check(128'h1dd8a5316ecc35c3e313bca59d2ac94a);
    @(posedge clk);
    check(128'h6742982706a9f154f657d5dc94b746db);




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
  task check(input logic [127:0] answer);
    // repeat (19) @(posedge clk);
    assert(data_out === answer)
      $display("\033[1;32m✔ Test PASSED! FINAL ANSWER = %h\033[0m", data_out);
    else 
      $error("\033[1;31m✘ Test FAILED! Expected: %h, Got: %h\033[0m", answer, data_out);
  endtask

 
endmodule
    



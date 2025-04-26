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
  parameter DATA__WIDTH = 128;
  parameter SPLIT_WIDTH = 32;
  logic                       flush;
  logic   [SPLIT_WIDTH-1:0]   ha_i;   // H[127:96]
  logic   [SPLIT_WIDTH-1:0]   hb_i;   // H[95:64]
  logic   [SPLIT_WIDTH-1:0]   hc_i;   // H[63:32]
  logic   [SPLIT_WIDTH-1:0]   hd_i;   // H[31:0]
  logic   [DATA__WIDTH-1:0]   a_i;    // Choose Ai or Zd or Ai^Zd
  logic   [DATA__WIDTH-1:0]   mul_o;  // Feeds into Zd
  // logic   [DATA__WIDTH-1:0]   AA_o;   // Debug


  split_multiplier #(.DATA__WIDTH(DATA__WIDTH), .SPLIT_WIDTH(SPLIT_WIDTH)) 
  dut (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .ha_i(ha_i),
    .hb_i(hb_i),
    .hc_i(hc_i),
    .hd_i(hd_i),
    .a_i(a_i),
    .mul_o(mul_o)
    // .AA_o(AA_o)
  );

  //----------------------------------------------------------------------
  // Generate testbench.
  //----------------------------------------------------------------------
  initial begin
    do_reset();

    flush_all();
    set_test_values(
      128'h42831ec2217774244b7221b784d0d49c,
      128'hb83b533708bf535d0aa6e52980d53b78
    );
    check(128'h59ed3f2bb1a0aaa07c9f56c6a504647b);

    // h.h
    flush_all();
    set_test_values(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'hb83b533708bf535d0aa6e52980d53b78
    );
    check(128'h8a6ff5aca561c0d865805055eb728397);

    // h2.h
    flush_all();
    set_test_values(
      128'h8a6ff5aca561c0d865805055eb728397,
      128'hb83b533708bf535d0aa6e52980d53b78
    );
    check(128'hc414cb8f1152eb71563a5ca9ddcbddb5);

    // h2.h2
    flush_all();
    set_test_values(
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h8a6ff5aca561c0d865805055eb728397
    );
    check(128'h3c4b0daa91e6b35f9b9e89d8510dd431);

    // h2.h3
    flush_all();
    set_test_values(
      128'h8a6ff5aca561c0d865805055eb728397,
      128'hc414cb8f1152eb71563a5ca9ddcbddb5
    );
    check(128'h423dbfb8033039e6b9cb105cf1d6f3b1);



    repeat (20) @(posedge clk);
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
  task set_test_values(input logic [127:0] h, input logic [127:0] a);
    // Cycle 1: Set ha_i
    a_i <= a;
    ha_i <= h[127:96];
    hb_i <= 0;
    hc_i <= 0;
    hd_i <= 0;
    @(posedge clk);

    // Cycle 2: Set hb_i
    a_i <= 0;
    ha_i <= 0;
    hb_i <= h[95:64];
    hc_i <= 0;
    hd_i <= 0;
    @(posedge clk);

    // Cycle 3: Set hc_i
    a_i <= 0;
    ha_i <= 0;
    hb_i <= 0;
    hc_i <= h[63:32];
    hd_i <= 0;
    @(posedge clk);

    // Cycle 4: Set hd_i
    a_i <= 0;
    ha_i <= 0;
    hb_i <= 0;
    hc_i <= 0;
    hd_i <= h[31:0];
    @(posedge clk);

    a_i <= 0;
    ha_i <= 0;
    hb_i <= 0;
    hc_i <= 0;
    hd_i <= 0;
  endtask

  task flush_all();
    flush <= '1;
    @(posedge clk);
    flush <= '0;
  endtask

  task check(input logic [127:0] answer);
    @(posedge clk);
    assert(mul_o === answer)
      $display("\033[1;32m✔ Test PASSED! mul_o = %h\033[0m", mul_o);
    else 
      $error("\033[1;31m✘ Test FAILED! Expected: %h, Got: %h\033[0m", answer, mul_o);
  endtask

endmodule
    



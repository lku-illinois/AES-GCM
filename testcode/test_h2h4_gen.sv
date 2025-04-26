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
  logic               GHASH_done;
  logic   [127:0]     h1_i;
  logic               h1_valid_i;
  logic   [127:0]     h1;
  logic   [127:0]     h2;
  logic   [127:0]     h4;
  logic               h_valid;

  h2h4_gen dut(
    .clk(clk),
    .rst(rst),
    .GHASH_done(GHASH_done),
    .h1_i(h1_i),
    .h1_valid_i(h1_valid_i),
    .h1(h1),
    .h2(h2),
    .h4(h4),
    .h_valid(h_valid)
  );
  //----------------------------------------------------------------------
  // Generate testbench.
  //----------------------------------------------------------------------
  initial begin
    do_reset();

    test(128'hacbef20579b4b8ebce889bac8732dad7);
    check(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hb94efa0be54358f908c0c7fc88d48db2
    );
    reset();
    
    repeat(5) @(posedge clk);
    test(128'hb83b533708bf535d0aa6e52980d53b78);
    check(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431
    );
    reset();

    repeat(5) @(posedge clk);
    test(128'h466923ec9ae682214f2c082badb39249);
    check(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0
    );
    reset();
    

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
  task test(input logic [127:0] in);
    h1_i <= in;
    h1_valid_i <= '1;
    GHASH_done <= 1'b0;
    repeat (20) @(posedge clk);
    GHASH_done <= 1'b1;
  endtask

  task reset();
    @(posedge clk);
    GHASH_done <= 1'b0;
    h1_valid_i <= '0;
  endtask

  task check(
    input logic [127:0] ans1,
    input logic [127:0] ans2,
    input logic [127:0] ans3
  );
    @(posedge GHASH_done)
    // Check if all three match
    if ((h1 == ans1) && (h2 == ans2) && (h4 == ans3)) begin
        $display("\033[1;32m✔ All correct: h1=%h, h2=%h, h4=%h\033[0m",
                 h1, h2, h4);
    end else begin
        // Check each one individually
        if (h1 != ans1) begin
            $display("\033[1;31m✘ 1st is incorrect: got %h, expected %h\033[0m",
                     h1, ans1);
        end
        if (h2 != ans2) begin
            $display("\033[1;31m✘ 2nd is incorrect: got %h, expected %h\033[0m",
                     h2, ans2);
        end
        if (h4 != ans3) begin
            $display("\033[1;31m✘ 3rd is incorrect: got %h, expected %h\033[0m",
                     h4, ans3);
        end
    end
  endtask
endmodule
    



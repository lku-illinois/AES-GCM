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

  logic   [SPLIT_WIDTH-1:0]   ha_i;   // H[127:96]
  logic   [SPLIT_WIDTH-1:0]   hb_i;   // H[95:64]
  logic   [SPLIT_WIDTH-1:0]   hc_i;   // H[63:32]
  logic   [SPLIT_WIDTH-1:0]   hd_i;   // H[31:0]
  logic   [DATA__WIDTH-1:0]   a_i;    // Choose Ai or Zd or Ai^Zd
  logic   [DATA__WIDTH-1:0]   mul_o;  // Feeds into Zd
  logic   [DATA__WIDTH-1:0]   AA_o;   // Debug


  top #(.DATA__WIDTH(DATA__WIDTH), .SPLIT_WIDTH(SPLIT_WIDTH)) 
  dut (
    .clk(clk),
    .rst(rst),
    .ha_i(ha_i),
    .hb_i(hb_i),
    .hc_i(hc_i),
    .hd_i(hd_i),
    .a_i(a_i),
    .mul_o(mul_o),
    .AA_o(AA_o)
  );

  //----------------------------------------------------------------------
  // Generate testbench.
  //----------------------------------------------------------------------
  initial begin
    do_reset();

    ha_i = 32'h42831ec2;
    hb_i = 32'h21777424;
    hc_i = 32'h4b7221b7;
    hd_i = 32'h84d0d49c;
    a_i = 128'hb83b533708bf535d0aa6e52980d53b78;  // Test value for h_i


    repeat (20) @(posedge clk);
  
    // Print the compute_hh values
    $display("\nFinal Computed HH Values: %h", AA_o);
    $display("\nFinal Multiply Output: %h", mul_o);

    #10 $finish;
  end

  //----------------------------------------------------------------------
  // Timeout.
  //----------------------------------------------------------------------
  initial begin
      #1s;
      $fatal("Timeout!");
  end

    

endmodule
    



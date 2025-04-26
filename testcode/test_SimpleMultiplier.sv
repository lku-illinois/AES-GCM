// this testcode verifies that our multiplier (not split) is working
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
    parameter DATA_WIDTH = 128;

    logic [DATA_WIDTH-1:0] h_i;
  	logic [DATA_WIDTH-1:0] a_i;
  	logic [DATA_WIDTH-1:0] x_o;
  	logic [DATA_WIDTH-1:0] compute_hh_o  [DATA_WIDTH];


    multiplier #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .h_i(h_i),
      	.a_i(a_i),
      	.x_o(x_o),
      	.compute_hh_o(compute_hh_o)
    );

    //----------------------------------------------------------------------
    // Generate testbench.
    //----------------------------------------------------------------------
    initial begin
        do_reset();

        a_i = 128'hb83b533708bf535d0aa6e52980d53b78;  // Test value for h_i
      	h_i = 128'h42831ec2217774244b7221b784d0d49c;

        #20;
      
        // Print the compute_hh values
        $display("\nComputed HH Values:");
        for (int i = 0; i < DATA_WIDTH; i++) begin
          	$display("compute_hh[%0d] = %h", i, compute_hh_o[i]);
        end
      	$display("x_o: %h",x_o);

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
    



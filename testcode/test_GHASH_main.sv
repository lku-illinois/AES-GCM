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
  int                 input_num;
  logic               start;
  logic               busy;
  logic               error_o;
  logic   [127:0]     h1;
  logic   [127:0]     h2;
  logic   [127:0]     h4;
  logic               h_valid;
  logic   [127:0]     A_i;
  logic   [127:0]     XI_o; 
  logic               GHASH_done;
  logic               A_req;
  

  GHASH_main dut(
    .clk(clk),
    .rst(rst),
    .input_num(input_num),
    .start(start),
    .busy(busy),
    .error_o(error_o),
    .h1(h1),
    .h2(h2),
    .h4(h4),
    .h_valid(h_valid),
    .A_req(A_req),
    .A_i(A_i),
    .XI_o(XI_o), 
    .GHASH_done(GHASH_done)
  );

  //----------------------------------------------------------------------
  // Generate testbench.
  //----------------------------------------------------------------------
  initial begin
    do_reset();

    test_one_input();
    test_two_input();
    test_three_input();
    test_four_input();
    test_five_input();
    test_six_input();
    test_seven_input();

    // test 6 IV to genrate Y0
    five_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'h9313225df88406e555909c5aff5269aa,
      128'h6a7a9538534f7da1e4c303d2a318a728,
      128'hc3c0c95156809539fcf0e2429a6b5254,
      128'h16aedbf5a0de6a57a637b39b00000000,
      128'h000000000000000000000000000001e0
    );
    check(128'h3bab75780a31c059f83d2a44752f9864);
    

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


  task one_input(input logic [127:0] h1_input, input logic [127:0] A_input);
    input_num <= 1;
    start <= '1;
    h_valid  <= '1;
    h1 <= h1_input;
    h2 <= '0;
    h4 <= '0;
    fork
      begin
          @(posedge A_req);     
          @(posedge clk);
          A_i <= A_input;    
      end
      begin
        @(posedge busy);
        @(posedge clk);
        input_num <= 0;
        start <= '0;
      end
    join
  endtask

  task two_input(input logic [127:0] h1_input, input logic [127:0] h2_input, input logic [127:0] A_input1, input logic [127:0] A_input2);
    input_num <= 2;
    start <= '1;
    h_valid  <= '1;
    h1 <= h1_input;
    h2 <= h2_input;
    h4 <= '0;
    fork
      begin
        @(posedge A_req);     
        @(posedge clk);
        A_i <= A_input1;
        @(posedge clk);
        A_i <= A_input2;
      end
      begin
        @(posedge busy);
        @(posedge clk);
        input_num <= 0;
        start <= '0;
      end
    join
  endtask

  task three_input(input logic [127:0] h1_input, input logic [127:0] h2_input, input logic [127:0] A_input1, input logic [127:0] A_input2, input logic [127:0] A_input3);
    input_num <= 3;
    start <= '1;
    h_valid  <= '1;
    h1 <= h1_input;
    h2 <= h2_input;
    h4 <= '0;
    fork
      begin
        @(posedge A_req);     
        @(posedge clk);
        A_i <= A_input1;
        @(posedge clk);
        A_i <= A_input2;
        @(posedge clk);
        A_i <= A_input3;
      end
      begin
        @(posedge busy);
        @(posedge clk);
        input_num <= 0;
        start <= '0;
      end
    join
  endtask

  task four_input(input logic [127:0] h1_input, input logic [127:0] h2_input, input logic [127:0] h4_input, 
    input logic [127:0] A_input1, input logic [127:0] A_input2, input logic [127:0] A_input3, input logic [127:0] A_input4);
    input_num <= 4;
    start <= '1;
    h_valid  <= '1;
    h1 <= h1_input;
    h2 <= h2_input;
    h4 <= h4_input;
    fork
      begin
        @(posedge A_req);     
        @(posedge clk);
        A_i <= A_input1;
        @(posedge clk);
        A_i <= A_input2;
        @(posedge clk);
        A_i <= A_input3;
        @(posedge clk);
        A_i <= A_input4;
      end
      begin
        @(posedge busy);
        @(posedge clk);
        input_num <= 0;
        start <= '0;
      end
    join
  endtask

  task five_input(input logic [127:0] h1_input, input logic [127:0] h2_input, input logic [127:0] h4_input, 
    input logic [127:0] A_input1, input logic [127:0] A_input2, input logic [127:0] A_input3, input logic [127:0] A_input4, input logic [127:0] A_input5);
    input_num <= 5;
    start <= '1;
    h1 <= h1_input;
    h_valid  <= '1;
    h1 <= h1_input;
    h2 <= h2_input;
    h4 <= h4_input;
    fork
      begin
        @(posedge A_req);     
        @(posedge clk);
        A_i <= A_input1;
        @(posedge clk);
        A_i <= A_input2;
        @(posedge clk);
        A_i <= A_input3;
        @(posedge clk);
        A_i <= A_input4;
        @(posedge clk);
        A_i <= A_input5;
      end
      begin
        @(posedge busy);
        @(posedge clk);
        input_num <= 0;
        start <= '0;
      end
    join
  endtask

  task six_input(input logic [127:0] h1_input, input logic [127:0] h2_input, input logic [127:0] h4_input, 
    input logic [127:0] A_input1, input logic [127:0] A_input2, input logic [127:0] A_input3, input logic [127:0] A_input4, input logic [127:0] A_input5, input logic [127:0] A_input6);
    input_num <= 6;
    start <= '1;
    h1 <= h1_input;
    h_valid  <= '1;
    h1 <= h1_input;
    h2 <= h2_input;
    h4 <= h4_input;
    fork
      begin
        @(posedge A_req);     
        @(posedge clk);
        A_i <= A_input1;
        @(posedge clk);
        A_i <= A_input2;
        @(posedge clk);
        A_i <= A_input3;
        @(posedge clk);
        A_i <= A_input4;
        @(posedge clk);
        A_i <= A_input5;
        @(posedge clk);
        A_i <= A_input6;
      end
      begin
        @(posedge busy);
        @(posedge clk);
        input_num <= 0;
        start <= '0;
      end
    join
  endtask

  task seven_input(input logic [127:0] h1_input, input logic [127:0] h2_input, input logic [127:0] h4_input, 
    input logic [127:0] A_input1, input logic [127:0] A_input2, input logic [127:0] A_input3, input logic [127:0] A_input4, input logic [127:0] A_input5, input logic [127:0] A_input6, input logic [127:0] A_input7);
    input_num <= 7;
    start <= '1;
    h1 <= h1_input;
    h_valid  <= '1;
    h1 <= h1_input;
    h2 <= h2_input;
    h4 <= h4_input;
    fork
      begin
        @(posedge A_req);     
        @(posedge clk);
        A_i <= A_input1;
        @(posedge clk);
        A_i <= A_input2;
        @(posedge clk);
        A_i <= A_input3;
        @(posedge clk);
        A_i <= A_input4;
        @(posedge clk);
        A_i <= A_input5;
        @(posedge clk);
        A_i <= A_input6;
        @(posedge clk);
        A_i <= A_input7;
      end
      begin
        @(posedge busy);
        @(posedge clk);
        input_num <= 0;
        start <= '0;
      end
    join
  endtask

  task check(input logic [127:0] answer);
    @(posedge GHASH_done);
    @(posedge clk);
    h_valid <= '0;
    assert(XI_o === answer)
      $display("\033[1;32m✔ Test PASSED! FINAL ANSWER = %h\033[0m", XI_o);
    else 
      $error("\033[1;31m✘ Test FAILED! Expected: %h, Got: %h\033[0m", answer, XI_o);
  endtask

  task test_one_input();
    $display("Test W/ One Input");
    one_input(
      128'h42831ec2217774244b7221b784d0d49c,
      128'hb83b533708bf535d0aa6e52980d53b78
    );
    check(128'h59ed3f2bb1a0aaa07c9f56c6a504647b);

    repeat (10) @(posedge clk);
    one_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'hb83b533708bf535d0aa6e52980d53b78
    );
    check(128'h8a6ff5aca561c0d865805055eb728397);

    repeat (10) @(posedge clk);
    one_input(
      128'h8a6ff5aca561c0d865805055eb728397,
      128'hb83b533708bf535d0aa6e52980d53b78
    );
    check(128'hc414cb8f1152eb71563a5ca9ddcbddb5);

    repeat (10) @(posedge clk);
    one_input(
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h8a6ff5aca561c0d865805055eb728397
    );
    check(128'h3c4b0daa91e6b35f9b9e89d8510dd431);

    repeat (10) @(posedge clk);
    one_input(
      128'h8a6ff5aca561c0d865805055eb728397,
      128'hc414cb8f1152eb71563a5ca9ddcbddb5
    );
    check(128'h423dbfb8033039e6b9cb105cf1d6f3b1);
  endtask

  task test_two_input();
    $display("Test W/ Two Input");
    two_input(
      // h1
      128'h66e94bd4ef8a2c3b884cfa59ca342b2e,
      // h2
      128'ha569901bb4b18906f5059d24465c904d,
      // a1
      128'h0388dace60b6a392f328c2b971b2fe78,
      // a2
      128'h00000000000000000000000000000080
    );
    check(128'hf38cbb1ad69223dcc3457ae5b6b0f885);

    repeat (10) @(posedge clk);
    two_input(
      // h1
      128'haae06992acbf52a3e8f4a96ec9300bd7,
      // h2
      128'hd5917cec8770308f0102033e22e4c6fb,
      // a1
      128'h98e7247c07f0fe411c267e4384b0f600,
      // a2
      128'h00000000000000000000000000000080
    );
    check(128'he2c63f0ac44ad0e02efa05ab6743d4ce);

    repeat (10) @(posedge clk);
    two_input(
      // h1
      128'hdc95c078a2408989ad48a21492842087,
      // h2
      128'hc7c27e834f1e393c2a82d138ce9261b7,
      // a1
      128'hcea7403d4d606b6e074ec5d3baf39d18,
      // a2
      128'h00000000000000000000000000000080
    );
    check(128'h83de425c5edc5d498f382c441041ca92);

    repeat (10) @(posedge clk);
    // test3
    two_input(
      // h1
      128'hb83b533708bf535d0aa6e52980d53b78,
      // h2
      128'h8a6ff5aca561c0d865805055eb728397,
      // c1
      128'h42831ec2217774244b7221b784d0d49c,
      // c2
      128'he3aa212f2c02a4e035c17e2329aca12e
    );
    // x2
    check(128'hb714c9048389afd9f9bc5c1d4378e052);
  endtask

  task test_three_input();
    $display("Test W/ Three Input");
    three_input(
        128'hb83b533708bf535d0aa6e52980d53b78,
        128'h8a6ff5aca561c0d865805055eb728397,
        128'h42831ec2217774244b7221b784d0d49c,
        128'he3aa212f2c02a4e035c17e2329aca12e,
        128'h21d514b25466931c7d8f6a5aac84aa05
      );
    check(128'h47400c6577b1ee8d8f40b2721e86ff10);

    three_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h42831ec2217774244b7221b784d0d49c
    );
    check(128'h54f5e1b2b5a8f9525c23924751a3ca51);

    three_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h3980ca0b3c00e841eb06fac4872a2757,
      128'h859e1ceaa6efd984628593b40ca1e19c,
      128'h7d773d00c144c525ac619d18c84a3f47
    );
    check(128'he67592048dd7153973a0dbbb8804bee2);

    three_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h3980ca0b3c00e841eb06fac4872a2757
    );
    check(128'h714f9700ddf520f20695f6180c6e669d);

    three_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'h522dc1f099567d07f47f37a32a84427d,
      128'h643a8cdcbfe5c0c97598a2bd2555d1aa,
      128'h8cb08e48590dbb3da7b08b1056828838
    );
    check(128'h45fad9deeda9ea561b8f199c3613845b);

    three_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h522dc1f099567d07f47f37a32a84427d
    );
    check(128'habe07e0bb62354177480b550f9f6cdcc);
  endtask

  task test_four_input();
    $display("Test W/ Four Input");
    four_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'h42831ec2217774244b7221b784d0d49c,
      128'he3aa212f2c02a4e035c17e2329aca12e,
      128'h21d514b25466931c7d8f6a5aac84aa05,
      128'h1ba30b396a0aac973d58e091473f5985
    );
    check(128'h4796cf49464704b5dd91f159bb1b7f95);

    four_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h42831ec2217774244b7221b784d0d49c,
      128'he3aa212f2c02a4e035c17e2329aca12e
    );
    check(128'h324f585c6ffc1359ab371565d6c45f93);

    four_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'h3980ca0b3c00e841eb06fac4872a2757,
      128'h859e1ceaa6efd984628593b40ca1e19c,
      128'h7d773d00c144c525ac619d18c84a3f47,
      128'h18e2448b2fe324d9ccda2710acade256
    );
    check(128'h503e86628536625fb746ce3cecea433f);

    four_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h3980ca0b3c00e841eb06fac4872a2757,
      128'h859e1ceaa6efd984628593b40ca1e19c
    );
    check(128'he858680b7b240d2ecf7e06bbad4524e2);

    four_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hb94efa0be54358f908c0c7fc88d48db2,
      128'h522dc1f099567d07f47f37a32a84427d,
      128'h643a8cdcbfe5c0c97598a2bd2555d1aa,
      128'h8cb08e48590dbb3da7b08b1056828838,
      128'hc5f61e6393ba7a0abcc9f662898015ad
    );
    check(128'hed95f8e164bf3213febc740f0bd9c6af);
  endtask

  task test_five_input();
    $display("Test W/ Five Input");
    five_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'h42831ec2217774244b7221b784d0d49c,
      128'he3aa212f2c02a4e035c17e2329aca12e,
      128'h21d514b25466931c7d8f6a5aac84aa05,
      128'h1ba30b396a0aac973d58e091473f5985,
      128'h00000000000000000000000000000200
    );
    check(128'h7f1b32b81b820d02614f8895ac1d4eac);

    five_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h42831ec2217774244b7221b784d0d49c,
      128'he3aa212f2c02a4e035c17e2329aca12e,
      128'h21d514b25466931c7d8f6a5aac84aa05
    );
    check(128'hca7dd446af4aa70cc3c0cd5abba6aa1c);

    five_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'h3980ca0b3c00e841eb06fac4872a2757,
      128'h859e1ceaa6efd984628593b40ca1e19c,
      128'h7d773d00c144c525ac619d18c84a3f47,
      128'h18e2448b2fe324d9ccda2710acade256,
      128'h00000000000000000000000000000200
    );
    check(128'h51110d40f6c8fff0eb1ae33445a889f0);

    five_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h3980ca0b3c00e841eb06fac4872a2757,
      128'h859e1ceaa6efd984628593b40ca1e19c,
      128'h7d773d00c144c525ac619d18c84a3f47
    );
    check(128'h3f4865abd6bb3fb9f5c4a816f0a9b778);

    five_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hb94efa0be54358f908c0c7fc88d48db2,
      128'h522dc1f099567d07f47f37a32a84427d,
      128'h643a8cdcbfe5c0c97598a2bd2555d1aa,
      128'h8cb08e48590dbb3da7b08b1056828838,
      128'hc5f61e6393ba7a0abcc9f662898015ad,
      128'h00000000000000000000000000000200
    );
    check(128'h4db870d37cb75fcb46097c36230d1612);
  endtask

  task test_six_input();
    $display("Test W/ Six Input");
    six_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h42831ec2217774244b7221b784d0d49c,
      128'he3aa212f2c02a4e035c17e2329aca12e,
      128'h21d514b25466931c7d8f6a5aac84aa05,
      128'h1ba30b396a0aac973d58e09100000000
    );
    check(128'h1590df9b2eb6768289e57d56274c8570);

    six_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h61353b4c2806934a777ff51fa22a4755,
      128'h699b2a714fcdc6f83766e5f97b6c7423,
      128'h73806900e49f24b22b097544d4896b42,
      128'h4989b5e1ebac0f07c23f459800000000
    );
    check(128'h08c873f1c8cec3effc209a07468caab1);

    six_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h8ce24998625615b603a033aca13fb894,
      128'hbe9112a5c3a211a8ba262a3cca7e2ca7,
      128'h01e4a9a4fba43c90ccdcb281d48c7c6f,
      128'hd62875d2aca417034c34aee500000000
    );
    check(128'h0694c6f16bb0275a48891d06590344b0);

    six_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h3980ca0b3c00e841eb06fac4872a2757,
      128'h859e1ceaa6efd984628593b40ca1e19c,
      128'h7d773d00c144c525ac619d18c84a3f47,
      128'h18e2448b2fe324d9ccda271000000000
    );
    check(128'h4256f67fe87b4f49422ba11af857c973);

    six_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h0f10f599ae14a154ed24b36e25324db8,
      128'hc566632ef2bbb34f8347280fc4507057,
      128'hfddc29df9a471f75c66541d4d4dad1c9,
      128'he93a19a58e8b473fa0f062f700000000
    );
    check(128'h8532826e63ce4a5b89b70fa28f8070fe);

    six_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'hd27e88681ce3243c4830165a8fdcf9ff,
      128'h1de9a1d8e6b447ef6ef7b79828666e45,
      128'h81e79012af34ddd9e2f037589b292db3,
      128'he67c036745fa22e7e9b7373b00000000
    );
    check(128'h65233cbe5251f7d246bfc967a8678647);

    six_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hb94efa0be54358f908c0c7fc88d48db2,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h522dc1f099567d07f47f37a32a84427d,
      128'h643a8cdcbfe5c0c97598a2bd2555d1aa,
      128'h8cb08e48590dbb3da7b08b1056828838,
      128'hc5f61e6393ba7a0abcc9f66200000000
    );
    check(128'h9249beaf520c48b912fa120bbf391dc8);

    six_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hb94efa0be54358f908c0c7fc88d48db2,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'hc3762df1ca787d32ae47c13bf19844cb,
      128'haf1ae14d0b976afac52ff7d79bba9de0,
      128'hfeb582d33934a4f0954cc2363bc73f78,
      128'h62ac430e64abe499f47c9b1f00000000
    );
    check(128'h2378943c034697f72a80fce5059bf3f3);
  endtask

  task test_seven_input();
    $display("Test W/ Seven Input");
    seven_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h42831ec2217774244b7221b784d0d49c,
      128'he3aa212f2c02a4e035c17e2329aca12e,
      128'h21d514b25466931c7d8f6a5aac84aa05,
      128'h1ba30b396a0aac973d58e09100000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'h698e57f70e6ecc7fd9463b7260a9ae5f);

    seven_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h61353b4c2806934a777ff51fa22a4755,
      128'h699b2a714fcdc6f83766e5f97b6c7423,
      128'h73806900e49f24b22b097544d4896b42,
      128'h4989b5e1ebac0f07c23f459800000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'hdf586bb4c249b92cb6922877e444d37b);

    seven_input(
      128'hb83b533708bf535d0aa6e52980d53b78,
      128'h8a6ff5aca561c0d865805055eb728397,
      128'h3c4b0daa91e6b35f9b9e89d8510dd431,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h8ce24998625615b603a033aca13fb894,
      128'hbe9112a5c3a211a8ba262a3cca7e2ca7,
      128'h01e4a9a4fba43c90ccdcb281d48c7c6f,
      128'hd62875d2aca417034c34aee500000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'h1c5afe9760d3932f3c9a878aac3dc3de);

    seven_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h3980ca0b3c00e841eb06fac4872a2757,
      128'h859e1ceaa6efd984628593b40ca1e19c,
      128'h7d773d00c144c525ac619d18c84a3f47,
      128'h18e2448b2fe324d9ccda271000000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'hed2ce3062e4a8ec06db8b4c490e8a268);

    seven_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h0f10f599ae14a154ed24b36e25324db8,
      128'hc566632ef2bbb34f8347280fc4507057,
      128'hfddc29df9a471f75c66541d4d4dad1c9,
      128'he93a19a58e8b473fa0f062f700000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'h1e6a133806607858ee80eaf237064089);

    seven_input(
      128'h466923ec9ae682214f2c082badb39249,
      128'hfeb4f24b48eba65cf94280b1f68220a0,
      128'h7e9e366e5b08cc1d706219849638cdb0,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'hd27e88681ce3243c4830165a8fdcf9ff,
      128'h1de9a1d8e6b447ef6ef7b79828666e45,
      128'h81e79012af34ddd9e2f037589b292db3,
      128'he67c036745fa22e7e9b7373b00000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'h82567fb0b4cc371801eadec005968e94);

    seven_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hb94efa0be54358f908c0c7fc88d48db2,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'h522dc1f099567d07f47f37a32a84427d,
      128'h643a8cdcbfe5c0c97598a2bd2555d1aa,
      128'h8cb08e48590dbb3da7b08b1056828838,
      128'hc5f61e6393ba7a0abcc9f66200000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'h8bd0c4d8aacd391e67cca447e8c38f65);

    seven_input(
      128'hacbef20579b4b8ebce889bac8732dad7,
      128'hdb9f3b4948607beb8bb753ba40ab627b,
      128'hb94efa0be54358f908c0c7fc88d48db2,
      128'hfeedfacedeadbeeffeedfacedeadbeef,
      128'habaddad2000000000000000000000000,
      128'hc3762df1ca787d32ae47c13bf19844cb,
      128'haf1ae14d0b976afac52ff7d79bba9de0,
      128'hfeb582d33934a4f0954cc2363bc73f78,
      128'h62ac430e64abe499f47c9b1f00000000,
      128'h00000000000000a000000000000001e0
    );
    check(128'h75a34288b8c68f811c52b2e9a2f97f63);
  endtask
endmodule
    



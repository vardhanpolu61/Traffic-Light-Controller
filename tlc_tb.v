// Code your testbench here
`timescale 1ns / 1ps

module tlc_tb;

  reg x, clr, clk;
  wire [1:0] hwy, ctrd;

  // DUT instantiation
  tlc dut (x, clr, hwy, ctrd, clk);

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Stimulus
  initial begin
    clr = 1;
    x   = 0;

    #2  clr = 0;
    #3  x   = 0;
    #10 x   = 1;
    #70 x   = 0;
    #100 x  = 1;
    #100 x   = 0;

    #1000 $finish;
  end

  // Waveform dump
  initial begin
    $dumpfile("tlc_tb.vcd");
    $dumpvars(0, tlc_tb);
  end

  // Monitor present state and next state
  initial begin
    $monitor(
      "Time=%0t | clk=%b clr=%b x=%b | PS=%b NS=%b | hwy=%b ctrd=%b",
      $time, clk, clr, x,
      dut.state, dut.next_state,
      hwy, ctrd
    );
  end

endmodule

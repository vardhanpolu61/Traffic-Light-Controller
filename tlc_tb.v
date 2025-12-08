`timescale 1ns / 1ps
module tlc_tb;
reg x,clr,clk;
wire [1:0]hwy,ctrd;
tlc dut(x,clr,hwy,ctrd,clk);
initial begin
clk=0;
forever #5 clk=~clk;
end
initial
begin
#0 clr=1;
#2 clr=0;
#3 x=0;
#10 x=1;
#50 x=0;
#100 x=1;
#20 x=0;
#1000 $finish;
end
endmodule

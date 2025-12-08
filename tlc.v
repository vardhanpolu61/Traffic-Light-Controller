`timescale 1ns / 1ps
module tlc(x,clr,hwy,ctrd,clk);
input x,clr,clk;
output reg [1:0]hwy,ctrd;
reg [1:0]state,next_state;
parameter s0=2'd0,s1=2'd1,s2=2'd2,s3=2'd3;
parameter r=2'b00,g=2'b01,y=2'b10;
parameter y2r=5;
initial begin
state=s0;
next_state=s0;
hwy=g;
ctrd=r;
end
always@(state or clr or x)
begin
if(clr)
next_state=s0;
else
begin
case(state)
s0:next_state=x?s1:s0;
s1:begin
repeat(y2r)@(posedge clk);
next_state=s2;
end
s2:next_state=x?s2:s3;
s3:begin
repeat(y2r)@(posedge clk)
next_state=s0;
end
endcase
end
end
always@(posedge clk)
begin
state<=next_state;
end
always@(state)
begin
case(state)
s0:begin
hwy=g;
ctrd=r;
end
s1:begin
hwy=y;
ctrd=r;
end
s2:begin
hwy=r;
ctrd=g;
end
s3:begin
hwy=r;
ctrd=y;
end
endcase
end
endmodule

`timescale 1ns / 1ps
module mips32_pl(clk1,clk2);
input clk1,clk2;
reg [31:0]PC,IF_ID_IR,IF_ID_NPC;
reg [31:0]ID_EX_IR,ID_EX_NPC,ID_EX_A,ID_EX_B,ID_EX_imm;
reg [2:0]ID_EX_type,EX_MEM_type,MEM_WB_type;
reg [31:0]EX_MEM_IR,EX_MEM_ALUout,EX_MEM_B;
reg EX_MEM_cond;
reg [31:0]MEM_WB_IR,MEM_WB_ALUout,MEM_WB_LMD;
reg Halted;
reg Branch_taken;
parameter Add=6'd0,Sub=6'd1,And=6'd2,Or=6'd3,
          Slt=6'd4,Mul=6'd5,Load=6'd6,Store=6'd9,
          Addi=6'd10,Subi=6'd11,Slti=6'd12,
          bneqz=6'd13,beqz=6'd14,
          Hlt=6'd63;
parameter reg_reg=3'd0,reg_imm=3'd1,mem_load=3'd2,mem_store=3'd3,branch=3'd4,halt=3'd5;
reg [31:0]REG[0:31];
reg [31:0]MEM[0:1023];
//IF stage
always@(posedge clk1)
if(Halted==0)
begin
if(((EX_MEM_IR[31:26]==beqz)&&(EX_MEM_cond==0))||((EX_MEM_IR[31:26]==bneqz)&&(EX_MEM_cond==1)))
begin
IF_ID_IR     <=#2 MEM[EX_MEM_ALUout];
Branch_taken <=#2 1'b1;
IF_ID_NPC    <=#2 EX_MEM_ALUout+1;
PC           <=#2 EX_MEM_ALUout+1;
end
else
begin
IF_ID_IR     <=#2 MEM[PC];
IF_ID_NPC    <=#2 PC+1;
PC           <=#2 PC+1;
end
end
//ID stage
always@(posedge clk2)
if(Halted==0)
begin
if(IF_ID_IR[25:21]==5'd0)  ID_EX_A   <=0;
else ID_EX_A   <=#2 REG[IF_ID_IR[25:21]];//rs
if(IF_ID_IR[20:16]==5'd0) ID_EX_B<=0;
else                      ID_EX_B<=REG[IF_ID_IR[20:16]]; //rt
ID_EX_imm <=#2 {{16{IF_ID_IR[15]}},IF_ID_IR[15:0]};
ID_EX_IR  <=#2 IF_ID_IR;
ID_EX_NPC <=#2 IF_ID_NPC;
case(IF_ID_IR[31:26])
Add,Sub,And,Or,Slt,Mul:ID_EX_type <=#2 reg_reg;
Addi,Subi,Slti:        ID_EX_type <=#2 reg_imm;
Load:      ID_EX_type<=#2 mem_load;
Store:     ID_EX_type<=#2 mem_store;
beqz,bneqz:ID_EX_type<=#2 branch;
Hlt:       ID_EX_type<=#2 halt;
default:   ID_EX_type<=#2 halt;//invalid opcode
endcase
end
//EX STAGE
always@(posedge clk1)
if(Halted==0)
begin
EX_MEM_type <=#2ID_EX_type;
EX_MEM_IR   <=#2 ID_EX_IR;
Branch_taken <=#2 0;
case(ID_EX_type)
reg_reg:begin
case(ID_EX_IR[31:26])//opcode
Add:EX_MEM_ALUout<=#2 ID_EX_A +ID_EX_B;
Sub:EX_MEM_ALUout<=#2 ID_EX_A -ID_EX_B;
Mul:EX_MEM_ALUout<=#2 ID_EX_A *ID_EX_B;
Slt:EX_MEM_ALUout<=#2 ID_EX_A < ID_EX_B;
And:EX_MEM_ALUout<=#2 ID_EX_A & ID_EX_B;
Or:EX_MEM_ALUout<=#2 ID_EX_A | ID_EX_B;
default: EX_MEM_ALUout<=#2 32'hxxxxxxxx;
endcase
end
reg_imm:begin
case(ID_EX_IR[31:26])
Addi:EX_MEM_ALUout<=#2 ID_EX_A + ID_EX_imm;
Subi:EX_MEM_ALUout<=#2 ID_EX_A - ID_EX_imm;
Mul:EX_MEM_ALUout<=#2 ID_EX_A * ID_EX_imm;
Slti:EX_MEM_ALUout<=#2 ID_EX_A < ID_EX_imm;
default: EX_MEM_ALUout<=#2 32'hxxxxxxxx;
endcase
end
mem_load,mem_store:begin
EX_MEM_ALUout<=#2 ID_EX_A+ID_EX_imm;
EX_MEM_B<=#2 ID_EX_B;
end
branch:begin
EX_MEM_ALUout<=#2 ID_EX_NPC+ID_EX_imm;
EX_MEM_cond<=#2 (ID_EX_A==0);
end
endcase
end
//MEM STAGE
always@(posedge clk2)
if(Halted==0)
begin
MEM_WB_type<=#2 EX_MEM_type;
MEM_WB_IR<=#2 EX_MEM_IR;
case(EX_MEM_type)
reg_reg,reg_imm:MEM_WB_ALUout<=#2 EX_MEM_ALUout;
mem_load:MEM_WB_LMD<=#2 MEM[EX_MEM_ALUout];
mem_store:if(Branch_taken==0)//Disable write
MEM[EX_MEM_ALUout]<=#2 EX_MEM_B;
endcase
end
//WB STAGE
always@(posedge clk1)
begin
if(Branch_taken==0)//disable write if branch taken
case(MEM_WB_type)
reg_reg:REG[MEM_WB_IR[15:11]]<= #2 MEM_WB_ALUout;//rd
reg_imm:REG[MEM_WB_IR[20:16]]<= #2 MEM_WB_ALUout;//rt
mem_load:REG[MEM_WB_IR[20:16]]<= #2 MEM_WB_LMD;//rt
halt:Halted<=#2 1'b1;
endcase
end
endmodule

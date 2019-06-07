module ARM(
    input CLK,
    input RESET,
    //input Interrupt,  // for optional future use
    input [31:0] Instr,
    input [31:0] ReadData,
    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
    );
    
    // RegFile signals
    //wire CLK ;
    wire WE3 ;
    wire [3:0] A1 ;
    wire [3:0] A2 ;
    wire [3:0] A3 ;
    wire [31:0] WD3 ;
    wire [31:0] R15 ;
    wire [31:0] RD1 ;
    wire [31:0] RD2 ;
    
    // Extend Module signals
    wire [1:0] ImmSrc ;
    reg [23:0] InstrImm ;
    wire [31:0] ExtImm ;
    
    // Decoder signals
    wire [3:0] Rd ;
    wire [1:0] Op ;
    wire [5:0] Funct ;
    //wire PCS ;
    //wire RegW ;
    //wire MemW ;
    wire MemtoReg ;
    wire ALUSrc ;
    wire [1:0] RegSrc ;
    //wire [1:0] ALUControl ;
    //wire [1:0] FlagW ;
    
    // CondLogic signals
    //wire CLK ;
    wire PCS ;
    wire RegW ;
    wire MemW ;
    wire [1:0] FlagW ;
    wire [3:0] Cond ;
    //wire [3:0] ALUFlags,
    wire PCSrc ;
    wire RegWrite ; 
    //wire MemWrite
       
    // Shifter signals
    reg [1:0] Sh ;
    reg [4:0] Shamt5 ;
    wire [31:0] ShIn ;
    wire [31:0] ShOut ;
    
    // ALU signals
    wire [31:0] Src_A ;
    wire [31:0] Src_B ;
    wire [31:0] Src_B1;
    wire [2:0] ALUControl ;
    //wire [31:0] ALUResult ;
    wire [3:0] ALUFlags ;
    wire done;
    
    // ProgramCounter signals
    //wire CLK ;
    //wire RESET ;
    wire WE_PC ;    
    
            
     //wire [31:0] PC ; 
    // Other internal signals here
    wire [31:0] PCPlus4 ;
    wire [31:0] PCPlus8 ;
    //wire [31:0] Result ;
    wire [31:0]PC_IN;
    //MCyle wire
             wire [1:0]MCycleOp;
             reg Start1;
             wire [3:0]Operand1;
             wire [3:0]Operand2;
             wire busy;
             wire Start ;
             wire [4:0]count;
             wire [7:0]Result1;
    // datapath connections here
        assign WE_PC = ( ( (Instr[27:20] == 0) || (Instr[21:20] == 2'b10) ) & ( Instr[7:4] == 4'b1001 ) & busy) ? 1'b0 : 1'b1; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.
        assign Cond[3:0] = Instr[31:28];
        assign Op[1:0] = Instr[27:26];
        assign Rd[3:0] = Instr[15:12];       
        assign Funct[5:0] = Instr[25:20];
        assign A1[3:0] = RegSrc[0]? 4'd15 : Start1 ? Instr[11:8]:Instr[19:16];
        assign A3[3:0] = Instr[15:12];
        assign A2[3:0] = RegSrc[1] ? Rd[3:0] : Instr[3:0];
        assign Src_A[31:0] = RD1[31:0];
        assign Operand1[3:0] = Start1 ? Src_A[31:0] : 3'b000;
        assign WD3 = MemtoReg? ReadData[31:0]:ALUResult[31:0];
        assign WriteData[31:0] = Start ? Result1[7:0] : WD3[31:0];
        assign WE3 = 1;
        assign PCPlus4 = PC + 4;
        assign PC_IN = PCSrc ? WD3 : PCPlus4;
        assign PCPlus8 = PCPlus4 + 4;
        assign R15 = PCPlus8;
		assign Src_B[31:0] = ALUSrc?  ExtImm[31:0] : Start1 ? RD2[31:0] :ShOut[31:0] ; 
		assign Operand2[3:0] = Start1 ? Src_B[31:0] : 3'b000;
        assign ShIn[31:0] = RD2[31:0];
        assign Start = Start1;
        always @(Instr) 
		begin
          if ( ( Instr[27:20] == 0 || (Instr[21:20] == 2'b10)) & ( WE_PC == 0 ) )
                begin
                    Start1 = 1'b1;               
                end
          else
                begin
                    if (Instr[25] == 0) 
                        begin
                            InstrImm[23:0] = Instr;
		                    Shamt5[4:0] = Instr[11:7];
			                Sh[1:0] = Instr[6:5];
			                Start1 = 1'b0;
		                end
		        end
		end

        // Instantiate RegFile
    RegFile RegFile1( CLK,WE3,A1,A2,A3,WD3,R15,RD1,RD2);
                
    // Instantiate Extend Module
    Extend Extend1(ImmSrc,InstrImm,ExtImm);
                
    // Instantiate Decoder
    Decoder Decoder1( Rd,Op,Funct,Start,count,PCS,RegW,MemW,MemtoReg,ALUSrc,ImmSrc,RegSrc,B,ALUControl,FlagW,MCycleOp,done);
                                
    // Instantiate CondLogic
    CondLogic CondLogic1(CLK,PCS,B,RegW,MemW,FlagW,Cond,ALUFlags,PCSrc,RegWrite,MemWrite);
    
    // Instantiate Shifter        
    Shifter Shifter1(Sh,Shamt5,ShIn,ShOut);
                
    // Instantiate ALU        
    ALU ALU1(Src_A,Src_B,ALUControl,ALUResult,ALUFlags);                
    
    // Instantiate ProgramCounter    
    ProgramCounter ProgramCounter1(CLK,RESET,WE_PC,PC_IN,PC);  
    //Instantiate MCycle 
    MCycle MCycle1(CLK,done,MCycleOp,Operand1,Operand2,Result1,busy,count);
endmodule

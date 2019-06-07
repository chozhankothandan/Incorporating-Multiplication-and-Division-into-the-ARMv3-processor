
//output PCS should be coded 
 
module Decoder(
    input [3:0] Rd,
    
    input [1:0] Op,
    input [5:0] Funct,
    input Start,
    input [4:0]count,
    output reg PCS,
    output reg RegW,
    output reg MemW,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg [1:0] RegSrc,
    output reg B,
    output reg [2:0] ALUControl,
    output reg [1:0] FlagW,
    output reg [1:0] MCycleOp,
    output reg done = 0
    );
    reg ALUOp ;
    reg [9:0] controls ;
    //<extra signals, if any>
always@(*)
   begin 
     RegW = Op[0] + ( (~(Funct[5]) ) & ( ~( Funct[0] ) ) );    
     MemW = ( (Op == 2'b01) & (Funct[5] == 0) ) ? 1'b1 : 1'b0;
     MemtoReg = ( ((Op == 01) & ( Funct[0] == 1)) ) ? 1'b1 : 1'b0;
     ALUSrc = ( (Op == 00) & (Funct[5] == 1'b0) ) ? 1'b0 : 1'b1;
     ALUOp = (Op == 2'b00) ? 1'b1 : 1'b0;
     PCS = (Op == 10 & Op == 00) ? 1'b1 : 1'b0;
if(Start == 1)
    begin
        if( count <=3 )
            begin
                MCycleOp[1:0] = 2'b00;
                done = 1'b1;
            end
        else if( (count == 4 ) )
            begin
                  MCycleOp[1:0] = 1 + MCycleOp[1:0];
                  done = 1'b1;
            end     
        else
            begin
               done = 1'b0;
             end    
    end     
if((Op == 00) & (Funct[5] == 1))
        begin 
             ImmSrc = 00;
        end
else if (Op == 01)
        begin 
             ImmSrc = 01;
        end
else
        begin
             ImmSrc = 10;
        end
end
 always@(Op,Funct,ALUOp)
    begin   
        if(Op == 2'b00)
            begin
                RegSrc = 2'b00;
            end    
        else if ( (Op == 2'b01) & ( Funct[0] == 0 ) )
            begin
                RegSrc = 2'b10;
            end
        else if ( (Op == 2'b01) & ( Funct[0] == 1 ) )
            begin
                RegSrc = 2'b00;
            end
        else 
            begin
                RegSrc = 2'b01; 
                B = 1'b1;
            end
        
        if(ALUOp == 0)
            begin 
                ALUControl = 2'b00;
                FlagW = 2'b00;
            end
        else begin    
        case(Funct[4:1])
            4'b0100 : 
                if(Funct[0] == 0)
                    begin
                        ALUControl = 2'b00;
                        FlagW = 2'b00;
                    end
                else
                    begin   
                        ALUControl = 2'b00;
                        FlagW = 2'b11;
                    end
            4'b0010 :
                if(Funct[0] == 0)
                    begin
                         ALUControl = 2'b01;
                         FlagW = 2'b00;
                    end
                else
                    begin   
                         ALUControl = 2'b01;
                         FlagW = 2'b11;
                    end
            4'b0000 : 
                if(Funct[0] == 0)
                    begin
                         ALUControl = 2'b10;
                         FlagW = 2'b00;
                    end
                 else
                    begin
                         ALUControl = 2'b10;
                         FlagW = 2'b10;
                    end                      
            4'b1100 :
                 if(Funct[0] == 0)
                     begin
                         ALUControl = 2'b11;
                         FlagW = 2'b00;
                     end
                 else
                     begin
                         ALUControl = 2'b00;
                         FlagW = 2'b10;
                     end
            4'b1010 :
                     begin
                         ALUControl = 2'b10;
                         FlagW = 2'b00;
                      end
            default:
                    ALUControl = 0;
            endcase
            end
end
endmodule






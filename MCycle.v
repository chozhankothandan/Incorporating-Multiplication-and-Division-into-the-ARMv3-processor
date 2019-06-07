`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Shahzor Ahmad, Rajesh C Panicker
// 
// Create Date: 27.09.2016 10:59:44
// Design Name: 
// Module Name: MCycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/* 
----------------------------------------------------------------------------------
--	(c) Shahzor Ahmad, Rajesh C Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module MCycle

    #(parameter width = 4) // Keep this at 4 to verify your algorithms with 4 bit numbers (easier). When using MCycle as a component in ARM, generic map it to 32.
    (
        input CLK,
        input Start, // Multi-cycle Enable. The control unit should assert this when an instruction with a multi-cycle operation is detected.
        input [1:0] MCycleOp, // Multi-cycle Operation. "00" for signed multiplication, "01" for unsigned multiplication, "10" for signed division, "11" for unsigned division. Generated by Control unit
        input [width-1:0] Operand1, // Multiplicand / Dividend
        input [width-1:0] Operand2, // Multiplier / Divisor
        output reg [7:0] Result, // LSW of Product / Quotient
        output reg Busy, // Set immediately when Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
        output reg [4:0]count
    );
    
// use the Busy signal to reset WE_PC to 0 in ARM.v (aka "freeze" PC). The two signals are complements of each other
// since the IDLE_PROCESS is combinational, instantaneously asserts Busy once Start is asserted
  
    parameter IDLE = 1'b0 ;  // will cause a warning which is ok to ignore - [Synth 8-2507] parameter declaration becomes local in MCycle with formal parameter declaration list...

    parameter COMPUTING = 1'b1 ; // this line will also cause the above warning
    reg state = IDLE ;
    reg n_state = IDLE ;
    reg done ;
	 //Unsigned Multiplication
    reg [2:0]i = 2'b00; 
    reg [7:0]t1,ctemp=0;
    reg [7:0]Result1;    
        
    //unsigneddivision declaration 
    reg [7:0] Res = 0;
    reg [7:0] a1,b1;
    reg [8:0] p1;   
    integer j;
    

initial 
       begin
                    count = 0;
                    Busy = 1;
        end
always@( posedge CLK ) begin        

if(Start == 1)
    begin    
        count = count + 1;
        Busy = 1'b1;
            case(MCycleOp[1:0])    
		
				2'b00:                                       //Unsigned multiplication
					begin
                            i = i + 1;
                               if(Operand1[i]==1)
                                  begin
                                       t1 = Operand2 << i;
                                       Result1 = t1 + ctemp;
                                       ctemp = Result1;
                                  end
                               else
                                  begin
                                       t1 = 0 <<< i;
                                       Result1 = t1 + ctemp;
                                       ctemp = Result1;
                                  end
                               if(i == 4)
                                  begin
                                       Result[7:0] = ctemp[7:0];
                                       
                                  end

					end 
	       	       		    						
          	    2'b01:									// Unsigned Division
                    begin
                          //initialize the variables.
                         Busy = 1;
                          a1[7:0] = Operand1[3:0];
                          b1[7:0] = Operand2[3:0];
                          p1= 0;
                          for(j=0 ; j < 8; j = j + 1)    begin //start the for loop
                              p1 = {p1[8-2:0],a1[8-1]};
                              a1[7:1] = a1[6:0];
                              p1 = p1-b1;
                              if(p1[8-1] == 1)    begin
                                  a1[0] = 0;
                                  p1 = p1 + b1;   end
                              else
                                  a1[0] = 1;
                          end
                          Result[7:0] = a1; 
                          done <= 1'b1 ;
                         Busy = 1'b0;   
                      end 

			endcase 
    end
else
    begin
        Result[7:0] = 0;
    end
end   
endmodule

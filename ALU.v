
module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [2:0] ALUControl,
    output [31:0] ALUResult,
    output [3:0] ALUFlags
    );
    
    wire [32:0] S_wider ;
    reg [32:0] Src_A_comp ;
    reg [32:0] Src_B_comp ;
    reg [31:0] ALUResult_i ;
    reg [32:0] C_0 ;
    wire N, Z, C ;
    reg V ;
    
    assign S_wider = Src_A_comp + Src_B_comp + C_0 ;
    
    always@(Src_A, Src_B, ALUControl, S_wider) begin
        // default values; help avoid latches
        C_0 <= 0 ; 
        Src_A_comp <= {1'b0, Src_A} ;
        Src_B_comp <= {1'b0, Src_B} ;
        ALUResult_i <= Src_B ;
        V <= 0 ;
    
        case(ALUControl)
            2'b00:  
            begin
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ~^ Src_B[31] )  & ( Src_B[31] ^ S_wider[31] );          
            end
            
            2'b01:  
            begin
                C_0[0] <= 1 ;  
                Src_B_comp <= {1'b0, ~ Src_B} ;
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ^ Src_B[31] )  & ( Src_B[31] ~^ S_wider[31] );       
            end
            
            2'b10: ALUResult_i <= Src_A & Src_B ;
            2'b11: 
                    ALUResult_i <= Src_A | Src_B ;
            default:
                    ALUResult_i <= 0;       
                                   
        endcase ;
    end
    
    assign N = ALUResult_i[31] ;
    assign Z = (ALUResult_i == 0) ? 1 : 0 ;
    assign C = S_wider[32] ;
    
    assign ALUResult = ALUResult_i ;
    assign ALUFlags = {N, Z, C, V} ;
        
endmodule



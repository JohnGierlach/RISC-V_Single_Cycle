module seven_segment_top#(parameter WIDTH = 32)( 
    input wire clk, 
    input wire rst, 
    input[WIDTH-1:0] reg_display,
    output reg [3:0]segEnable, 
    output wire [6:0]outSeg 
    ); 
     
    reg [16:0] clockCounter;
    reg [27:0] low_high_counter;
    wire [6:0] hi_Seg, lo_Seg; 
    wire [6:0] lo_ones, lo_tens, lo_huns, lo_thous;      
    wire [6:0] hi_ones, hi_tens, hi_huns, hi_thous;   
    wire slowClk;
    wire lo_hi_seg;  
    
    // Divides 100 MHz Clock to 0.66Hz clock 
    always@(posedge clk or posedge rst) 
    begin 
        
        // If rst, set counter to 0 
        if(rst) begin
            clockCounter <=0;
            low_high_counter <= 0;
        end 
        
        // Each clock cycle increment counter 
        else begin
            clockCounter <= clockCounter + 1;
            low_high_counter <= low_high_counter + 1; 
        end  
    end     
    
    assign slowClk = clockCounter[16:16];
    assign lo_hi_seg = low_high_counter[27:27];
    
    // Switch to each 4 segment each slow clock cycle 
    always@(posedge slowClk or posedge rst) 
    begin 
        
        // If rst, set state machine to 0 
        if(rst) 
            segEnable <= 4'b1111; 
    
        // State machine that switches between ones and tens place 
        case(segEnable) 
            
            4'b1110 : segEnable <= 4'b1101; 
            4'b1101 : segEnable <= 4'b1011; 
            4'b1011 : segEnable <= 4'b0111; 
            4'b0111 : segEnable <= 4'b1110; 
            default : segEnable <= 4'b1110; 
         endcase 
    end 

    // Instantiate 4 instances of print_seg low end of 32-bits
    print_seg reg_lo_ones(reg_display[3:0], slowClk, rst, lo_ones); 
    print_seg reg_lo_tens(reg_display[7:4], slowClk, rst, lo_tens); 
    print_seg reg_lo_huns(reg_display[11:8], slowClk, rst, lo_huns); 
    print_seg reg_lo_thous(reg_display[15:12], slowClk, rst, lo_thous); 

    // Instantiate 4 instances of print_seg high end of 32-bits
    print_seg reg_hi_ones(reg_display[19:16], slowClk, rst, hi_ones); 
    print_seg reg_hi_tens(reg_display[23:20], slowClk, rst, hi_tens); 
    print_seg reg_hi_huns(reg_display[27:24], slowClk, rst, hi_huns); 
    print_seg reg_hi_thous(reg_display[31:28], slowClk, rst, hi_thous); 
    
    assign lo_Seg = (segEnable == 4'b1110)? lo_ones :  
                    (segEnable == 4'b1101)? lo_tens : 
                    (segEnable == 4'b1011)? lo_huns : lo_thous;

    assign hi_Seg = (segEnable == 4'b1110)? hi_ones :  
                    (segEnable == 4'b1101)? hi_tens : 
                    (segEnable == 4'b1011)? hi_huns : hi_thous;  

    assign outSeg = (lo_hi_seg) ? hi_Seg : lo_Seg;
endmodule 

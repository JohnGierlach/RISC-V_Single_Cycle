`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2024 12:41:46 PM
// Design Name: 
// Module Name: program_counter
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


module program_counter#(parameter WIDTH = 32)(
    input clk,
    input rst,
    input branch,
    input[WIDTH-1:0] in_pc,
    output[WIDTH-1:0] out_pc
    );
    
    reg[WIDTH-1:0] temp_pc;
    
    always@(posedge clk)begin
        if(rst)
            temp_pc <= 0;
        
        else begin
            if(branch)
                temp_pc <= temp_pc+in_pc-4;
                
            else
                temp_pc <= temp_pc+4;
        end
    end    
    
   assign out_pc = temp_pc;
    
endmodule

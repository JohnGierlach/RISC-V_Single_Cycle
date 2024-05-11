`timescale 1ns / 1ps

module dmu_engine#(parameter WIDTH = 32)(
    input clk,
    input rst,
    input read_en,
    input write_en,
    input[WIDTH-1:0] write_data,
    input[WIDTH-1:0] addr,
    output[WIDTH-1:0] out_data
    );
    
    integer i;
    reg[WIDTH-1:0] mem_storage[WIDTH*4-1:0];
    
    always@(posedge clk)begin
        if(rst)begin
            for(i = 0; i < WIDTH*WIDTH; i = i + 1)begin
                mem_storage[i] = 32'b0;
            end
        end
        
        // Write data to memory
        if(write_en)
            mem_storage[addr-1] <= write_data;
        
    end

    assign out_data = read_en ? mem_storage[addr-1]:32'b0;

endmodule

interface dmu_interface(input logic clock);
  
    logic clk,
    logic rst,
    logic read_en,
    logic write_en,
    logic[WIDTH-1:0] write_data,
    logic[WIDTH-1:0] addr,
    logic[WIDTH-1:0] out_data
  
  
endinterface: dmu_interface
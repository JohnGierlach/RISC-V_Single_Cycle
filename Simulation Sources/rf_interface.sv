interface rf_interface#(parameter WIDTH = 32)(input logic clock);
  
    logic clk, rst, write_en;
    logic[4:0] RS1, RS2, RD;
    logic[WIDTH-1:0] RD_data;
    logic[WIDTH-1:0] RS1_data, RS2_data;
  
  
endinterface: rf_interface
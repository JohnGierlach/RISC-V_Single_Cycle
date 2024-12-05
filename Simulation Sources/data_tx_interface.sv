interface data_tx_interface#(parameter WIDTH = 32)(input logic clock);
  
    logic clk; 
    logic rst; 
    logic pc;
    logic [2:0] Funct3;
    logic [6:0] Funct7;
    logic [6:0] opcode;
    logic [11:0] Imm_reg;
    logic [4:0] Shamt;
    logic  write_en; read_en;
    logic [4:0] RS1, RS2, RD;
    logic [WIDTH-1:0] ALU_data_out;
    logic [WIDTH-1:0] Mem_addr_out;
    logic [WIDTH-1:0] RS2_data_out; RS1_data_out;
    logic [WIDTH-1:0] dmu_out_data;
  
  
endinterface: rf_interface
interface alu_interface #(parameter WIDTH = 32) (input logic clock);
  
  
    logic clk;
    logic rst;
    logic[WIDTH-1:0] pc;
    logic signed[WIDTH-1:0] RS1;
    logic signed[WIDTH-1:0] RS2;
    logic[2:0] Funct3;
    logic[6:0] Funct7;
    logic[6:0] opcode;
    logic[11:0] Imm_reg;
    logic[4:0] Shamt;
    logic[WIDTH-1:0] RD;
    logic[WIDTH-1:0] Mem_addr;
  
  
endinterface: alu_interface
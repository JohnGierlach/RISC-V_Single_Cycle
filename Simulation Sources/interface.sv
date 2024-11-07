interface alu_interface(input logic clock);
  
  /*  alu dut(
    .clock(),
    .reset(),
    .A(),
    .B(),
    .ALU_Sel(),
    .ALU_Out(),
    .CarryOut()
  );*/
  
  logic reset;
  logic[7:0] a, b;
  logic[3:0] op_code;
  logic[7:0] result;
  bit carryout;
  
  
endinterface: alu_interface
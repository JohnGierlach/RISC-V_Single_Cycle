// Code your testbench here
// or browse Examples
`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

//----------------------------------
//Include Files
//----------------------------------
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "test.sv"


module top;
  
  //----------------------------------
  //Instantiations
  //----------------------------------

  logic clock;
  
  alu_interface intf(.clock(clock));
  
  alu dut(
    .clock(intf.clock),
    .reset(intf.reset),
    .A(intf.a),
    .B(intf.b),
    .ALU_Sel(intf.op_code),
    .ALU_Out(intf.result),
    .CarryOut(intf.carryout)
  );
  
  
  initial begin
    uvm_config_db #(virtual alu_interface)::set(null, "*", "vif", intf);
  end
  
  
  initial begin
    run_test("alu_test");
  end
  
  initial begin
  	clock = 0;
    #5;
    forever begin
    	clock = ~clock;
		#2;
    end
  end
  
  initial begin
  	#5000;
    $display("Sorry, ran out of clock cycles!");
    $finish;
  end
  
  
endmodule: top
// Code your testbench here
// or browse Examples
`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

//----------------------------------
//Include Files
//----------------------------------
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "risc-v-scoreboard.sv"
`include "env.sv"
`include "test.sv"
`include "alu_top.v"
`include "dmu_engine.v"
`include "register_select.v"
`include "data_tx.v"

module top;
  
  //----------------------------------
  //Instantiations
  //----------------------------------

  logic clock;
  
  data_tx_interface data_tx_intf(.clock(clock));

  data_tx dut(
    .clk(data_tx_intf.clk), 
    .rst(data_tx_intf.rst), 
    .pc(data_tx_intf.pc),
    .Funct3(data_tx_intf.Funct3),
    .Funct7(data_tx_intf.Funct7),
    .opcode(data_tx_intf.opcode),
    .Imm_reg(data_tx_intf.Imm_reg),
    .Shamt(data_tx_intf.Shamt),
    .write_en(data_tx_intf.write_en), .read_en(data_tx_intf.read_en),
    .RS1(data_tx_intf.RS1), .RS2(data_tx_intf.RS2), .RD(data_tx_intf.RD),
    .Mem_addr_out(data_tx_intf.Mem_addr_out),
    .RS2_data_out(data_tx_intf.RS2_data_out), .RS1_data_out(data_tx_intf.RS1_data_out),
    .dmu_out_data(data_tx_intf.dmu_out_data)
  );

  initial begin
    uvm_config_db #(virtual data_tx_interface)::set(null, "*", "data_tx_vif", data_tx_intf);
  end
  
  
  initial begin
    run_test("data_tx_test");
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
  	#50000;
    $display("Sorry, ran out of clock cycles!");
    $finish;
  end
  
  
endmodule: top
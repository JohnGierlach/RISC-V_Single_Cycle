// Code your testbench here
// or browse Examples
`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

//----------------------------------
//Include Files
//----------------------------------
`include "alu_interface.sv"
`include "dmu_interface.sv"
`include "rf_interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "risc-v-scoreboard.sv"
`include "env.sv"
`include "test.sv"


module top;
  
  //----------------------------------
  //Instantiations
  //----------------------------------

  logic clock;
  
  alu_interface alu_intf(.clock(clock));
  rf_interface rf_intf(.clock(clock));
  dmu_interface dmu_intf(.clock(clock));
  
  alu_top dut0(
    .clk(alu_intf.clk),
    .rst(alu_intf.rst),
    .pc(alu_intf.pc),
    .RS1(alu_intf.RS1),
    .RS2(alu_intf.RS2),
    .Funct3(alu_intf.Funct3),
    .Funct7(alu_intf.Funct7),
    .opcode(alu_intf.opcode),
    .Imm_reg(alu_intf.Imm_reg),
    .Shamt(alu_intf.Shamt),
    .RD(alu_intf.RD),
    .Mem_addr(alu_intf.Mem_addr)
  );

  register_select dut1(
    .clk(rf_intf.clk),
    .rst(rf_intf.rst),
    .write_en(rf_intf.write_en),
    .RS1(rf_intf.RS1),
    .RS2(rf_intf.RS2),
    .RD(rf_intf.RD),
    .RD_data(rf_intf.RD_data),
    .RS1_data(rf_intf.RS1_data),
    .RS2_data(rf_intf.RS2_data)
  );
  
  dmu_engine dut2(
    .clk(dmu_intf.clk),
    .rst(dmu_intf.rst),
    .read_en(dmu_intf.read_en),
    .write_en(dmu_intf.write_en),
    .write_data(dmu_intf.write_data),
    .addr(dmu_intf.addr),
    .out_data(dmu_intf.out_data)
  );
  
  initial begin
    uvm_config_db #(virtual alu_interface)::set(null, "*", "alu_vif", alu_intf);
    uvm_config_db #(virtual rf_interface)::set(null, "*", "rf_vif", rf_intf);
    uvm_config_db #(virtual dmu_interface)::set(null, "*", "dmu_vif", dmu_intf);
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
// Object class


class alu_sequence_item extends uvm_sequence_item;
	
  `uvm_object_utils(alu_sequence_item)
  
  // Instantiations
  
  // Inputs
  rand logic reset;
  rand logic[7:0] a, b;
  rand logic[3:0] op_code;
  
  // Default Constraints
  constraint input1_c{a inside {[10:20]};}
  constraint input2_c{b inside {[1:10]};}
  constraint op_code_c{op_code inside {[0:3]};}
  
  // Outputs
  logic[7:0] result;
  bit carryout;
  
  
  function new(string name = "alu_sequence_item");
    super.new(name);
  endfunction: new
	
endclass


class rf_sequence_item extends uvm_sequence_item;
	
  `uvm_object_utils(rf_sequence_item)
  
  // Instantiations
  
  // Inputs
  rand logic reset;
  rand logic[7:0] a, b;
  rand logic[3:0] op_code;
  
  // Default Constraints
  constraint input1_c{a inside {[10:20]};}
  constraint input2_c{b inside {[1:10]};}
  constraint op_code_c{op_code inside {[0:3]};}
  
  // Outputs
  logic[7:0] result;
  bit carryout;
  
  
  function new(string name = "rf_sequence_item");
    super.new(name);
  endfunction: new
	
endclass

class dmu_sequence_item extends uvm_sequence_item;
	
  `uvm_object_utils(dmu_sequence_item)
  
  // Instantiations
  
  // Inputs
  rand logic reset;
  rand logic[7:0] a, b;
  rand logic[3:0] op_code;
  
  // Default Constraints
  constraint input1_c{a inside {[10:20]};}
  constraint input2_c{b inside {[1:10]};}
  constraint op_code_c{op_code inside {[0:3]};}
  
  // Outputs
  logic[7:0] result;
  bit carryout;
  
  
  function new(string name = "dmu_sequence_item");
    super.new(name);
  endfunction: new
	
endclass
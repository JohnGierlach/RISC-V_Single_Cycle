// Object class


// This is our reset sequence
class base_sequence extends uvm_sequence;
	
  `uvm_object_utils(base_sequence)
  
  alu_sequence_item reset_pkt;
  
  function new(string name = "base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("BASE_SEQ", "Inside body task!", UVM_HIGH);
    
    reset_pkt = alu_sequence_item::type_id::create("reset_pkt");
    start_item(reset_pkt);
    
    reset_pkt.randomize() with {reset==1;};
    
    finish_item(reset_pkt);
    
    
  endtask: body
	
endclass: base_sequence


class initialize_regs_sequence extends base_sequence;
	
  `uvm_object_utils(initialize_regs_sequence)
  
  alu_sequence_item item;
  
  function new(string name = "initialize_regs_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    item = alu_sequence_item::type_id::create("item");
    start_item(item);
    
    item.randomize() with {reset==0;};
    
    finish_item(item);
    
    
  endtask: body
	
endclass: initialize_regs_sequence
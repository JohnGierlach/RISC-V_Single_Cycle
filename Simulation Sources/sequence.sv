// Object class


//-----------------------------------------------------------------
// BASE SEQUENCE - RESET TO KNOWN STABLE STATE
//-----------------------------------------------------------------
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

//-----------------------------------------------------------------
// INIT REGISTERS SEQUENCE - POPULATE REGISTER FILE WITH VALUES
//-----------------------------------------------------------------
class init_regs_sequence extends base_sequence;
	
  `uvm_object_utils(init_regs_sequence)
  
  alu_sequence_item item;
  
  function new(string name = "init_regs_sequence");
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
	
endclass: init_regs_sequence

//-----------------------------------------------------------------
// R-Type AND I-Type ALU SEQUENCE - PERFORM ALU OPS FOR R&I Type 
//-----------------------------------------------------------------
class r_i_type_alu_sequence extends base_sequence;
	
  `uvm_object_utils(r_i_type_alu_sequence)
  
  alu_sequence_item item;
  
  function new(string name = "r_i_type_alu_sequence");
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
	
endclass: r_i_type_alu_sequence


//-----------------------------------------------------------------
// WRITE SEQUENCE - DMU READ REGISTER FILE DATA
//-----------------------------------------------------------------
class write_sequence extends base_sequence;
	
  `uvm_object_utils(write_sequence)
  
  alu_sequence_item item;
  
  function new(string name = "write_sequence");
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
	
endclass: write_sequence


//-----------------------------------------------------------------
// READ SEQUENCE - REGISTER FILE READS DMU DATA
//-----------------------------------------------------------------
class read_sequence extends base_sequence;
	
  `uvm_object_utils(read_sequence)
  
  alu_sequence_item item;
  
  function new(string name = "read_sequence");
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
	
endclass: read_sequence

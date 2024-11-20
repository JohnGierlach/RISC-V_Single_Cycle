// Object class


//-----------------------------------------------------------------
// BASE SEQUENCE - RESET TO KNOWN STABLE STATE
//-----------------------------------------------------------------
class base_sequence extends uvm_sequence;
	
  `uvm_object_utils(base_sequence)
  
  alu_sequence_item alu_reset_pkt;
  rf_sequence_item rf_reset_pkt;
  dmu_sequence_item dmu_reset_pkt;

  function new(string name = "base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("BASE_SEQ", "Inside body task!", UVM_HIGH);
    
    alu_reset_pkt = alu_sequence_item::type_id::create("alu_reset_pkt");
    rf_reset_pkt = alu_sequence_item::type_id::create("rf_reset_pkt");
    dmu_reset_pkt = alu_sequence_item::type_id::create("dmu_reset_pkt");

    start_item(alu_reset_pkt);
    start_item(rf_reset_pkt);
    start_item(dmu_reset_pkt);
    
    alu_reset_pkt.randomize() with {reset==1;};
    rf_reset_pkt.randomize() with {reset==1;};
    dmu_reset_pkt.randomize() with {reset==1;};
    
    finish_item(alu_reset_pkt);
    finish_item(rf_reset_pkt);
    finish_item(dmu_reset_pkt);
    
    
  endtask: body
	
endclass: base_sequence

//-----------------------------------------------------------------
// INIT REGISTERS SEQUENCE - POPULATE REGISTER FILE WITH VALUES
//-----------------------------------------------------------------
class init_regs_sequence extends base_sequence;
	
  `uvm_object_utils(init_regs_sequence)
  
  alu_sequence_item alu_item;
  rf_sequence_item rf_item;
  
  function new(string name = "init_regs_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    alu_item = alu_sequence_item::type_id::create("alu_item");
    rf_item = rf_sequence_item::type_id::create("alu_item");

    start_item(alu_item);
    start_item(rf_item);
    
    rf_item.randomize() with 
    {
      rst == 0;
      RD == RS1;

      // In reg file, write_en is active low
      write_en == 0;
    };

    alu_item.randomize() with 
    {
      rst == 0;

      // No PC or Shamt used during init registers sequence
      pc == 0;
      Shamt == 0;

      // Sets operation as ADDI 
      opcode == 7'h13;
      funct3 == 3'h0;
      funct7 == 7'h00;
    };
    
    finish_item(alu_item);
    finish_item(rf_item);
    
    
  endtask: body
	
endclass: init_regs_sequence

//-----------------------------------------------------------------
// R-Type AND I-Type ALU SEQUENCE - PERFORM ALU OPS FOR R&I Type 
//-----------------------------------------------------------------
class r_i_type_alu_sequence extends base_sequence;
	
  `uvm_object_utils(r_i_type_alu_sequence)
  
  alu_sequence_item alu_item;
  rf_sequence_item rf_item;
  
  function new(string name = "r_i_type_alu_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    alu_item = alu_sequence_item::type_id::create("alu_item");
    rf_item = rf_sequence_item::type_id::create("alu_item");

    start_item(alu_item);
    start_item(rf_item);
    
    rf_item.randomize() with 
    {
      rst == 0;

      // In reg file, write_en is active low
      write_en == 0;
    };

    alu_item.randomize() with 
    {
      rst == 0;

      // No PC or Shamt used during init registers sequence
      pc == 0;
    };
    
    finish_item(alu_item);
    finish_item(rf_item);
    
  endtask: body
	
endclass: r_i_type_alu_sequence


//-----------------------------------------------------------------
// WRITE SEQUENCE - DMU READ REGISTER FILE DATA
//-----------------------------------------------------------------
class write_sequence extends base_sequence;
	
  `uvm_object_utils(write_sequence)
  
  dmu_sequence_item dmu_item;
  rf_sequence_item rf_item;
  alu_sequence_item alu_item;
  
  function new(string name = "write_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    dmu_item = dmu_sequence_item::type_id::create("dmu_item");
    rf_item = rf_sequence_item::type_id::create("rf_item");
    alu_item = alu_sequence_item::type_id::create("alu_item");
    start_item(dmu_item);
    start_item(rf_item);
    start_item(alu_item);
    
    alu_item.randomize() with 
    {
      rst == 0;

      // Sets the opcode to SW
      opcode == 7'b0100011;
      Imm_reg inside {[1:128]};
    };

    
    rf_item.randomize() with {
      rst == 0;
      RS1 == 0;
    };

    dmu_item.randomize() with {
      rst == 0;
      read_en == 0;
      write_en == 1;
    };
    
    finish_item(dmu_item);
    finish_item(rf_item);
    finish_item(alu_item);
    
    
  endtask: body
	
endclass: write_sequence


//-----------------------------------------------------------------
// READ SEQUENCE - REGISTER FILE READS DMU DATA
//-----------------------------------------------------------------
class read_sequence extends base_sequence;
	
  `uvm_object_utils(read_sequence)
  
  dmu_sequence_item dmu_item;
  rf_sequence_item rf_item;
  alu_sequence_item alu_item;
  
  function new(string name = "read_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    dmu_item = dmu_sequence_item::type_id::create("dmu_item");
    rf_item = rf_sequence_item::type_id::create("rf_item");
    alu_item = alu_sequence_item::type_id::create("alu_item");
    start_item(dmu_item);
    start_item(rf_item);
    start_item(alu_item);
    
    alu_item.randomize() with 
    {
      rst == 0;

      // Sets the opcode to LW
      opcode == 7'b0000011;

      // further contrain Imm_reg to access only access possible memory blocks
      Imm_reg inside {[1:128]};
    };

    rf_item.randomize() with {
      rst == 0;
      RS1 == 0;

      // In reg file, write_en is active low
      write_en == 0;
    };

    dmu_item.randomize() with {
      rst == 0;
      read_en == 1;
      write_en == 0;
    };
    
    finish_item(dmu_item);
    finish_item(rf_item);
    finish_item(alu_item);
    
    
  endtask: body
	
endclass: read_sequence

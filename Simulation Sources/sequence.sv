// Object class


//-----------------------------------------------------------------
// BASE SEQUENCE - RESET TO KNOWN STABLE STATE
//-----------------------------------------------------------------
class base_sequence extends uvm_sequence;
	
  `uvm_object_utils(base_sequence)
  
  data_tx_sequence_item reset_pkt;

  function new(string name = "base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("BASE_SEQ", "Inside body task!", UVM_HIGH);
    
    reset_pkt = alu_sequence_item::type_id::create("reset_pkt");

    start_item(reset_pkt);
    
    reset_pkt.randomize() with {rst==1;};
    
    finish_item(reset_pkt);
    
    
  endtask: body
	
endclass: base_sequence

//-----------------------------------------------------------------
// INIT REGISTERS SEQUENCE - POPULATE REGISTER FILE WITH VALUES
//-----------------------------------------------------------------
class init_regs_sequence extends base_sequence;
	
  `uvm_object_utils(init_regs_sequence)
  
  data_tx_sequence_item data_tx_item;
  
  function new(string name = "init_regs_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    data_tx_item = alu_sequence_item::type_id::create("data_tx_item");

    start_item(data_tx_item);
    
    data_tx_item.randomize() with 
    {
      rst == 0;
      RD == RS1;

      // In reg file, write_en is active low
      write_en == 0;

      // PC & Shamt set to 0
      pc == 0;
      Shamt == 0;

      // Sets operation as ADDI 
      opcode == 7'h13;
      Funct3 == 3'h0;
      Funct7 == 7'h00;
    };

    finish_item(data_tx_item);
        
  endtask: body
	
endclass: init_regs_sequence

//-----------------------------------------------------------------
// R-Type AND I-Type ALU SEQUENCE - PERFORM ALU OPS FOR R&I Type 
//-----------------------------------------------------------------
class r_i_type_alu_sequence extends base_sequence;
	
  `uvm_object_utils(r_i_type_alu_sequence)
  
  data_tx_sequence_item data_tx_item;
  
  function new(string name = "r_i_type_alu_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    data_tx_item = alu_sequence_item::type_id::create("data_tx_item");

    start_item(data_tx_item);
    
    data_tx_item.randomize() with 
    {
      rst == 0;

      // In reg file, write_en is active low
      write_en == 0;
      pc == 0;
    };
    
    finish_item(data_tx_item);

  endtask: body
	
endclass: r_i_type_alu_sequence


//-----------------------------------------------------------------
// WRITE SEQUENCE - DMU READ REGISTER FILE DATA
//-----------------------------------------------------------------
class write_sequence extends base_sequence;
	
  `uvm_object_utils(write_sequence)
  
  data_tx_sequence_item data_tx_item;
  
  function new(string name = "write_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    data_tx_item = dmu_sequence_item::type_id::create("data_tx_item");

    start_item(data_tx_item);
    
    data_tx_item.randomize() with 
    {
      rst == 0;

      // Sets the opcode to SW
      opcode == 7'b0100011;
      Imm_reg inside {[1:128]};

      // Set base addr to 0
      RS1 == 0;

      // Write to Mem
      read_en == 0;
      write_en == 1;

    };

    finish_item(data_tx_item);
    
  endtask: body
	
endclass: write_sequence


//-----------------------------------------------------------------
// READ SEQUENCE - REGISTER FILE READS DMU DATA
//-----------------------------------------------------------------
class read_sequence extends base_sequence;
	
  `uvm_object_utils(read_sequence)
  
  data_tx_sequence_item data_tx_item;
  
  function new(string name = "read_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH);
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH);
    
    data_tx_item = dmu_sequence_item::type_id::create("data_tx_item");

    start_item(data_tx_item);
    
    data_tx_item.randomize() with 
    {
      rst == 0;

      // Sets the opcode to LW
      opcode == 7'b0000011;

      // further contrain Imm_reg to access only access possible memory blocks
      Imm_reg inside {[1:128]};

      // Set base addr to 0 
      RS1 == 0;

      // In reg file, write_en is active low
      write_en == 0;

      read_en == 1;
      write_en == 0;
    };

    finish_item(data_tx_item);
    
  endtask: body
	
endclass: read_sequence

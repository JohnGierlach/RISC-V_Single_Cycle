class base_sequencer extends uvm_sequencer#(alu_sequence_item);
  `uvm_component_utils(base_sequencer)
  
  function new(string name = "base_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info("BASE_SEQUENCER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  //--------------------------------------------------------
  //build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("BASE_SEQUENCER_CLASS", "Build Phase!", UVM_HIGH)
  endfunction: build_phase

  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("BASE_SEQUENCER_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
  
endclass: base_sequencer

class alu_sequencer extends base_sequencer;
  `uvm_component_utils(alu_sequencer)
  
  function new(string name = "alu_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ALU_SEQUENCER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ALU_SEQUENCER_CLASS", "Build Phase!", UVM_HIGH)
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ALU_SEQUENCER_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
endclass : alu_sequencer;

class rf_sequencer extends base_sequencer;
  `uvm_component_utils(rf_sequencer)
  
  function new(string name = "rf_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info("RF_SEQUENCER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("RF_SEQUENCER_CLASS", "Build Phase!", UVM_HIGH)
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("RF_SEQUENCER_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
endclass : rf_sequencer;

class dmu_sequencer extends base_sequencer;
  `uvm_component_utils(dmu_sequencer)
  
  function new(string name = "dmu_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DMU_SEQUENCER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DMU_SEQUENCER_CLASS", "Build Phase!", UVM_HIGH)
  endfunction: build_phase
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("DMU_SEQUENCER_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
endclass : dmu_sequencer;
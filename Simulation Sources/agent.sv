class base_agent extends uvm_agent;
  `uvm_component_utils(base_agent)
  
   data_tx_driver drv;
   data_tx_monitor mon;
   data_tx_sequencer seqr;
  
  function new(string name = "base_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT_CLASS", "Build Phase!", UVM_HIGH)
    
    drv = data_tx_driver::type_id::create("drv", this);
    mon = data_tx_monitor::type_id::create("mon", this);
    seqr = data_tx_sequencer::type_id::create("seqr", this);
    
  endfunction: build_phase

  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("AGENT_CLASS", "Connect Phase!", UVM_HIGH)
    
    drv.seq_item_port.connect(seqr.seq_item_export);
    
  endfunction: connect_phase

  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    // Logic
    
    
  endtask: run_phase
endclass: base_agent

class alu_agent extends base_agent;

  alu_driver drv;
  alu_monitor mon;
  alu_sequencer seqr;

  function new(string name = "alu_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ALU_AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ALU_AGENT_CLASS", "Build Phase!", UVM_HIGH)
    
    drv = alu_driver::type_id::create("drv", this);
    mon = alu_monitor::type_id::create("mon", this);
    seqr = alu_sequencer::type_id::create("seqr", this);
    
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ALU_AGENT_CLASS", "Connect Phase!", UVM_HIGH)
    
    drv.seq_item_port.connect(seqr.seq_item_export);
    
  endfunction: connect_phase

endclass : alu_agent

class rf_agent extends base_agent;

  rf_driver drv;
  rf_monitor mon;
  rf_sequencer seqr;

  function new(string name = "rf_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("RF_AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("RF_AGENT_CLASS", "Build Phase!", UVM_HIGH)
    
    drv = rf_driver::type_id::create("drv", this);
    mon = rf_monitor::type_id::create("mon", this);
    seqr = rf_sequencer::type_id::create("seqr", this);
    
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("RF_AGENT_CLASS", "Connect Phase!", UVM_HIGH)
    
    drv.seq_item_port.connect(seqr.seq_item_export);
    
  endfunction: connect_phase

endclass : rf_agent

class dmu_agent extends base_agent;

  dmu_driver drv;
  dmu_monitor mon;
  dmu_sequencer seqr;

  function new(string name = "dmu_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DMU_AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DMU_AGENT_CLASS", "Build Phase!", UVM_HIGH)
    
    drv = dmu_driver::type_id::create("drv", this);
    mon = dmu_monitor::type_id::create("mon", this);
    seqr = dmu_sequencer::type_id::create("seqr", this);
    
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("DMU_AGENT_CLASS", "Connect Phase!", UVM_HIGH)
    
    drv.seq_item_port.connect(seqr.seq_item_export);
    
  endfunction: connect_phase

endclass : dmu_agent
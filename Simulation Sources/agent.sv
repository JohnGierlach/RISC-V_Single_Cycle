class data_tx_agent extends uvm_agent;
  `uvm_component_utils(data_tx_agent)
  
   alu_driver drv;
   alu_monitor mon;
   alu_sequencer seqr;
  
  function new(string name = "data_tx_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT_CLASS", "Build Phase!", UVM_HIGH)
    
    drv = alu_driver::type_id::create("drv", this);
    mon = alu_monitor::type_id::create("mon", this);
    seqr = alu_sequencer::type_id::create("seqr", this);
    
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
endclass: data_tx_agent
class data_tx_sequencer extends uvm_sequencer#(alu_sequence_item);
  `uvm_component_utils(data_tx_sequencer)
  
  function new(string name = "data_tx_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SEQUENCER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  //--------------------------------------------------------
  //build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SEQUENCER_CLASS", "Build Phase!", UVM_HIGH)
  endfunction: build_phase

  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SEQUENCER_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
  
endclass: data_tx_sequencer
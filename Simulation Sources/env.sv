class data_tx_env extends uvm_env;
  `uvm_component_utils(data_tx_env)
  
  data_tx_agent agnt;
  risc_v_scoreboard scb;
  
  function new(string name = "data_tx_env", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ENV_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV_CLASS", "Build Phase!", UVM_HIGH)
    
    agnt = data_tx_agent::type_id::create("agnt", this);
    scb = risc_v_scoreboard::type_id::create("scb", this);
    
  endfunction: build_phase

  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS", "Connect Phase!", UVM_HIGH)
    

    // TODO : Create monitor port connection for rf, alu, and dmu
    // TODO : scb.alu_scoreboard_port, scb.rf_scoreboard_port, scb.dmu_scoreboard_port
    agnt.mon.alu_monitor_port.connect(scb.alu_scoreboard_port);
    agnt.mon.rf_monitor_port.connect(scb.rf_scoreboard_port);
    agnt.mon.dmu_monitor_port.connect(scb.dmu_scoreboard_port);
    
  endfunction: connect_phase
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    // Logic
    
    
  endtask: run_phase
endclass: data_tx_env
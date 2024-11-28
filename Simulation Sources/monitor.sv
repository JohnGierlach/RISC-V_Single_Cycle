class data_tx_monitor extends uvm_monitor;
  `uvm_component_utils(data_tx_monitor)
  
  virtual alu_interface vif;
  alu_sequence_item item;
  uvm_analysis_port #(alu_sequence_item) monitor_port;

  // TODO : Create a monitor port, item and virtual interface for rf, alu, dmu
  
  
  function new(string name = "data_tx_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info("MONITOR_CLASS", "Inside Constructor!", UVM_HIGH)
    
  endfunction: new

  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    `uvm_info("MONITOR_CLASS", "Build Phase!", UVM_HIGH)
    
    // TODO : Create monitor port instances for rf, alu, and dmu

    monitor_port = new("monitor_port", this);
    
    // TODO : Include a pass/fail condition for rf, alu and dmu virtual inteface connectioj
    
    if(!(uvm_config_db#(virtual alu_interface)::get(this, "*",  "vif", vif)))begin
      `uvm_error("MONTIOR_CLASS", "Failed to get VIF from config DB!");
    end
    
  endfunction: build_phase
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("MONITOR_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase

  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("MONITOR_CLASS", "Inside Run Phase!", UVM_HIGH)
    
    forever begin
      item = alu_sequence_item::type_id::create("item");

      // TODO : Create rf, alu, and dmu sequence item

      // TODO : Check to make sure rf.rst, alu.rst, or dmu.rst is 0
      // All rst signals are tied to the same top level rst signal
      wait(!vif.reset);
      
      // TODO : Capture all inputs and outputs of rf, alu, and dmu interfaces

      // Capturing all inputs from a given interface
      @(posedge vif.clock)begin
      	item.a = vif.a;
        item.b = vif.b;
        item.op_code = vif.op_code;
      end
     
      // Capturing all outputs from a given interface
      @(posedge vif.clock)begin
      	item.result = vif.result;
        item.carryout = vif.carryout;
      end
      
      // TODO : Write the respective item to the rf, alu, and dmu montior port

      // Send item to scoreboard
      monitor_port.write(item);
    end
    
    
  endtask: run_phase
endclass: data_tx_monitor
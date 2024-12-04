class data_tx_monitor extends uvm_monitor;
  `uvm_component_utils(data_tx_monitor)
  
  virtual data_tx_interface data_tx_vif;
  data_tx_sequence_item data_tx_item;

  uvm_analysis_port #(data_tx_sequence_item) data_tx_monitor_port;
  
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

    data_tx_monitor_port = new("alu_monitor_port", this);
    
    if(!(uvm_config_db#(virtual data_tx_interface)::get(this, "*",  "data_tx_vif", data_tx_vif)))begin
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
      data_tx_item = data_tx_sequence_item::type_id::create("data_tx_item");

      wait(!data_tx_vif.rst);

      // Capturing all inputs for data_tx interface
      @(posedge data_tx_vif.clk)begin
      	
        // Global Reset
        data_tx_item.rst = data_tx_vif.rst;
        data_tx_item.pc = data_tx_vif.pc;
        
        // RF Input Signals
        data_tx_item.RS1 = data_tx_vif.RS1;
        data_tx_item.RS2 = data_tx_vif.RS2;
        data_tx_item.RD = data_tx_vif.RD;

        // ALU Input Signals
        data_tx_item.Funct3 = data_tx_vif.Funct3;
        data_tx_item.Funct7 = data_tx_vif.Funct7;
        data_tx_item.Imm_reg = data_tx_vif.Imm_reg;
        data_tx_item.Shamt = data_tx_vif.Shamt;
        data_tx_item.opcode = data_tx_vif.opcode;

        // RF & DMU Input WE
        data_tx_item.write_en = data_tx_vif.write_en;

        // DMU Input Signal
        data_tx_item.read_en = data_tx_vif.read_en;
      end
     
      // Capturing all outputs for data_tx interface
      @(posedge data_tx_vif.clk)begin
      	
        // RF Output signals
        data_tx_item.RS1_data_out = data_tx_vif.RS1_data_out;
      	data_tx_item.RS2_data_out = data_tx_vif.RS2_data_out;
        
        // ALU Output Signals
        data_tx_item.Mem_addr_out = data_tx_vif.Mem_addr_out;
        data_tx_item.ALU_data_out = data_tx_vif.ALU_data_out;

        // DMU Output Signals
      	data_tx_item.dmu_out_data = data_tx_vif.dmu_out_data;
      	
      end

    end
    
  endtask: run_phase

endclass: data_tx_monitor

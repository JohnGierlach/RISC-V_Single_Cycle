class data_tx_monitor extends uvm_monitor;
  `uvm_component_utils(data_tx_monitor)
  
  virtual alu_interface vif_alu;
  virtual rf_interface vif_rf;
  virtual dmu_interface vif_dmu;

  alu_sequence_item alu_item;
  rf_sequence_item rf_item;
  dmu_sequence_item dmu_item;

  uvm_analysis_port #(alu_sequence_item, rf_sequence_item, dmu_sequence_item) monitor_port;
  
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

    monitor_port = new("monitor_port", this);
    
    if(!(uvm_config_db#(virtual alu_interface)::get(this, "*",  "vif_alu", vif_alu)))begin
      `uvm_error("MONTIOR_CLASS", "Failed to get VIF from config DB!");
    end

    if(!(uvm_config_db#(virtual rf_interface)::get(this, "*",  "vif_rf", vif_rf)))begin
      `uvm_error("MONTIOR_CLASS", "Failed to get VIF from config DB!");
    end

    if(!(uvm_config_db#(virtual dmu_interface)::get(this, "*",  "vif_dmu", vif_dmu)))begin
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
      alu_item = alu_sequence_item::type_id::create("alu_item");
      rf_item = rf_sequence_item::type_id::create("rf_item");
      dmu_item = dmu_sequence_item::type_id::create("dmu_item");

      wait(!vif_alu.rst && !vif_rf.rst && !vif_dmu.rst);

      // Capturing all inputs for alu interface
      @(posedge vif_alu.clk)begin
      	alu_item.rst = vif_alu.rst;
        alu_item.pc = vif_alu.pc;
        vif_alu.RS1 = vif_alu.RS1;
        vif_alu.RS2 = vif_alu.RS2;
        alu_item.Funct3 = vif_alu.Funct3;
        alu_item.Funct7 = vif_alu.Funct7;
        alu_item.Imm_reg = vif_alu.Imm_reg;
        alu_item.Shamt = vif_alu.Shamt;
        alu_item.op_code = vif_alu.op_code;
      end
     
      // Capturing all outputs for alu interface
      @(posedge vif_alu.clk)begin
      	alu_item.Mem_addr = vif_alu.Mem_addr;
        alu_item.RD = vif_alu.RD;
      end

      // Capturing all inputs for rf interface
      @(posedge vif_rf.clk)begin
        vif_rf.RD_data = vif_rf.RD_data;
      	rf_item.rst = vif_alu.rst;
        rf_item.write_en = vif_rf.write_en;
        rf_item.RS1 = vif_rf.RS1;
        rf_item.RS2 = vif_rf.RS2;
        rf_item.RD = vif_rf.RD;
      end
     
      // Capturing all outputs for rf interface
      @(posedge vif_rf.clk)begin
      	rf_item.RS1_data = vif_rf.RS1_data;
        rf_item.RS2_data = vif_rf.RS2_data;
      end

      // Capturing all inputs for dmu interface
      @(posedge vif_dmu.clk)begin
      	vif_dmu.write_data = vif_dmu.write_data;
        vif_dmu.addr = vif_dmu.addr;
        dmu_item.rst = vif_dmu.rst;
        dmu_item.read_en = vif_dmu.read_en;
        dmu_item.write_en = vif_dmu.write_en;
      end
     
      // Capturing all outputs for dmu interface
      @(posedge vif_dmu.clk)begin
      	dmu_item.out_data = vif_dmu.out_data;
      end

      // Send item to scoreboard
      monitor_port.write(alu_item, rf_item, dmu_item);
    end
    
  endtask: run_phase
endclass: data_tx_monitor
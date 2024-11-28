class data_tx_driver extends uvm_driver#(alu_sequence_item);
  `uvm_component_utils(data_tx_driver)
   
  virtual alu_interface vif;
  alu_sequence_item item;

  // TODO : Create virtual interface for rf, alu, and dmu:
  // vif_rf, vif_alu, vif_dmu

  // TODO : Create sequence items for rf, alu and dmu:
  // rf_item, alu_item, dmu_item
  
  function new(string name = "data_tx_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
    

    // TODO : Include a pass/fail condition for rf, alu and dmu virtual inteface connectioj
    if(!(uvm_config_db#(virtual alu_interface)::get(this, "*",  "vif", vif)))begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!");
    end
      
  endfunction: build_phase

  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("DRIVER_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
  

  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("DRIVER_CLASS", "Inside Run Phase!", UVM_HIGH)
    
    forever begin

      // TODO : Drive the current sequence item for rf, alu, and dmu
      // Follow the logic below

      item = alu_sequence_item::type_id::create("item");
      seq_item_port.get_next_item(item);
      drive(item);
      seq_item_port.item_done();
                                               
    end
    
    
  endtask: run_phase
  


  // This driver task needs to be changed based on how th alu_top.v module is configured.
  //
  // Inputs: clk, rst, pc, RS1, RS2, Funct3, Funct7, opcode, Imm_reg, Shamt
  // Outputs: RD, Mem_addr
  //
  // RS1 & RS2 come from the register_select.v module (register file)
  // RS1 & RS2 must be driven by the register field sequence items: RS1_Data & RS2_Data
  task drive(alu_sequence_item item);
    @(posedge vif.clock)begin
      vif.reset <= item.reset;
      vif.a <= item.a;
      vif.b <= item.b;
      vif.op_code <= item.op_code;
    end
  endtask: drive

  // TODO : Need to create a rf_drive task for register file
  // Find inputs & outputs either from internal sequence item or external sequence item
  // Ex for external seq_item: vif_rf.RD_Data <= (isDMUOutput) ? vif_dmu.out_data : vif_alu.RD


  // TODO : Need to create a dmu_drive task for DMU
  // Find inputs & outputs either from internal sequence item or external sequence item
  
endclass: data_tx_driver
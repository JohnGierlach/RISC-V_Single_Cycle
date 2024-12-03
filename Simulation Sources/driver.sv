class alu_driver extends uvm_driver#(alu_sequence_item);
  `uvm_component_utils(alu_driver)
   
  virtual alu_interface vif_alu;
  virtual rf_interface vif_rf;

  alu_sequence_item alu_item;

  
  function new(string name = "alu_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
    
    if(!(uvm_config_db#(virtual alu_interface)::get(this, "*",  "vif_alu", vif_alu)))begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!");
    end

    if(!(uvm_config_db#(virtual rf_interface)::get(this, "*",  "vif_rf", vif_rf)))begin
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

      alu_item = alu_sequence_item::type_id::create("alu_item");
      seq_item_port.get_next_item(alu_item);
      alu_drive(alu_item);
      seq_item_port.item_done();
                                               
    end
            
  endtask: run_phase
  
  task alu_drive(alu_sequence_item alu_item);
    @(posedge vif_alu.clk)begin
      vif_alu.rst <= alu_item.rst;
      vif_alu.pc <= alu_item.pc;
      vif_alu.RS1 <= vif_rf.RS1_data;
      vif_alu.RS2 <= vif_rf.RS2_data;
      vif_alu.Funct3 <= alu_item.Funct3;
      vif_alu.Funct7 <= alu_item.Funct7;
      vif_alu.opcode <= alu_item.opcode;
      vif_alu.Imm_reg <= alu_item.Imm_reg;
      vif_alu.Shamt <= alu_item.Shamt;
      vif_alu.Mem_addr <= alu_item.Mem_addr;
      vif_alu.RD <= alu_item.RD;
    end
  endtask: alu_drive

endclass: alu_driver


class rf_driver extends uvm_driver#(rf_sequence_item);
  `uvm_component_utils(rf_driver)
   
  virtual alu_interface vif_alu;
  virtual rf_interface vif_rf;
  virtual dmu_interface vif_dmu;
  
  rf_sequence_item rf_item;

  function new(string name = "rf_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
    
    if(!(uvm_config_db#(virtual alu_interface)::get(this, "*",  "vif_alu", vif_alu)))begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!");
    end

    if(!(uvm_config_db#(virtual rf_interface)::get(this, "*",  "vif_rf", vif_rf)))begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!");
    end

    if(!(uvm_config_db#(virtual dmu_interface)::get(this, "*",  "vif_dmu", vif_dmu)))begin
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

      rf_item = rf_sequence_item::type_id::create("rf_item");
      seq_item_port.get_next_item(rf_item);
      rf_drive(rf_item);
      seq_item_port.item_done();
      
    end
            
  endtask: run_phase

  task rf_drive(rf_sequence_item rf_item);
    @(posedge vif_rf.clk)begin
      vif_rf.RD_data <= (vif_dmu.read_en) ? vif_dmu.out_data : vif_alu.RD;
      vif_rf.rst <= rf_item.rst;
      vif_rf.write_en <= rf_item.write_en;
      vif_rf.RS1 <= rf_item.RS1;
      vif_rf.RS2 <= rf_item.RS2;
      vif_rf.RD <= rf_item.RD;
      vif_rf.RS1_data <= rf_item.RS1_data;
      vif_rf.RS2_data <= rf_item.RS2_data;
    end
  endtask: rf_drive

  
endclass: rf_driver

class dmu_driver extends uvm_driver#(dmu_sequence_item);
  `uvm_component_utils(dmu_driver)
   
  virtual alu_interface vif_alu;
  virtual rf_interface vif_rf;
  virtual dmu_interface vif_dmu;
  
  dmu_sequence_item dmu_item;
  
  function new(string name = "dmu_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
    
    if(!(uvm_config_db#(virtual alu_interface)::get(this, "*",  "vif_alu", vif_alu)))begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!");
    end

    if(!(uvm_config_db#(virtual rf_interface)::get(this, "*",  "vif_rf", vif_rf)))begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!");
    end

    if(!(uvm_config_db#(virtual dmu_interface)::get(this, "*",  "vif_dmu", vif_dmu)))begin
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

      dmu_item = dmu_sequence_item::type_id::create("dmu_item");
      seq_item_port.get_next_item(dmu_item);
      dmu_drive(dmu_item);
      seq_item_port.item_done();
                                               
    end
            
  endtask: run_phase
  
  task dmu_drive(dmu_sequence_item dmu_item);
    @(posedge vif_dmu.clk)begin
      vif_dmu.write_data <= vif_rf.RS2_data;
      vif_dmu.addr <= vif_alu.Mem_addr;
      vif_dmu.rst <= dmu_item.rst;
      vif_dmu.read_en <= dmu_item.read_en;
      vif_dmu.write_en <= dmu_item.write_en;
      vif_dmu.out_data <= dmu_item.out_data;
    end
  endtask: dmu_drive
  
endclass: dmu_driver

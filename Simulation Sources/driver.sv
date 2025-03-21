class data_tx_driver extends uvm_driver#(data_tx_sequence_item);
  `uvm_component_utils(data_tx_driver)
   
  virtual data_tx_interface data_tx_vif;
  
  parameter R_TYPE = 7'h33, I_TYPE = 7'h13, LOAD = 7'b0000011, STORE = 7'b0100011;

  data_tx_sequence_item data_tx_item;

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
    
    if(!(uvm_config_db#(virtual data_tx_interface)::get(this, "*",  "data_tx_vif", data_tx_vif)))begin
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

      data_tx_item = data_tx_sequence_item::type_id::create("data_tx_item");
      seq_item_port.get_next_item(data_tx_item);
      drive(data_tx_item);
      seq_item_port.item_done();
      
                                               
    end
            
  endtask: run_phase
  
  task drive(data_tx_sequence_item data_tx_item);
    @(posedge data_tx_vif.clk)begin
        // Global Reset
        data_tx_vif.rst <= data_tx_item.rst;
        data_tx_vif.pc <= data_tx_item.pc;
        
        // RF Input Signals
        data_tx_vif.RS1 <= data_tx_item.RS1;
      data_tx_vif.RS2 <= (data_tx_item.opcode == I_TYPE || data_tx_item.opcode == LOAD || data_tx_item.opcode == STORE) ? data_tx_item.Imm_reg[4:0] : data_tx_item.RS2;
        data_tx_vif.RD <= data_tx_item.RD;

        // ALU Input Signals
      data_tx_vif.Funct7 <= (data_tx_item.opcode == I_TYPE || data_tx_item.opcode == LOAD || data_tx_item.opcode == STORE) ? data_tx_item.Imm_reg[11:5] : data_tx_item.Funct7;
        data_tx_vif.Funct3 <= data_tx_item.Funct3;
        data_tx_vif.Imm_reg <= data_tx_item.Imm_reg;
        data_tx_vif.Shamt <= data_tx_item.Shamt;
        data_tx_vif.opcode <= data_tx_item.opcode;

        // RF & DMU Input WE
        data_tx_vif.write_en <= data_tx_item.write_en;

        // DMU Input Signal
        data_tx_vif.read_en <= data_tx_item.read_en;

    end
  endtask: drive

endclass: data_tx_driver


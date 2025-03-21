
class data_tx_test extends uvm_test;
  `uvm_component_utils(data_tx_test)

  data_tx_env           env;
  base_sequence         reset_seq;
  init_regs_sequence    init_regs_seq;
  r_i_type_alu_sequence r_i_type_alu_seq;
  write_sequence        wr_seq;
  read_sequence         rd_seq;
  rd_wr_conflict_sequence rd_wr_c_seq;

  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "data_tx_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TEST_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST_CLASS", "Build Phase!", UVM_HIGH)

    env = data_tx_env::type_id::create("env", this);

  endfunction: build_phase

  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)

  endfunction: connect_phase

  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("TEST_CLASS", "Run Phase!", UVM_HIGH)

    phase.raise_objection(this);

    // Reset sequence, reset ALU, DMU, and RF
    reset_seq = base_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agnt.seqr);
    #10;
	
    `uvm_info("SEQUENCE", "Finished Reset Sequence", UVM_HIGH);
    
    // Initilize 32 registers with values
    repeat(32) begin
      `uvm_info("SEQUENCE", "Run Initilize Register Sequence", UVM_HIGH);
      init_regs_seq = init_regs_sequence::type_id::create("init_regs_seq");
      init_regs_seq.start(env.agnt.seqr);
      #10;
    end

    // Perform R-Type and I-Type ALU test to write to registers
    repeat(100)begin
      r_i_type_alu_seq = r_i_type_alu_sequence::type_id::create("r_i_type_alu_seq");
      r_i_type_alu_seq.start(env.agnt.seqr);
      #10;
    end

    // Write data from register file to DMU
    repeat(100)begin
      wr_seq = write_sequence::type_id::create("wr_seq");
      wr_seq.start(env.agnt.seqr);
      #10;
    end
    
    // Read data from register file to DMU
    repeat(100)begin
      rd_seq = read_sequence::type_id::create("rd_seq");
      rd_seq.start(env.agnt.seqr);
      #10;
    end
    
    repeat(100)begin
      rd_wr_c_seq = rd_wr_conflict_sequence::type_id::create("rd_wr_c_seq");
      rd_wr_c_seq.start(env.agnt.seqr);
      #10;
    end

    phase.drop_objection(this);

  endtask: run_phase


endclass: data_tx_test
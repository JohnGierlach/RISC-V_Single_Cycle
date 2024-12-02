class risc_v_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(risc_v_scoreboard)

    uvm_analysis_imp #(alu_sequence_item, dmu_sequence_item, rf_sequence_item, risc_v_scoreboard) scoreboard_port;
    alu_sequence_item alu_transactions[$];
    rf_sequence_item rf_transactions[$];
    dmu_sequence_item dmu_transactions[$];

    // Constructor
    function new(string name = "risc_v_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("SCB_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    
    //--------------------------------------------------------
    //Connect Phase
    //--------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SCB_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SCB_CLASS", "Build Phase!", UVM_HIGH)
   
        scoreboard_port = new("scoreboard_port", this);
  endfunction: build_phase
    
    // Write method
    function void write(alu_sequence_item alu_item, rf_sequence_item rf_item, dmu_sequence_item dmu_item);
    // `uvm_info("write", $sformatf("Data received = 0x%0h", data), UVM_MEDIUM)

        alu_transactions.push_back(alu_item);
        dmu_transactions.push_back(dmu_item);
        rf_transactions.push_back(rf_item);
    endfunction: write 

//--------------------------------------------------------›
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCB_CLASS", "Run Phase!", UVM_HIGH)
   
    forever begin
      alu_sequence_item alu_curr_trans;
      rf_sequence_item rf_curr_trans;
      alu_sequence_item curr_trans;
      wait((alu_curr_trans.size() != 0));

      alu_curr_trans = alu_transactions.pop_front();
      rf_curr_trans = alu_transactions.pop_front();
      dmu_curr_trans = alu_transactions.pop_front();
      compare(alu_curr_trans, rf_curr_trans, dmu_curr_trans);
      
    end
    
    //--------------------------------------------------------
  //Compare : Generate Expected Result and Compare with Actual
  //--------------------------------------------------------
  task compare(alu_sequence_item alu_curr_trans, rf_sequence_item rf_curr_trans, dmu_sequence_item dmu_curr_trans);
    logic [31:0] alu_expected_RD, alu_expected_mem_addr;
    logic [31:0] dmu_expected_out_data;
    logic [31:0] rf_expected_RS1_data, rf_expected_RS2_data;

    localparam ADD = 0, SLL = 1, SLT = 2, SLTU = 3, XOR = 4, SRL = 5, OR = 6, AND = 7, NOP = 8;
    localparam R_TYPE = 7'h33, I_TYPE_IMM = 7'h13, LOAD = 7'b0000011, STORE = 7'b0100011;

    // R-Type Instruction
    if(alu_curr_trans.opcode == R_TYPE) begin
        case(alu_curr_trans.Funct3)
            ADD:    alu_expected_RD = (alu_curr_trans.Funct7 == 7'h20) ? (rf_curr_trans.RS1_data - rf_curr_trans.RS2_data) : (rf_curr_trans.RS1_data - rf_curr_trans.RS2_data);
            SLL:    alu_expected_RD = rf_curr_trans.RS1_data << rf_curr_trans.RS2_data;
            // Potential Edge Case
            SLT:    alu_expected_RD = (rf_curr_trans.RS1_data[31] ^ rf_curr_trans.RS2_data[31]) ? rf_curr_trans.RS1_data[31] : 
                    (rf_curr_trans.RS1_data - rf_curr_trans.RS2_data)[31];
            SLTU:   alu_expected_RD = (rf_curr_trans.RS1_data < rf_curr_trans.RS2_data) ? 1'b1 : 1'b0;
            XOR:    alu_expected_RD = rf_curr_trans.RS1_data ^ rf_curr_trans.RS2_data;
            SRL:    alu_expected_RD = (alu_curr_trans.Funct7 == 7'h20) ? (rf_curr_trans.RS1_data >>> rf_curr_trans.RS2_data) : (rf_curr_trans.RS1_data >> rf_curr_trans.RS2_data);
            OR:     alu_expected_RD = rf_curr_trans.RS1_data | rf_curr_trans.RS2_data;
            AND:    alu_expected_RD = rf_curr_trans.RS1_data & rf_curr_trans.RS2_data;
            default:    alu_expected_RD = alu_expected_RD;
        endcase
    end else if (alu_curr_trans.opcode == I_TYPE) begin
        case(alu_curr_trans.Funct3)
            ADD:    alu_expected_RD = (alu_curr_trans.Funct7 == 7'h20) ? (rf_curr_trans.RS1_data - alu_curr_trans.Imm_reg) : (rf_curr_trans.RS1_data - alu_curr_trans.Imm_reg);
            SLL:    alu_expected_RD = rf_curr_trans.RS1_data << alu_curr_trans.Shamt;
            // Might be wrong
            SLT:    alu_expected_RD = (rf_curr_trans.RS1_data[31] ^ alu_curr_trans.Imm_reg[10]) ? rf_curr_trans.RS1_data[31] : 
                    (rf_curr_trans.RS1_data - alu_curr_trans.Imm_reg)[31];
            SLTU:   alu_expected_RD = (rf_curr_trans.RS1_data < alu_curr_trans.Imm_reg) ? 1'b1 : 1'b0;
            XOR:    alu_expected_RD = rf_curr_trans.RS1_data ^ alu_curr_trans.Imm_reg;
            SRL:    alu_expected_RD = (alu_curr_trans.Funct7 == 7'h20) ? (rf_curr_trans.RS1_data >>> alu_curr_trans.Shamt) : (rf_curr_trans.RS1_data >> alu_curr_trans.Shamt);
            OR:     alu_expected_RD = rf_curr_trans.RS1_data | alu_curr_trans.Imm_reg;
            AND:    alu_expected_RD = rf_curr_trans.RS1_data & alu_curr_trans.Imm_reg;
            default:    alu_expected_RD = alu_expected_RD;
        endcase
    end 
    // I-Type Load Instructon
    else if (alu_curr_trans.opcode == LOAD) begin
        alu_expected_mem_addr = rf_curr_trans.RS1_data + alu_curr_trans.Imm_reg;
    end
    // Store Instruction
    else if (alu_curr_trans.opcode == STORE) begin
        alu_expected_mem_addr = rf_curr_trans.RS1_data + alu_curr_trans.Imm_reg;
    end


    // ========================== Pass-Fail Check ========================== 

    // ALU DUT
    if (alu_curr_trans.RD != alu_expected_RD) 
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", alu_curr_trans.RD, alu_expected_RD))

    if (alu_curr_trans.Mem_addr != alu_expected_mem_addr) 
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", alu_curr_trans.Mem_addr, alu_expected_mem_addr))

    // Register File DUT
    if (rf_curr_trans.RS1_data != rf_expected_RS1_data)
         `uvm_error("COMPARE", $sformatf("Transaction failed in RF DUT! ACT=%d, EXP=%d", rf_curr_trans.RS1_data, rf_expected_RS1_data))

    if (rf_curr_trans.RS2_data != rf_expected_RS2_data)
         `uvm_error("COMPARE", $sformatf("Transaction failed in RF DUT! ACT=%d, EXP=%d", rf_curr_trans.RS2_data, rf_expected_RS2_data))

    // Data Memory DUT
    if (dmu_curr_trans.out_data != dmu_expected_out_data)
         `uvm_error("COMPARE", $sformatf("Transaction failed in DMU DUT! ACT=%d, EXP=%d", dmu_curr_trans.out_data, dmu_expected_out_data))
    else
        `uvm_error("COMPARE", $sformatf("Transaction Passed"), UVM_LOW);
    
  endtask: compare

    endtask: run_phase
endclass : risc_v_scoreboard


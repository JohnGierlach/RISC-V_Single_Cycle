class risc_v_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(risc_v_scoreboard)
    `uvm_analysis_imp_decl(_alu_scoreboard_port)	
    `uvm_analysis_imp_decl(_rf_scoreboard_port)	
    `uvm_analysis_imp_decl(_dmu_scoreboard_port)	
  
  
    uvm_analysis_imp_alu_scoreboard_port #(alu_sequence_item, risc_v_scoreboard) alu_scoreboard_port;
    uvm_analysis_imp_rf_scoreboard_port #(rf_sequence_item, risc_v_scoreboard) rf_scoreboard_port;
    uvm_analysis_imp_dmu_scoreboard_port #(dmu_sequence_item, risc_v_scoreboard) dmu_scoreboard_port;
    alu_sequence_item alu_transactions[$];
    rf_sequence_item rf_transactions[$];
    dmu_sequence_item dmu_transactions[$];

    int VECTOR_CNT, PASS_CNT, ERROR_CNT;
    bit pass;
    parameter MEM_DEPTH=128;
    parameter WIDTH=32;

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
   
        alu_scoreboard_port = new("alu_scoreboard_port", this);
        rf_scoreboard_port = new("rf_scoreboard_port", this);
        dmu_scoreboard_port = new("dmu_scoreboard_port", this);
  endfunction: build_phase
    
    // Write method
    function void write_alu_scoreboard_port(alu_sequence_item alu_item);
    //`uvm_info("write", $sformatf("Data received = 0x%0h", data), UVM_MEDIUM)
        alu_transactions.push_back(alu_item);
    endfunction: write_alu_scoreboard_port
  
    function void write_rf_scoreboard_port(rf_sequence_item rf_item);
    //`uvm_info("write", $sformatf("Data received = 0x%0h", data), UVM_MEDIUM)
        rf_transactions.push_back(rf_item);
    endfunction: write_rf_scoreboard_port
  
    function void write_dmu_scoreboard_port(dmu_sequence_item dmu_item);
    //`uvm_info("write", $sformatf("Data received = 0x%0h", data), UVM_MEDIUM)

        dmu_transactions.push_back(dmu_item);
    endfunction: write_dmu_scoreboard_port

//--------------------------------------------------------›
  //Run Phase
  //--------------------------------------------------------

    logic [WIDTH-1:0] reg_file_model [0:WIDTH-1];
    logic [WIDTH-1:0] mem_storage [0:MEM_DEPTH-1];

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCB_CLASS", "Run Phase!", UVM_HIGH)
   
    forever begin
      alu_sequence_item alu_curr_trans;
      rf_sequence_item rf_curr_trans;
      dmu_sequence_item dmu_curr_trans;
      wait((alu_transactions.size() != 0));

      alu_curr_trans = alu_transactions.pop_front();
      rf_curr_trans = rf_transactions.pop_front();
      dmu_curr_trans = dmu_transactions.pop_front();
      compare(alu_curr_trans, rf_curr_trans, dmu_curr_trans);
      
    end
  endtask: run_phase
    
    //--------------------------------------------------------
  //Compare : Generate Expected Result and Compare with Actual
  //--------------------------------------------------------
  task compare(alu_sequence_item alu_curr_trans, rf_sequence_item rf_curr_trans, dmu_sequence_item dmu_curr_trans);
    logic [WIDTH-1:0] alu_expected_RD, alu_expected_mem_addr;
    logic [WIDTH-1:0] dmu_expected_out_data;
    logic [WIDTH-1:0] rf_expected_RS1_data, rf_expected_RS2_data;

    localparam ADD = 0, SLL = 1, SLT = 2, SLTU = 3, XOR = 4, SRL = 5, OR = 6, AND = 7, NOP = 8;
    localparam R_TYPE = 7'h33, I_TYPE = 7'h13, LOAD = 7'b0000011, STORE = 7'b0100011;

    // -------------------------- ALU Model --------------------------
    // R-Type Instruction
    if(alu_curr_trans.opcode == R_TYPE) begin
        case(alu_curr_trans.Funct3)
            ADD:    alu_expected_RD = (alu_curr_trans.Funct7 == 7'h20) ? (rf_curr_trans.RS1_data - rf_curr_trans.RS2_data) : (rf_curr_trans.RS1_data - rf_curr_trans.RS2_data);
            SLL:    alu_expected_RD = rf_curr_trans.RS1_data << rf_curr_trans.RS2_data;
            // Potential Edge Case
            SLT:    alu_expected_RD = (rf_curr_trans.RS1_data[WIDTH-1] ^ rf_curr_trans.RS2_data[WIDTH-1]) ? rf_curr_trans.RS1_data[WIDTH-1] : 
            {(rf_curr_trans.RS1_data - rf_curr_trans.RS2_data)}[WIDTH-1];
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
            SLT:    alu_expected_RD = (rf_curr_trans.RS1_data[WIDTH-1] ^ alu_curr_trans.Imm_reg[11]) ? rf_curr_trans.RS1_data[WIDTH-1] : 
                    {(rf_curr_trans.RS1_data - alu_curr_trans.Imm_reg)}[WIDTH-1];
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

    // -------------------------- Register File Model --------------------------
    rf_expected_RS1_data = reg_file_model[rf_curr_trans.RS1];
    rf_expected_RS2_data = reg_file_model[rf_curr_trans.RS2];

    if (!rf_curr_trans.write_en)
        reg_file_model = (dmu_curr_trans.read_en) ? dmu_curr_trans.out_data : alu_curr_trans.RD;

    // // -------------------------- DMU Model --------------------------
    if (dmu_curr_trans.read_en) begin
        dmu_expected_out_data = mem_storage[alu_curr_trans.Mem_addr];
    end 
    else if (dmu_curr_trans.write_en) begin
        dmu_expected_out_data = 0;
        mem_storage[alu_curr_trans.Mem_addr] = rf_curr_trans.RS2_data;
    end
    

    // ========================== Pass-Fail Check ========================== 

    // ALU DUT
    if (alu_curr_trans.rst) begin
      `uvm_info("RESET", $sformatf("do not compare"), UVM_LOW)
        PASS(); // May want to remove pass
    end
    else if (alu_curr_trans.RD != alu_expected_RD) begin
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", alu_curr_trans.RD, alu_expected_RD))
        FAIL();
    end
    else if (alu_curr_trans.Mem_addr != alu_expected_mem_addr) begin
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", alu_curr_trans.Mem_addr, alu_expected_mem_addr))
        FAIL();
    end

    // Register File DUT
    else if (rf_curr_trans.RS1_data != rf_expected_RS1_data) begin
         `uvm_error("COMPARE", $sformatf("Transaction failed in RF DUT! ACT=%d, EXP=%d", rf_curr_trans.RS1_data, rf_expected_RS1_data))
        FAIL();
    end
    else if (rf_curr_trans.RS2_data != rf_expected_RS2_data) begin
         `uvm_error("COMPARE", $sformatf("Transaction failed in RF DUT! ACT=%d, EXP=%d", rf_curr_trans.RS2_data, rf_expected_RS2_data))
        FAIL();
    end

    // Data Memory DUT
    else if (dmu_curr_trans.out_data != dmu_expected_out_data) begin
         `uvm_error("COMPARE", $sformatf("Transaction failed in DMU DUT! ACT=%d, EXP=%d", dmu_curr_trans.out_data, dmu_expected_out_data))
        FAIL();
    end
    else begin
        `uvm_info("COMPARE", $sformatf("Transaction Passed"), UVM_LOW);
        PASS();
    end
    
  endtask: compare

function void PASS();
    VECTOR_CNT++;
    PASS_CNT++;
endfunction: PASS

function void FAIL();
    VECTOR_CNT++;
    ERROR_CNT++;
endfunction

endclass : risc_v_scoreboard


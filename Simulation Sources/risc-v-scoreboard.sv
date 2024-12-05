class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    `uvm_analysis_imp_decl(_data_tx_scoreboard_port)	
  
    uvm_analysis_imp_data_tx_scoreboard_port #(data_tx_sequence_item, scoreboard) data_tx_scoreboard_port;

    data_tx_sequence_item data_tx_transactions[$];

    int VECTOR_CNT, PASS_CNT, ERROR_CNT;
    bit pass;
    parameter MEM_DEPTH=128;
    parameter WIDTH=32;

    // Constructor
    function new(string name = "scoreboard", uvm_component parent = null);
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
   
        data_tx_scoreboard_port = new("data_tx_scoreboard_port", this);
  endfunction: build_phase
  
    function void write(data_tx_sequence_item data_tx_item);
    //`uvm_info("write", $sformatf("Data received = 0x%0h", data), UVM_MEDIUM)

        data_tx_transactions.push_back(data_tx_item);
    endfunction: write

//--------------------------------------------------------›
  //Run Phase
  //--------------------------------------------------------

    logic [WIDTH-1:0] reg_file_model [0:WIDTH-1];
    logic [WIDTH-1:0] mem_storage [0:MEM_DEPTH-1];

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCB_CLASS", "Run Phase!", UVM_HIGH)
   
    forever begin
      data_tx_sequence_item data_tx_curr_trans;
      wait((data_tx_transactions.size() != 0));

      data_tx_curr_trans = data_tx_transactions.pop_front();

      compare(data_tx_curr_transactions);
      
    end
  endtask: run_phase
    
    //--------------------------------------------------------
  //Compare : Generate Expected Result and Compare with Actual
  //--------------------------------------------------------
  task compare(data_tx_sequence_item data_tx_curr_trans);
    logic [WIDTH-1:0] alu_expected_data_out, alu_expected_mem_addr;
    logic [WIDTH-1:0] dmu_expected_out_data;
    logic [WIDTH-1:0] expected_RS1_data, expected_RS2_data;

    localparam ADD = 0, SLL = 1, SLT = 2, SLTU = 3, XOR = 4, SRL = 5, OR = 6, AND = 7, NOP = 8;
    localparam R_TYPE = 7'h33, I_TYPE = 7'h13, LOAD = 7'b0000011, STORE = 7'b0100011;

    expected_RS1_data = reg_file_model[data_tx_curr_trans.RS1];
    expected_RS2_data = reg_file_model[data_tx_curr_trans.RS2];

    // -------------------------- ALU Model --------------------------
    // R-Type Instruction
    if(data_tx_curr_trans.opcode == R_TYPE) begin
        case(data_tx_curr_trans.Funct3)
            ADD:    alu_expected_data_out = (data_tx_curr_trans.Funct7 == 7'h20) ? (expected_RS1_data - expected_RS2_data) : (expected_RS1_data - expected_RS2_data);
            SLL:    alu_expected_data_out = expected_RS1_data << expected_RS2_data;
            // Potential Edge Case
            SLT:    alu_expected_data_out = (expected_RS1_data[WIDTH-1] ^ expected_RS2_data[WIDTH-1]) ? expected_RS1_data[WIDTH-1] : 
            {(expected_RS1_data - expected_RS2_data)}[WIDTH-1];
            SLTU:   alu_expected_data_out = (expected_RS1_data < expected_RS2_data) ? 1'b1 : 1'b0;
            XOR:    alu_expected_data_out = expected_RS1_data ^ expected_RS2_data;
            SRL:    alu_expected_data_out = (data_tx_curr_trans.Funct7 == 7'h20) ? (expected_RS1_data >>> expected_RS2_data) : (expected_RS1_data >> expected_RS2_data);
            OR:     alu_expected_data_out = expected_RS1_data | expected_RS2_data;
            AND:    alu_expected_data_out = expected_RS1_data & expected_RS2_data;
            default:    alu_expected_data_out = alu_expected_data_out;
        endcase
    end else if (data_tx_curr_trans.opcode == I_TYPE) begin
        case(data_tx_curr_trans.Funct3)
            ADD:    alu_expected_data_out = (data_tx_curr_trans.Funct7 == 7'h20) ? (expected_RS1_data - data_tx_curr_trans.Imm_reg) : (expected_RS1_data - data_tx_curr_trans.Imm_reg);
            SLL:    alu_expected_data_out = expected_RS1_data << data_tx_curr_trans.Shamt;
            // Might be wrong
            SLT:    alu_expected_data_out = (expected_RS1_data[WIDTH-1] ^ data_tx_curr_trans.Imm_reg[11]) ? expected_RS1_data[WIDTH-1] : 
                    {(expected_RS1_data - data_tx_curr_trans.Imm_reg)}[WIDTH-1];
            SLTU:   alu_expected_data_out = (expected_RS1_data < data_tx_curr_trans.Imm_reg) ? 1'b1 : 1'b0;
            XOR:    alu_expected_data_out = expected_RS1_data ^ data_tx_curr_trans.Imm_reg;
            SRL:    alu_expected_data_out = (data_tx_curr_trans.Funct7 == 7'h20) ? (expected_RS1_data >>> data_tx_curr_trans.Shamt) : (expected_RS1_data >> data_tx_curr_trans.Shamt);
            OR:     alu_expected_data_out = expected_RS1_data | data_tx_curr_trans.Imm_reg;
            AND:    alu_expected_data_out = expected_RS1_data & data_tx_curr_trans.Imm_reg;
            default:    alu_expected_data_out = alu_expected_data_out;
        endcase
    end 
    // I-Type Load Instructon
    else if (data_tx_curr_trans.opcode == LOAD) begin
        alu_expected_mem_addr = expected_RS1_data + data_tx_curr_trans.Imm_reg;
    end

    // Store Instruction
    else if (data_tx_curr_trans.opcode == STORE) begin
        alu_expected_mem_addr = expected_RS1_data + data_tx_curr_trans.Imm_reg;
    end

    // -------------------------- Register File Write --------------------------
    if (!data_tx_curr_trans.write_en)
        reg_file_model = (data_tx_curr_trans.read_en) ? data_tx_curr_trans.out_data : data_tx_curr_trans.RD;

    // -------------------------- DMU Model --------------------------
    if (data_tx_curr_trans.read_en) begin
        dmu_expected_out_data = mem_storage[data_tx_curr_trans.Mem_addr_out];
    end 
    else if (data_tx_curr_trans.write_en) begin
        dmu_expected_out_data = 0;
        mem_storage[data_tx_curr_trans.Mem_addr_out] = data_tx_curr_trans.RS2_data;
    end
    

    // ========================== Pass-Fail Check ========================== 

    // ALU DUT
    if (data_tx_curr_trans.rst) begin
      `uvm_info("RESET", $sformatf("do not compare"), UVM_LOW)
        PASS(); // May want to remove pass
    end
    else if (data_tx_curr_trans.ALU_data_out != alu_expected_data_out) begin
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", data_tx_curr_trans.ALU_data_out, alu_expected_data_out))
        FAIL();
    end
    else if (data_tx_curr_trans.Mem_addr_out != alu_expected_mem_addr) begin
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", data_tx_curr_trans.Mem_addr_out, alu_expected_mem_addr))
        FAIL();
    end

    // Data Memory DUT
    else if (data_tx_curr_trans.dmu_out_data != dmu_expected_out_data) begin
         `uvm_error("COMPARE", $sformatf("Transaction failed in DMU DUT! ACT=%d, EXP=%d", data_tx_curr_trans.dmu_out_data, dmu_expected_out_data))
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

endclass : scoreboard


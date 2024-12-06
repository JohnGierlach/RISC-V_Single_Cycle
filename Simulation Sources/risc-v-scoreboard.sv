class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
  
    uvm_analysis_imp#(data_tx_sequence_item, scoreboard) data_tx_scoreboard_port;

    data_tx_sequence_item data_tx_transactions[$];

    logic [WIDTH-1:0] reg_file_model [0:WIDTH-1];
    logic [WIDTH-1:0] mem_storage [0:MEM_DEPTH-1];

    parameter ADD = 0, SLL = 1, SLT = 2, SLTU = 3, XOR = 4, SRL = 5, OR = 6, AND = 7;
    parameter R_TYPE = 7'h33, I_TYPE = 7'h13, LOAD = 7'b0000011, STORE = 7'b0100011;
    parameter MEM_DEPTH=128, WIDTH=32;
    int VECTOR_CNT, PASS_CNT, ERROR_CNT;
    bit pass;

    //--------------------------------------------------------
    //Constructor
    //--------------------------------------------------------
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("SCB_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    //--------------------------------------------------------
    //Build Phase
    //--------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SCB_CLASS", "Build Phase!", UVM_HIGH)
   
        data_tx_scoreboard_port = new("data_tx_scoreboard_port", this);

        for(int i = 0; i < WIDTH;i++)begin
            reg_file_model[i] = 0;
        end
        
        for(int i = 0; i < MEM_DEPTH; i++)begin
                mem_storage[i] = 0;
        end
  endfunction: build_phase

    //--------------------------------------------------------
    //Connect Phase
    //--------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SCB_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase

  
    // Write Function
    function void write(data_tx_sequence_item data_tx_item);
    //`uvm_info("write", $sformatf("Data received = 0x%0h", data), UVM_MEDIUM)

        data_tx_transactions.push_back(data_tx_item);
    endfunction: write

//--------------------------------------------------------›
//Run Phase
//--------------------------------------------------------

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCB_CLASS", "Run Phase!", UVM_HIGH)

   
    forever begin
     	data_tx_sequence_item data_tx_curr_trans;
      wait((data_tx_transactions.size() > 0));

      data_tx_curr_trans = data_tx_transactions.pop_front();

      compare(data_tx_curr_trans);
      
    end
  endtask: run_phase
    
    //--------------------------------------------------------
  //Compare : Generate Expected Result and Compare with Actual
  //--------------------------------------------------------
  task compare(data_tx_sequence_item out_tr);
    logic [WIDTH-1:0] alu_expected_data_out, alu_expected_mem_addr;
    logic [WIDTH-1:0] dmu_expected_out_data;
    logic [WIDTH-1:0] expected_RS1_data, expected_RS2_data;

    expected_RS1_data = reg_file_model[out_tr.RS1];
    expected_RS2_data = reg_file_model[out_tr.RS2];
	
   	// Reset Output signals
    if(out_tr.rst)begin
    	alu_expected_data_out = 0;
        alu_expected_mem_addr = 0;
      	dmu_expected_out_data = 0;
        expected_RS1_data = 0;
        expected_RS2_data = 0;

        for(int i = 0; i < WIDTH;i++)begin
                reg_file_model[i] = 0;
            end
        
        for(int i = 0; i < MEM_DEPTH; i++)begin
                mem_storage[i] = 0;
            end
    end
    else begin
        // -------------------------- ALU Model --------------------------
        // R-Type Instruction
        if(out_tr.opcode == R_TYPE) begin
            case(out_tr.Funct3)
                ADD:    alu_expected_data_out = (out_tr.Funct7 == 7'h20) ? (out_tr.RS1_data_out - expected_RS2_data) : 								(out_tr.RS1_data_out + expected_RS2_data);
                SLL:    alu_expected_data_out = out_tr.RS1_data_out << expected_RS2_data;
                // Potential Edge Case
                SLT:    alu_expected_data_out = (out_tr.RS1_data_out[WIDTH-1] ^ expected_RS2_data[WIDTH-1]) ? 										out_tr.RS1_data_out[WIDTH-1] : 
                  (out_tr.RS1_data_out < expected_RS2_data);
                SLTU:   alu_expected_data_out = (out_tr.RS1_data_out < expected_RS2_data) ? 1'b1 : 1'b0;
                XOR:    alu_expected_data_out = out_tr.RS1_data_out ^ expected_RS2_data;
                SRL:    alu_expected_data_out = (out_tr.Funct7 == 7'h20) ? (out_tr.RS1_data_out >>> expected_RS2_data) : 							(out_tr.RS1_data_out >> expected_RS2_data);
                OR:     alu_expected_data_out = out_tr.RS1_data_out | expected_RS2_data;
                AND:    alu_expected_data_out = out_tr.RS1_data_out & expected_RS2_data;
                default:    alu_expected_data_out = alu_expected_data_out;
            endcase
        end 
        else if (out_tr.opcode == I_TYPE) begin
            case(out_tr.Funct3)
              ADD:    alu_expected_data_out = (out_tr.Funct7 != 7'h20) ? (out_tr.RS1_data_out + out_tr.Imm_reg) : 								(out_tr.RS1_data_out - out_tr.Imm_reg);
                SLL:    alu_expected_data_out = out_tr.RS1_data_out << out_tr.RS2;
                // Might be wrong
                SLT:    alu_expected_data_out = (out_tr.RS1_data_out < out_tr.Imm_reg);
                SLTU:   alu_expected_data_out = (out_tr.RS1_data_out < out_tr.Imm_reg) ? 1'b1 : 1'b0;
                XOR:    alu_expected_data_out = out_tr.RS1_data_out ^ out_tr.Imm_reg;
                SRL:    alu_expected_data_out = (out_tr.Funct7 == 7'h20) ? (out_tr.RS1_data_out >>> out_tr.RS2) : 								(out_tr.RS1_data_out >> out_tr.RS2);
                OR:     alu_expected_data_out = out_tr.RS1_data_out | out_tr.Imm_reg;
                AND:    alu_expected_data_out = out_tr.RS1_data_out & out_tr.Imm_reg;
                default:    alu_expected_data_out = alu_expected_data_out;
            endcase
        end 
        // I-Type Load Instructon
        else if (out_tr.opcode == LOAD) begin
            alu_expected_mem_addr = out_tr.RS1_data_out + out_tr.Imm_reg;
            if (out_tr.read_en) begin
                dmu_expected_out_data = mem_storage[alu_expected_mem_addr];
            end 
        end
        // Store Instruction
        else if (out_tr.opcode == STORE) begin
            alu_expected_mem_addr = out_tr.RS1_data_out + out_tr.Imm_reg;
            if (out_tr.write_en) begin
                dmu_expected_out_data = 0;
                mem_storage[out_tr.Mem_addr_out] = out_tr.RS2_data_out;
            end
        end

        // -------------------------- Register File Write --------------------------
        if (!out_tr.write_en)
            reg_file_model[out_tr.RD] = (out_tr.read_en) ? out_tr.dmu_out_data : out_tr.ALU_data_out;

        // -------------------------- DMU Model --------------------------

    end
    // ========================== Pass-Fail Check ========================== 
	
    // ALU DUT
    if (out_tr.rst) begin
      `uvm_info("RESET", $sformatf("do not compare"), UVM_LOW)
        PASS(); // May want to remove pass
    end
    else if (out_tr.ALU_data_out != alu_expected_data_out) begin
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", out_tr.ALU_data_out, alu_expected_data_out))
          `uvm_info("VALUES", $sformatf("RS1:%d RS2:%d RD:%d Imm_Reg:%d Op:%b, Funct3:%b, Re:%d We:%d, Shamt:%d", out_tr.RS1,out_tr.RS2, 
                                                                                        out_tr.RD,
                                                                                        out_tr.Imm_reg,
                                                                                        out_tr.opcode,
                                  														out_tr.Funct3,
                                                                                        out_tr.read_en,
                                   									                    out_tr.write_en,
                                                                                        out_tr.Shamt), UVM_LOW)
    
    `uvm_info("VALUES", $sformatf("ALU_data_out:%d\tMem_addr_out:%d\tRS1_D:%d\tRS2_D:%d\tDMU_Data:%d",  out_tr.ALU_data_out,
                                                                                     out_tr.Mem_addr_out,
                                   										             out_tr.RS1_data_out,
                                   									                 out_tr.RS2_data_out,
                                                                                     out_tr.dmu_out_data), UVM_LOW)
    
    `uvm_info("VALUES", $sformatf("EXP_ALU_out:%d\tEXP_Mem_addr:%d\tEXP_RS1:%d\tEXP_RS2:%d\tEXP_DMU_Data:%d", alu_expected_data_out,
                                                                                                alu_expected_mem_addr,
                                                                                                expected_RS1_data,
                                  																expected_RS2_data,
                                 																dmu_expected_out_data), UVM_LOW)
        FAIL();
    end
    else if (out_tr.Mem_addr_out != alu_expected_mem_addr) begin
        `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", out_tr.Mem_addr_out, alu_expected_mem_addr))
              `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", out_tr.ALU_data_out, alu_expected_data_out))
          `uvm_info("VALUES", $sformatf("RS1:%d RS2:%d RD:%d Imm_Reg:%d Op:%b, Funct3:%b, Re:%d We:%d, Shamt:%d", out_tr.RS1,out_tr.RS2, 
                                                                                        out_tr.RD,
                                                                                        out_tr.Imm_reg,
                                                                                        out_tr.opcode,
                                  														out_tr.Funct3,
                                                                                        out_tr.read_en,
                                   									                    out_tr.write_en,
                                                                                        out_tr.Shamt), UVM_LOW)
    
    `uvm_info("VALUES", $sformatf("ALU_data_out:%d\tMem_addr_out:%d\tRS1_D:%d\tRS2_D:%d\tDMU_Data:%d",  out_tr.ALU_data_out,
                                                                                     out_tr.Mem_addr_out,
                                   										             out_tr.RS1_data_out,
                                   									                 out_tr.RS2_data_out,
                                                                                     out_tr.dmu_out_data), UVM_LOW)
    
    `uvm_info("VALUES", $sformatf("EXP_ALU_out:%d\tEXP_Mem_addr:%d\tEXP_RS1:%d\tEXP_RS2:%d\tEXP_DMU_Data:%d", alu_expected_data_out,
                                                                                                alu_expected_mem_addr,
                                                                                                expected_RS1_data,
                                  																expected_RS2_data,
                                 																dmu_expected_out_data), UVM_LOW)
        FAIL();
    end

    // Data Memory DUT
    else if (out_tr.dmu_out_data != dmu_expected_out_data) begin
         `uvm_error("COMPARE", $sformatf("Transaction failed in DMU DUT! ACT=%d, EXP=%d", out_tr.dmu_out_data, dmu_expected_out_data))
              `uvm_error("COMPARE", $sformatf("Transaction failed in ALU DUT! ACT=%d, EXP=%d", out_tr.ALU_data_out, alu_expected_data_out))
          `uvm_info("VALUES", $sformatf("RS1:%d RS2:%d RD:%d Imm_Reg:%d Op:%b, Funct3:%b, Re:%d We:%d, Shamt:%d", out_tr.RS1,out_tr.RS2, 
                                                                                        out_tr.RD,
                                                                                        out_tr.Imm_reg,
                                                                                        out_tr.opcode,
                                  														out_tr.Funct3,
                                                                                        out_tr.read_en,
                                   									                    out_tr.write_en,
                                                                                        out_tr.Shamt), UVM_LOW)
    
    `uvm_info("VALUES", $sformatf("ALU_data_out:%d\tMem_addr_out:%d\tRS1_D:%d\tRS2_D:%d\tDMU_Data:%d",  out_tr.ALU_data_out,
                                                                                     out_tr.Mem_addr_out,
                                   										             out_tr.RS1_data_out,
                                   									                 out_tr.RS2_data_out,
                                                                                     out_tr.dmu_out_data), UVM_LOW)
    
    `uvm_info("VALUES", $sformatf("EXP_ALU_out:%d\tEXP_Mem_addr:%d\tEXP_RS1:%d\tEXP_RS2:%d\tEXP_DMU_Data:%d", alu_expected_data_out,
                                                                                                alu_expected_mem_addr,
                                                                                                expected_RS1_data,
                                  																expected_RS2_data,
                                 																dmu_expected_out_data), UVM_LOW)
        FAIL();
    end
    else begin
      `uvm_info("COMPARE", $sformatf("Transaction Passed!"), UVM_LOW);
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
// Object class


class data_tx_sequence_item extends uvm_sequence_item;
	
  `uvm_object_utils(data_tx_sequence_item)
  
  parameter WIDTH = 32;
  localparam R_TYPE = 7'h33, I_TYPE = 7'h13, LOAD = 7'b0000011, STORE = 7'b0100011;
  // Instantiations
  
  //-------------------------------- ALU Constraints --------------------------------

  // Inputs
  rand logic rst;
  rand logic[WIDTH-1:0] pc;
  rand logic[2:0] Funct3;
  rand logic[6:0] Funct7;
  rand logic[6:0] opcode;
  rand logic[11:0] Imm_reg;
  rand logic[4:0] Shamt;
  
  // Default Constraints

  // Will never use pc for data_tx test
  constraint pc_c{
    pc == 0;
  }

  // Equal 25% chance to either be R-Type or I-Type instruction
  constraint opcode_c{
    opcode dist {
      R_TYPE := 1, // R-Type
      I_TYPE := 1, // I-Type
	  LOAD   := 1,
      STORE  := 1
    };
  }
  
  // Equal probabiltiy of being ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND, NOP; 
  constraint Funct3_c{
    Funct3 dist {[0:8]:=1};
  }

  // When ADD/ADDI or SRL/SRLI have a 50% chance to do SUB or SRA respectively
  constraint Funct7_c{  
    
    if ((Funct3 == 3'b000 || Funct3 == 3'b101)) {
      Funct7 dist {
        7'h00 := 1, // 0
        7'h20 := 1  // 0x20
      };
    }

    else
      Funct7 == 0;
  }

  // Set Imm_reg to 0-2047 with more chances to hit 40% chance to test values between 0 and 2047
  constraint Imm_reg_c{
    Imm_reg dist {
       12'h000 :/ 3, 
       12'hfff :/ 3, 
      [12'h001:12'hffe] :/4
       };
  }

  constraint Shamt_c{
    Shamt dist {[0:31] := 1};
  }
  // Outputs
  logic[WIDTH-1:0] ALU_data_out;
  logic[WIDTH-1:0] Mem_addr_out;

  
  //------------------------ End of ALU Constraints ---------------------------------

  //-------------------------------- RF Constraints ---------------------------------

  // Inputs
  rand logic write_en;
  randc logic[4:0] RS1, RS2, RD;

  // Register Constraints across all 32 possible registers
  constraint RS1_c{RS1 inside {[0:31]};}
  constraint RS2_c{RS2 inside {[0:31]};}
  constraint RD_c {RD inside {[0:31]};}

   // Outputs
  logic[WIDTH-1:0] RS1_data_out, RS2_data_out;

  //-------------------------------- End of RF Constraints --------------------------
  

  //-------------------------------- DMU Constraints --------------------------------

    // Inputs 
  rand logic read_en;
  
  
  // Outputs
  logic[WIDTH-1:0] dmu_out_data;
  
  function new(string name = "data_tx_sequence_item");
    super.new(name);
  endfunction: new

  //------------------------------- End of DMU Constraints --------------------------
	
endclass

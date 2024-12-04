// Object class


class data_tx_sequence_item extends uvm_sequence_item;
	
  `uvm_object_utils(data_tx_sequence_item)
  
  parameter WIDTH = 32;

  // Instantiations
  
  //-------------------------------- ALU Constraints --------------------------------

  // Inputs
  rand logic rst;
  rand logic[WIDTH-1:0] pc;
  // rand logic[WIDTH-1:0] RS1, RS1; | Gets these values from Register file intf
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

  // Equal 50% chance to either be R-Type or I-Type instruction
  constraint opcode_c{
    opcode dist {
      7'h33 := 1, // R-Type
      7'h13 := 1 // I-Type
    };
  }
  
  // Equal probabiltiy of being ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND, NOP; 
  constraint Funct3_c{
    Funct3 dist {[0:8]:=1};
  }

  // When ADD/ADDI or SRL/SRLI have a 50% chance to do SUB or SRA respectively
  constraint Funct7_c{  
    if (Funct3 == 3'b000 || Funct3 == 3'b101) {
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
       11'h000 :/ 3, 
       11'h3ff :/ 3, 
       [11'h001:11'h3fe] :/4
       };
  }

  constraint Shamt_c{
    Shamt dist {[0:31] := 1};
  }
  // Outputs
  logic[WIDTH-1:0] RD;
  logic[WIDTH-1:0] Mem_addr;

  
  //------------------------ End of ALU Constraints ---------------------------------

  //-------------------------------- RF Constraints ---------------------------------

  // Inputs
  rand logic write_en;
  rand logic[4:0] RS1, RS2, RD;

  // Register Constraints across all 32 possible registers
  constraint RS1_c{RS1 inside {[1:31]};}
  constraint RS2_c{RS2 inside {[1:31]};}
  constraint RD_c {RD inside {[1:31]};}

   // Outputs
  logic[WIDTH-1:0] RS1_data, RS2_data;

  //-------------------------------- End of RF Constraints --------------------------
  

  //-------------------------------- DMU Constraints --------------------------------

    // Inputs 
  rand logic rst;
  rand logic read_en, write_en;
  
  
  // Outputs
  logic[WIDTH-1:0] out_data;
  
  function new(string name = "data_tx_sequence_item");
    super.new(name);
  endfunction: new

  //------------------------------- End of DMU Constraints --------------------------
	
endclass

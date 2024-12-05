class coverage extends uvm_subscriber # (data_tx_sequence_item);
`uvm_component_utils(coverage)

uvm_analysis_imp#(data_tx_sequence_item, coverage) data_tx_coverage_port;

function new(string name = "coverage", uvm_component parent);
  super.new(name,parent);
    dut_cov = new();
endfunction

data_tx_sequence_item txn;
real coverage_percentage;
localparam ADD = 0, SLL = 1, SLT = 2, SLTU = 3, XOR = 4, SRL = 5, OR = 6, AND = 7, NOP = 8; 
localparam R_TYPE = 7'h33, I_TYPE = 7'h13, LOAD = 7'b0000011, STORE = 7'b0100011, BRANCH = 7'b1100011, JUMP = 7'b1101111;
parameter MEM_DEPTH=128;
parameter WIDTH=32;

covergroup dut_cov;
    option.per_instance=1;
    // Arbitrary number of bins
    cp_RS1_data: coverpoint txn.RS1_data_out {option.auto_bin_max=8;}
    cp_RS2_data: coverpoint txn.RS2_data_out {option.auto_bin_max=8;}
    cp_dmu_out_data: coverpoint txn.dmu_out_data {option.auto_bin_max=8;}
    cp_alu_data_out: coverpoint txn.ALU_data_out {option.auto_bin_max=8;}
    cp_imm_reg: coverpoint txn.Imm_reg iff (txn.opcode == I_TYPE) {option.auto_bin_max=8;}

    cp_opcode: coverpoint txn.opcode{
        bins r_type_op = {R_TYPE};
        bins i_type_op = {I_TYPE};
        bins load_op = {LOAD};
        bins store_op = {STORE};
        bins branch_op = {BRANCH};
        bins jump_op = {JUMP};
        bins other = default;
    }
    
    cp_Funct3: coverpoint txn.Funct3{
        bins add = {ADD};
        bins sll = {SLL};
        bins slt = {SLT};
        bins sltu = {SLTU};
        bins Xor = {XOR};
        bins srl = {SRL};
        bins Or = {OR};
        bins And = {AND};
        bins nop = {NOP};
        bins other = default;
    }

    cp_Funct7: coverpoint txn.Funct7 iff (txn.opcode==R_TYPE || txn.opcode==I_TYPE)
    {
        bins zero = {'0};
        bins nonzero = default;
    }

  cp_shamt: coverpoint txn.Shamt iff (txn.opcode==I_TYPE && (txn.Funct3 == SLL || txn.Funct3 == SRL))
    {
        option.auto_bin_max=32;
    }

    cp_arithmetic_instructions: cross cp_opcode, cp_Funct3;

    cp_write_enable: coverpoint txn.write_en {
        bins enable_low = {0};
        bins enable_high = {1};
    }

    cp_read_enable: coverpoint txn.read_en {
        bins enable_low = {0};
        bins enable_high = {1};
    }

    // Coverpoints for register file port accesses
   cp_RS1_access: coverpoint txn.RS1{option.auto_bin_max=32;}
   cp_RS2_access: coverpoint txn.RS2{option.auto_bin_max=32;}
   cp_RD_access: coverpoint txn.RD{option.auto_bin_max=32;}

    // Coverpoint for memory address accesses
    cp_mem_addr: coverpoint txn.Mem_addr_out iff (txn.opcode==LOAD || txn.opcode==STORE)
  {option.auto_bin_max=MEM_DEPTH;}

endgroup : dut_cov

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("COVERAGE_CLASS", "Build Phase!", UVM_HIGH)

    data_tx_coverage_port = new("data_tx_coverage_port", this);
endfunction : build_phase

function void write(data_tx_sequence_item t);
    txn = t;
    dut_cov.sample();
endfunction

function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    coverage_percentage = dut_cov.get_coverage();
endfunction

function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),$sformatf("Coverage is %f",coverage_percentage),UVM_LOW)
endfunction

endclass : coverage
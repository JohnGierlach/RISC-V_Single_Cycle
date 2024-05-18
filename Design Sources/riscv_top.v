`timescale 1ns / 1ps

module riscv_top #(parameter WIDTH = 32)
    (
    input clk,
    input rst,
    output[WIDTH-1:0] rd
    );
    
    
    // Wires for passing along data processed from engines
    wire[WIDTH-1:0] RS1_data, RS2_data, RD_data, ALU_data, MEM_data, Mem_addr;
    
    wire[WIDTH-1:0] new_pc, curr_pc;
    
    // FW wires
    wire[4:0] RD, RS2, RS1;
    wire[6:0] Funct7;
    wire[2:0] Funct3;
    wire[6:0] opcode;
    
    
    wire read_en, write_en, branch, take_branch, jump;
    
    program_counter PC(.clk(clk),
                       .rst(rst),
                       .new_pc(new_pc),
                       .out_pc(curr_pc));
    
    // Stores instructions in memory & fetches them from processing
    instruction_mem INSTRUCTION_MEMORY(.clk(clk), 
                                       .rst(rst), 
                                       .pc(curr_pc),
                                       .offset(new_pc),
                                       .RD(RD),
                                       .RS1(RS1),
                                       .RS2(RS2),
                                       .Funct3(Funct3),
                                       .Funct7(Funct7),
                                       .read_en(read_en),
                                       .write_en(write_en),
                                       .branch(branch),
                                       .jump(jump),
                                       .opcode(opcode));    
    
    // Register select module 
    register_select REG_FILE_SELECT(.clk(clk), 
                                    .rst(rst),
                                    .write_en(write_en), 
                                    .RD_data(RD_data), 
                                    .RS1_data(RS1_data), 
                                    .RS2_data(RS2_data), 
                                    .RS1(RS1),
                                    .RS2(RS2),
                                    .RD(RD));  
                                      
    // ALU engine to perform math calculations
    alu_top ALU_ENGINE(.clk(clk), 
                       .rst(rst),
                       .pc(curr_pc), 
                       .RS1(RS1_data), 
                       .RS2(RS2_data), 
                       .Funct3(Funct3), 
                       .Funct7(Funct7), 
                       .RD(ALU_data),
                       .Mem_addr(Mem_addr), 
                       .Imm_reg({Funct7, RS2}),
                       .Shamt(RS2),
                       .opcode(opcode));
                 
    

    
    // Data memory unit (DMU) for loading and storing data from/to memory
    dmu_engine DATA_MEMORY(.clk(clk),
                           .rst(rst),
                           .read_en(read_en),
                           .write_en(write_en),
                           .addr(Mem_addr),
                           .write_data(RS2_data),
                           .out_data(MEM_data));
    
    assign new_pc = branch ? Funct7: jump ? {Funct7, RS2, RS1, Funct3}:curr_pc;
    assign RD_data = read_en ? MEM_data:ALU_data;                                                                    
    assign rd = RD_data;
endmodule

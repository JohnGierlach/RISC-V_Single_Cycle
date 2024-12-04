module data_tx_top #(parameter WIDTH = 32)(
    input clk, 
    input rst, 
    input pc,
    input[2:0] Funct3,
    input[6:0] Funct7,
    input[6:0] opcode,
    input[11:0] Imm_reg,
    input[4:0] Shamt,
    input write_en, read_en,
    input[4:0] RS1, RS2, RD,
    output[WIDTH-1:0] ALU_data_out,
    output [WIDTH-1:0] Mem_addr_out,
    output[WIDTH-1:0] RS2_data_out, RS1_data_out,
    output[WIDTH-1:0] dmu_out_data
);

    wire[WIDTH-1:0] RS1_data, RS2_data, RD_data, MEM_data, ALU_data;

    wire[WIDTH-1:0] Mem_addr;

    // Register select module 
    register_select REG_FILE_SELECT(.clk(clk), 
                                    .rst(rst),
                                    .write_en(write_en), 
                                    .RD_data(RD_data), 
                                    .RS1_data(RS1_data), 
                                    .RS2_data(RS2_data), 
                                    .RS1(RS1),
                                    .RS2(RS2),
                                    .RD(RD_data));  
                                      
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

    assign RD_data = read_en ? MEM_data:ALU_data; 

    // Register File Debug Bus
    assign RS1_data_out = RS1_data;
    assign RS2_data_out = RS2_data;

    // ALU Debug Bus
    assign ALU_data_out = ALU_data;
    assign Mem_addr_out = Mem_addr;

    // DMU Debug Bus
    assign dmu_out_data = MEM_data

endmodule
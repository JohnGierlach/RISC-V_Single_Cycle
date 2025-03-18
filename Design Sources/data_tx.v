module data_tx_top #(parameter WIDTH = 32)(
    input clk, 
    input rst, 
    input[WIDTH-1:0] pc,
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
    wire[WIDTH-1:0] reg_debug [0:WIDTH-1];
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
                                    .RD(RD),
                                    .reg0(reg_debug[0]),  
                                    .reg1(reg_debug[1]),  
                                    .reg2(reg_debug[2]),  
                                    .reg3(reg_debug[3]),  
                                    .reg4(reg_debug[4]),  
                                    .reg5(reg_debug[5]),  
                                    .reg6(reg_debug[6]),  
                                    .reg7(reg_debug[7]),  
                                    .reg8(reg_debug[8]),  
                                    .reg9(reg_debug[9]),  
                                    .reg10(reg_debug[10]),  
                                    .reg11(reg_debug[11]),  
                                    .reg12(reg_debug[12]),  
                                    .reg13(reg_debug[13]),  
                                    .reg14(reg_debug[14]),  
                                    .reg15(reg_debug[15]),  
                                    .reg16(reg_debug[16]),  
                                    .reg17(reg_debug[17]),  
                                    .reg18(reg_debug[18]),  
                                    .reg19(reg_debug[19]),  
                                    .reg20(reg_debug[20]),  
                                    .reg21(reg_debug[21]),  
                                    .reg22(reg_debug[22]),  
                                    .reg23(reg_debug[23]),  
                                    .reg24(reg_debug[24]),  
                                    .reg25(reg_debug[25]),  
                                    .reg26(reg_debug[26]),  
                                    .reg27(reg_debug[27]),  
                                    .reg28(reg_debug[28]),  
                                    .reg29(reg_debug[29]),  
                                    .reg30(reg_debug[30]),  
                                    .reg31(reg_debug[31]));  
                                      
    // ALU engine to perform math calculations
    alu_top ALU_ENGINE(.clk(clk), 
                       .rst(rst),
                       .pc(pc), 
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
    assign dmu_out_data = MEM_data;
  

endmodule

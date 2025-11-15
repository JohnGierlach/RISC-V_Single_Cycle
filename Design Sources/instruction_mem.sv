module instruction_mem #(parameter WIDTH = 32)
    (
    input clk,
    input rst,
    input[WIDTH-1:0] pc,
    input[WIDTH-1:0] offset,
    output [4:0] RD, RS2, RS1,
    output [6:0] Funct7,
    output [2:0] Funct3,
    output [6:0] opcode,
    output read_en, mem_write_en, reg_write_en, branch, jump
    );
    
    // FW registers
    reg[4:0] rd, rs2, rs1;
    reg[6:0] funct7;
    reg[2:0] funct3;
    reg[6:0] Opcode;
    
    localparam NUM_INST = 4;
    
    // Last instruction must be a NO-OP 
reg [WIDTH-1:0] inst_rom [0:NUM_INST-1] = 
{
    32'h00550513, // ADDI x10, x0, 5
    32'h17000593, // ADDI x11, x0, 368
    32'h22B50633, // MUL x12, x10, x11
    32'h00000000  // padding / NOP
};




    always@(posedge clk)begin
        if(rst)begin
            rd <= 5'b0;
            rs2 <= 5'b0;
            rs1 <= 5'b0;
            funct7 <= 7'b0;
            funct3 <= 3'b0;
            Opcode <= 7'b0;
        end
        
        else begin
            if(pc/4 < NUM_INST)begin
                if(pc == 0)begin
                Opcode <= {inst_rom[0][6:0]};
                rd     <= {inst_rom[0][11:7]};
                funct3 <= {inst_rom[0][14:12]};
                rs1    <= {inst_rom[0][19:15]};
                rs2    <= {inst_rom[0][24:20]};
                funct7 <= {inst_rom[0][31:25]}; 
                end
                
                else begin
                    if(branch || jump)begin
                        Opcode <= {inst_rom[offset/4][6:0]};
                        rd     <= {inst_rom[offset/4][11:7]};
                        funct3 <= {inst_rom[offset/4][14:12]};
                        rs1    <= {inst_rom[offset/4][19:15]};
                        rs2    <= {inst_rom[offset/4][24:20]};
                        funct7 <= {inst_rom[offset/4][31:25]};
                    end
                    else begin
                        Opcode <= {inst_rom[pc/4][6:0]};
                        rd     <= {inst_rom[pc/4][11:7]};
                        funct3 <= {inst_rom[pc/4][14:12]};
                        rs1    <= {inst_rom[pc/4][19:15]};
                        rs2    <= {inst_rom[pc/4][24:20]};
                        funct7 <= {inst_rom[pc/4][31:25]};
                    end
                end
            end
        end
    end
    
    assign RD = rd;
    assign RS1 = rs1;
    assign RS2 = rs2;
    assign Funct3 = funct3;
    assign Funct7 = funct7;
    assign opcode = Opcode;
    assign read_en = Opcode == 7'b0000011 ? 1:0;
    assign mem_write_en = Opcode == 7'b0100011 ? 1:0;
    assign reg_write_en = Opcode == 7'b0110011 | Opcode == 7'b0010011 ? 1:0;
    assign branch = (Opcode == 7'b1100011) ? 1:0;
    assign jump = (Opcode == 7'b1101111) ? 1:0;
    
endmodule

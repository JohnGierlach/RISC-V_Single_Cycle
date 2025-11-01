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
    
    localparam NUM_INST = 11;
    
    // Last instruction must be a NO-OP 
reg [WIDTH-1:0] inst_rom [0:NUM_INST-1] = 
{
    32'h00550513, // ADDI x10, x0, 5304
    32'h17000593, // ADDI x11, x0, 5
    32'h00000613, // ADDI x12, x0, 0
    32'h00100693, // ADDI x13, x0, 1
    32'h00058663, // BEQ x11, x0, done
    32'h00A60633, // ADD x12, x12, x10
    32'h40D585B3, // SUB x11, x11, x13
    32'h0001486F, // JAL x16, loop
    32'h00160533, // ADD x10, x12, x1
    32'h0000006F, // JAL x16, done
    32'h00000000  // NOP (padding)
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

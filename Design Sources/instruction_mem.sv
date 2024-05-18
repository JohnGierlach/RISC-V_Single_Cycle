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
    output read_en, write_en, branch, jump
    );

    reg[WIDTH-1:0] addr;
    
    // FW registers
    reg[4:0] rd, rs2, rs1;
    reg[6:0] funct7;
    reg[2:0] funct3;
    reg[6:0] Opcode;
    
    localparam NUM_INST = 19;
    
    // Last instruction must be a NO-OP 
    reg[WIDTH-1:0] inst_rom [0:NUM_INST-1] = 
    {
        32'h00A08093, //ADDI
        32'h00A10113, //ADDI
        32'h001101B3, //ADD
        32'h18208663, //BEQ
        32'h00312233, //SLT
        32'h00115293, //SRLI
        32'h00211313, //SLLI
        32'h0032F3B3, //AND
        32'h0001886F, //JAL
        32'h0032E433, //OR
        32'h0032C4B3, //XOR
        32'h40610533, //SUB
        32'h004155B3, //SRL
        32'h08A02223, //SW
        32'h00411633, //SLL
        32'h40555693, //SRAI
        32'h40555733, //SRA
        32'h00402783, //LW
        32'h0         //NO-OP
    };

    always@(posedge clk)begin
        if(rst)
            addr <= 32'b0;
            
        else
            if(pc/4 < NUM_INST)begin
                if(pc == 0)
                    addr <= inst_rom[0];
                
                else
                    if(branch)
                        addr <= inst_rom[(pc+offset-4)/4];
                    else 
                        addr <= inst_rom[pc/4];
            end
    end

    // Extract machine code to run proper FW assembly
    always@(posedge clk)begin 
        if(rst) begin
            rd <= 5'b0;
            rs2 <= 5'b0;
            rs1 <= 5'b0;
            funct7 <= 7'b0;
            funct3 <= 3'b0;
            Opcode <= 7'b0;
        end
            
        else begin
                Opcode <= {addr[6:0]};
                rd     <= {addr[11:7]};
                funct3 <= {addr[14:12]};
                rs1    <= {addr[19:15]};
                rs2    <= {addr[24:20]};
                funct7 <= {addr[31:25]};
        end
    end
    
    assign RD = rd;
    assign RS1 = rs1;
    assign RS2 = rs2;
    assign Funct3 = funct3;
    assign Funct7 = funct7;
    assign opcode = Opcode;
    assign read_en = Opcode == 7'b0000011 ? 1:0;
    assign write_en = Opcode == 7'b0100011 ? 1:0;
    assign branch = (Opcode == 7'b1100011) ? 1:0;
    assign jump = (Opcode == 7'b1101111) ? 1:0;
    
endmodule

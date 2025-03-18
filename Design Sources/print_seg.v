`timescale 1ns / 1ps

module print_seg(
    input[3:0] reg_hex,
    input slowClk, reset,
    output reg [6:0] outSeg
    );

    
     // Start of Decoder
     always @(posedge slowClk or posedge reset)
     begin
        if(reset)
            outSeg <= 7'b0000001;

        case (reg_hex)
            4'h0: outSeg = 7'b1000000;
            4'h1: outSeg = 7'b1111001;
            4'h2: outSeg = 7'b0100100;
            4'h3: outSeg = 7'b0110000;
            4'h4: outSeg = 7'b0011001;
            4'h5: outSeg = 7'b0010010;
            4'h6: outSeg = 7'b0000010;
            4'h7: outSeg = 7'b1111000;
            4'h8: outSeg = 7'b0000000;
            4'h9: outSeg = 7'b0011000;
            4'ha: outSeg = 7'b1000000;
            4'hb: outSeg = 7'b1111001;
            4'hc: outSeg = 7'b0100100;
            4'hd: outSeg = 7'b0110000;
            4'he: outSeg = 7'b0011001;
            4'hf: outSeg = 7'b0010010;
            default: outSeg = 7'b1000000;
        endcase
     end

endmodule
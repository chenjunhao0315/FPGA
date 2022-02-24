`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/09 23:37:33
// Design Name: 
// Module Name: display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module display(in, ssd);
    input [3:0] in;         // binary code input
    output [7:0] ssd;       // seven segment display signal output
    
    reg [7:0] ssd;          // output signal (in always block)

// Combinational logics : muxs    
    always @ *
    begin
        case (in)
            4'd0: ssd = 8'b00000011;
            4'd1: ssd = 8'b10011111;
            4'd2: ssd = 8'b00100101;
            4'd3: ssd = 8'b00001101;
            4'd4: ssd = 8'b10011001;
            4'd5: ssd = 8'b01001001;
            4'd6: ssd = 8'b01000001;
            4'd7: ssd = 8'b00011111;
            4'd8: ssd = 8'b00000001;
            4'd9: ssd = 8'b00001001;
            4'ha: ssd = 8'b00110001;
            4'hb: ssd = 8'b11100011;
            4'hc: ssd = 8'b00010001;
            4'hd: ssd = 8'b10001001;
            4'he: ssd = 8'b10000101;
            4'hf: ssd = 8'b01100001;
            default: ssd = 8'b11111111;
        endcase
    end
endmodule

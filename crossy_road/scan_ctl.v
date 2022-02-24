`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/09 23:37:15
// Design Name: 
// Module Name: scan_ctl
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


module scan_ctl(clk_scan, ssd_output, ssd_ctl, in_4, in_3, in_2, in_1);
    input [1:0] clk_scan;           // clock for scan
    input [3:0] in_1;               // input 1
    input [3:0] in_2;               // input 2
    input [3:0] in_3;               // input 3
    input [3:0] in_4;               // input 4
    output reg [3:0] ssd_output;    // signal to seven segment display decoder
    output reg [3:0] ssd_ctl;       // seven segment display control
    
    always @ *
    begin
        case (clk_scan)
            2'b00:
            begin
                ssd_ctl = 4'b0111;
                ssd_output = in_4;
            end
            2'b01:
            begin
                ssd_ctl = 4'b1011;
                ssd_output = in_3;
            end
            2'b10:
            begin
                ssd_ctl = 4'b1101;
                ssd_output = in_2;
            end
            2'b11:
            begin
                ssd_ctl = 4'b1110;
                ssd_output = in_1;
            end
            default:
            begin
                ssd_ctl = 4'b0000;
                ssd_output = 4'b0;
            end
        endcase
    end
endmodule

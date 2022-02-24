`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/05 16:45:57
// Design Name: 
// Module Name: buzzer_control
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


module buzzer_control_right(clk, rst_n, note_div, audio_right);
    input clk;
    input rst_n;
    input [21:0] note_div;
    output [15:0] audio_right;
    
    reg [21:0] clk_cnt_next;
    reg [21:0] clk_cnt;
    reg b_clk;
    reg b_clk_next;
    
    always @ (posedge clk or negedge rst_n)
        if (~rst_n) 
            begin
            clk_cnt <= 22'd0;
            b_clk <= 1'b0; 
            end
        else 
            begin
            clk_cnt <= clk_cnt_next;
            b_clk <= b_clk_next; 
            end
            
    always @ *
        if (clk_cnt == note_div) 
            begin
            clk_cnt_next = 22'd0;
            b_clk_next = ~b_clk; 
            end
        else 
            begin
            clk_cnt_next = clk_cnt + 1'b1;
            b_clk_next = b_clk; 
            end
            
    assign audio_right = (b_clk == 1'b0) ? 16'hB000 : 16'h5FFF;         
    
endmodule

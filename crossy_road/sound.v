`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 00:57:36
// Design Name: 
// Module Name: sound
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


module sound(clk, rst_n, audio_mclk, audio_lrck, audio_sck, audio_sdin, dead, light);
    input clk, rst_n;
    input dead, light;
    output audio_mclk, audio_lrck, audio_sck;
    output audio_sdin;
    wire [21:0]out_note_left, out_note_right;
    wire [15:0]audio_left, audio_right;

    speaker_control A(
        .clk(clk),
        .rst_n(rst_n),
        .audio_left(audio_left),
        .audio_right(audio_right),
        .audio_mclk(audio_mclk),
        .audio_lrck(audio_lrck),
        .audio_sck(audio_sck),
        .audio_sdin(audio_sdin)
    );
    
    buzzer_control_left left(
        .clk(clk),
        .rst_n(rst_n),
        .note_div(out_note_left),
        .audio_left(audio_left)
    );
    
    buzzer_control_right right(
        .clk(clk),
        .rst_n(rst_n),
        .note_div(out_note_right),
        .audio_right(audio_right)
    );
    
    tone B(
        .clk(clk),
        .rst_n(rst_n),
        .dead(dead),
        .light(light),
        .out_note_left(out_note_left),
        .out_note_right(out_note_right)
    );
    
endmodule

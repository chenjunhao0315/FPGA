`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/05 01:53:42
// Design Name: 
// Module Name: speaker_control
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


module speaker_control(clk, rst_n, audio_left, audio_right, audio_mclk, audio_lrck, audio_sck, audio_sdin);
    input clk;
    input rst_n;
    input [15:0] audio_left;
    input [15:0] audio_right;
    output audio_mclk;
    output audio_lrck;
    output audio_sck;
    output reg audio_sdin;
 
    reg [31:0] data;
    reg [31:0] data_next;
    reg [8:0] clock, clock_next;

    always @ (posedge clk or negedge rst_n)
        if (~rst_n)
            clock <= 9'b0;
        else
            clock <= clock + 1'b1;

    assign audio_mclk = clock[1];
    assign audio_sck = clock[3];
    assign audio_lrck = clock[8];

    always @ *
        if (clock[8:4] == 5'b0)
            {audio_sdin, data_next} = {data[31], audio_left, audio_right};
        else
            {audio_sdin, data_next} = {data[31:0], 1'b0};
     
    always @ (posedge audio_sck or negedge rst_n)
        if (~rst_n)
            data <= 32'b0;
        else
            data <= data_next;
  
endmodule
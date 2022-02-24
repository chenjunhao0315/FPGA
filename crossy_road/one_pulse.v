`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 14:18:36
// Design Name: 
// Module Name: one_pulse
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


module one_pulse(clk, rst_n, pb_debounced, out_pulse);
    input clk;              // clock input
    input rst_n;            // active low reset
    input pb_debounced;     // input trigger
    output reg out_pulse;   // output one pulse

    reg button_delay;       // internal nodes
    reg out_pulse_next;     // input to DFF (in always block)

// Sequential logics : Buffer input
    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            button_delay <= 1'b0;
        else
            button_delay <= pb_debounced;
    end

// Pulse generation 
    assign output_pulse_next = pb_debounced & ~button_delay;

    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            out_pulse <= 1'b0;
        else
            out_pulse <= output_pulse_next;
    end
endmodule

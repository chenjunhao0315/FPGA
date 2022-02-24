`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/10 00:28:49
// Design Name: 
// Module Name: debounce_circuit
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


module debounce_circuit(clk, rst_n, pb_in, pb_debounced);
    input clk;      // clock input
    input rst_n;    // active low reset
    input pb_in;    // push button input
    output reg pb_debounced;    // output debounce signal
    
    reg [3:0] debounce_windows;     // shift register for flip flop
    reg next_push_button_debounced; // debounce result

// Sequential logics : Shifter register    
    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            debounce_windows <= 4'b0;
        else
            debounce_windows <= {debounce_windows[2:0], pb_in};
    end

// Debounce circuit
// Combinational logics : mux
    always @ *
    begin
        if (debounce_windows == 4'b1111)
            next_push_button_debounced = 1'b1;
        else
            next_push_button_debounced = 1'b0;
    end

// Sequential logics : Flip flop for debounced signal
    always @ (posedge clk or negedge rst_n)
        if (~rst_n)
            pb_debounced <= 1'b0;
        else
            pb_debounced <= next_push_button_debounced;
endmodule

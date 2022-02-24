`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 14:19:10
// Design Name: 
// Module Name: clock
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


module clock(clk, rst_n, clk_1, clk_100, clk_scan);
    input clk;              // global clock
    input rst_n;            // active low reset
    output [1:0] clk_scan;  // divided clock for scan control
    output clk_1;           // 1-Hz divided clock
    output clk_100;         // 100-Hz divided clock
    
    reg clk_1;              // 1-Hz counter DFF output (in always block)
    reg clk_100;            // 100-Hz counter DFF output (in always block)
    reg clk_1_next;         // input to divided clock 1-Hz buffer (in always block)
    reg clk_100_next;       // input to divided clock 100-Hz buffer (in always block)
    reg [25:0] cnt_1;           // temporary value for counting oscillation
    reg [25:0] cnt_1_next;      // input to counting 1Hz buffer (in always block)
    reg [18:0] cnt_100;         // temporary value for counting oscillation
    reg [18:0] cnt_100_next;    // input to counting 100Hz buffer (in always block)

// Continous assignment : clk_scan output
    assign clk_scan = cnt_1[16:15];

// Combinational logics : mux    
    always @ *
        if (cnt_1 == 26'd50000000)
        begin
            clk_1_next = ~clk_1;      // inverter
            cnt_1_next = 26'b0;       // initial value
        end
        else
        begin
            clk_1_next = clk_1;         // maintain
            cnt_1_next = cnt_1 + 1'b1;  // increment
        end  
        
// Sequential logics : Flip flops for counting the crystal oscillation and 1-Hz clock
    always @ (posedge clk or negedge rst_n)
        if (~rst_n)
            begin
            cnt_1 <= 26'b0;               // reset
            clk_1 <= 1'b0;
            end
        else
            begin
            cnt_1 <= cnt_1_next;
            clk_1 <= clk_1_next;
            end
            
// Combinational logics : mux    
    always @ *
        if (cnt_100 == 19'd500000)
            begin
            clk_100_next = ~clk_100;    // inverter
            cnt_100_next = 19'b0;       // initial value
            end
        else
            begin
            clk_100_next = clk_100;         // maintain
            cnt_100_next = cnt_100 + 1'b1;  // increment
            end  
                    
// Sequential logics : Flip flops for counting the crystal oscillation and 100-Hz clock
    always @ (posedge clk or negedge rst_n)
        if (~rst_n)
            begin
            cnt_100 <= 19'b0;               // reset
            clk_100 <= 1'b0;
            end
        else
            begin
            cnt_100 <= cnt_100_next;
            clk_100 <= clk_100_next;
            end
endmodule

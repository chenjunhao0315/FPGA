`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 14:12:54
// Design Name: 
// Module Name: vga_driver
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


`define DISPLAY_OUTPUT_1 1'b0
`define DISPLAY_OUTPUT_2 1'b1
`define READ 1'b0
`define WRITE 1'b1

module vga_driver (
    clk,            // system clock (100Mhz)
    rst_n,          // active low reset
    hs,             // vga horizontal sync.
    vs,             // vga vertical sync.
    red,            // vga red output
    green,          // vga green output
    blue,           // vga blue output
    frame_update,   // frame update
    valid,          // valid input signal
    I_x,            // input x position
    I_y,            // input y position
    I_colour        // input colour
);

    input clk;
    input rst_n;
    input [9:0] I_x;
    input [9:0] I_y;
    input [3:0] I_colour;
    input valid;
    output hs;
    output vs;
    output reg [3:0] red;
    output reg [3:0] green;
    output reg [3:0] blue;
    output frame_update;
    
    parameter C_V_VISIBLE_AREA = 480,
              C_V_FRONE_PROCH  = 10,
              C_V_SYNC_PULSE   = 2,
              C_V_BACK_PORCH   = 33,
              C_V_WHOLE_LINE   = 525;
              
    parameter C_H_VISIBLE_AREA = 640,
              C_H_FRONE_PORCH  = 16,
              C_H_SYNC_PULSE   = 96,
              C_H_BACK_PORCH   = 48,
              C_H_WHOLE_LINE   = 800;
              
    reg [9:0] cnt_h;
    reg [9:0] cnt_v;
    wire [9:0] O_x;
    wire [9:0] O_y;

    wire frame_update;

    reg clk_25M, clk_50M;

    reg rom_state;
    reg rom_state_next;

    reg [16:0] addr_output;
    reg [16:0] addr_input;

    reg [16:0] addr_display_1;
    reg [16:0] addr_display_2;

    reg data_control_display_1;
    reg data_control_display_2;

    reg [3:0] data_input_display_1;
    reg [3:0] data_input_display_2;

    wire [3:0] data_output_display_1;
    wire [3:0] data_output_display_2;

    reg [3:0] O_colour;

// RAM CONTROL
    memory_display_1 display_1(
        .clka(clk),
        .wea(data_control_display_1),
        .addra(addr_display_1),
        .dina(data_input_display_1),
        .douta(data_output_display_1)
    );

    memory_display_2 display_2(
        .clka(clk),
        .wea(data_control_display_2),
        .addra(addr_display_2),
        .dina(data_input_display_2),
        .douta(data_output_display_2)
    );

    always @ *
    begin
        addr_input = ((I_y) * (C_H_VISIBLE_AREA / 2) + (I_x)) % 76800;
        addr_output = ((O_y >> 1) * (C_H_VISIBLE_AREA / 2) + (O_x >> 1)) % 76800;
    end

    always @ *
    begin
        case (rom_state)
            `DISPLAY_OUTPUT_1 :     // output ram 1 input ram 2
            begin
                // ram control
                data_control_display_1 = `READ;
                if (valid)
                    data_control_display_2 = `WRITE;
                else
                    data_control_display_2 = `READ;
                // address control
                addr_display_1 = addr_output;
                addr_display_2 = addr_input;
                // ram input
                data_input_display_1 = 12'b0;
                if (valid)
                    data_input_display_2 = I_colour;
                else
                    data_input_display_2 = data_output_display_2;
                // vga output
                if (active)
                    O_colour = data_output_display_1;
                else
                    O_colour = 12'b0;
                // condition to switch input and output source
                if (frame_update == 1'b1)
                    rom_state_next = `DISPLAY_OUTPUT_2;
                else
                    rom_state_next = `DISPLAY_OUTPUT_1;
            end
            `DISPLAY_OUTPUT_2 :     // output ram 2 input ram 1
            begin
                // ram control
                data_control_display_2 = `READ;
                if (valid)
                    data_control_display_1 = `WRITE;
                else
                    data_control_display_1 = `READ;
                // address control
                addr_display_1 = addr_input;
                addr_display_2 = addr_output;
                // ram input
                if (valid)
                    data_input_display_1 = I_colour;
                else
                    data_input_display_1 = data_output_display_1;
                data_input_display_2 = 12'b0;
                // vga output
                if (active)
                    O_colour = data_output_display_2;
                else
                    O_colour = 4'b0;
                // condition to switch input and output source
                if (frame_update == 1'b1)
                    rom_state_next = `DISPLAY_OUTPUT_1;
                else
                    rom_state_next = `DISPLAY_OUTPUT_2;
            end
            default :
            begin
                data_control_display_1 = `READ;
                data_control_display_2 = `READ;
                addr_display_1 = 0;
                addr_display_2 = 0;
                data_input_display_1 = 12'b0;
                data_input_display_2 = 12'b0;
                O_colour = 4'b0;
                rom_state_next = `DISPLAY_OUTPUT_1;
            end
        endcase
    end

    always @ (posedge clk_25M or negedge rst_n)
        if (~rst_n)
            rom_state <= `DISPLAY_OUTPUT_1;
        else
            rom_state <= rom_state_next;
//

// THREE PRIMARY COLOR DECODER
    always @ *
    begin
        case (O_colour)
            4'd0 : begin {red, green, blue} = 12'h000; end
            4'd1 : begin {red, green, blue} = 12'hFFF; end
            4'd2 : begin {red, green, blue} = 12'h000; end
            4'd3 : begin {red, green, blue} = 12'hFEA; end
            4'd4 : begin {red, green, blue} = 12'hFF0; end
            4'd5 : begin {red, green, blue} = 12'h0AF; end
            4'd6 : begin {red, green, blue} = 12'h34C; end
            4'd7 : begin {red, green, blue} = 12'hCF0; end
            4'd8 : begin {red, green, blue} = 12'h0D4; end
            4'd9 : begin {red, green, blue} = 12'hB75; end
            4'd10 : begin {red, green, blue} = 12'h743; end
            4'd11 : begin {red, green, blue} = 12'hCCC; end
            4'd12 : begin {red, green, blue} = 12'h555; end
            4'd13 : begin {red, green, blue} = 12'hF00; end
            4'd14 : begin {red, green, blue} = 12'hF72; end
            4'd15 : begin {red, green, blue} = 12'habc; end
            default : begin {red, green, blue} = 12'h000; end
        endcase
    end
//

// clock
    always @ (posedge clk or negedge rst_n)
        if (~rst_n)
            {clk_25M, clk_50M} <= 2'b0;
        else
            {clk_25M, clk_50M} <= {clk_25M, clk_50M} + 1'b1;
//

//  horizontal
    always @ (posedge clk_25M or negedge rst_n)
        if (~rst_n)
            cnt_h <= 10'b0;
        else if (cnt_h == C_H_WHOLE_LINE - 1'b1)
            cnt_h <= 10'b0;
        else
            cnt_h <= cnt_h + 1'b1;
            
    assign hs = (cnt_h < C_H_SYNC_PULSE) ? 1'b0 : 1'b1;
 //
 
 // vertical
    always @ (posedge clk_25M or negedge rst_n)
        if (~rst_n)
            cnt_v <= 10'b0;
        else if (cnt_v == C_V_WHOLE_LINE - 1'b1)
            cnt_v <= 10'b0;
        else if (cnt_h == C_H_WHOLE_LINE - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else
            cnt_v <= cnt_v;
            
    assign vs = (cnt_v < C_V_SYNC_PULSE) ? 1'b0: 1'b1;
//

// active area
    assign active = (cnt_h >= C_H_SYNC_PULSE + C_H_BACK_PORCH) &&
                    (cnt_h < C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_VISIBLE_AREA) &&
                    (cnt_v >= C_V_SYNC_PULSE + C_V_BACK_PORCH) &&
                    (cnt_v < C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_VISIBLE_AREA);
//

// actually position                    
    assign O_x = (cnt_h >= C_H_SYNC_PULSE + C_H_BACK_PORCH && cnt_h < C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_VISIBLE_AREA) ? (cnt_h - C_H_SYNC_PULSE - C_H_BACK_PORCH) : 10'b0;
    assign O_y = (cnt_v >= C_V_SYNC_PULSE + C_V_BACK_PORCH && cnt_v < C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_VISIBLE_AREA) ? (cnt_v - C_V_SYNC_PULSE - C_V_BACK_PORCH) : 10'b0;
//    

    assign frame_update = cnt_v == C_V_WHOLE_LINE - 1'b1;
endmodule


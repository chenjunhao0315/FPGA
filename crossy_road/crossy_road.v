`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 14:17:36
// Design Name: 
// Module Name: crossy_road
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


module corssy_road(clk, rst_n, dip, hs, vs, red, green, blue, led, bp, audio_mclk, audio_lrck, audio_sck, audio_sdin, ssd, ssd_ctl, PS2_CLK, PS2_DATA);
	input clk;
	input rst_n;
	input [14:0] dip;
	input [4:0] bp;
	output hs;
	output vs;
	output [3:0] red;
	output [3:0] green;
	output [3:0] blue;
	output [15:0] led;
	output audio_mclk;
	output audio_lrck;
	output audio_sck;
	output audio_sdin;
	output [7:0] ssd;
	output [3:0] ssd_ctl;
	inout PS2_CLK;
	inout PS2_DATA;

	wire frame_update;
	wire valid;
	wire [9:0] I_x, I_y;
	wire [3:0] I_colour;
	
	wire [29:0] data_0;
	wire [29:0] data_1;
	wire [29:0] data_2;
	wire [29:0] data_3;
	wire [29:0] data_4;
	wire [29:0] data_5;
	wire [29:0] data_6;
	wire [29:0] chicken;
	
	reg [29:0] test;
	
	wire [9:0] position_y_background;
	
	wire O_render_ready;
	
	wire [2:0] move;
	
	wire [2:0] game_state;
	
	wire level_crossing_light;

	wire clk_1, clk_100;
	wire [1:0] clk_scan;

	wire [9:0] score;
	wire [9:0] coin, coin_store;
	
	wire character;

	parameter GRASS = 2'b00, ROAD = 2'b01, RIVER = 2'b10, RAIL = 2'b11;
	parameter EMPTY = 2'b00, TREE = 2'b01, ROCK = 2'b10, COIN = 2'b11;
    parameter CAR_1 = 2'b00, CAR_2 = 2'b01, CAR_3 = 2'b10, CAR_4 = 2'b11;
    parameter WATER_1 = 2'b00, WATER_2 = 2'b01, WATER_3 = 2'b10, WATER_4 = 2'b11;
    parameter TRAIN = 2'b00;
    
    input_control input_controller (
        .clk(clk), 
        .clk_100(clk_100), 
        .rst_n(rst_n), 
        .bp(bp), 
        .move(move), 
        .PS2_CLK(PS2_CLK), 
        .PS2_DATA(PS2_DATA),
        .character(character),
        .coin_store(coin_store),
        .input_mode(led[15])
    );

	data_control data_controller (
        .clk(clk),
        .rst_n(rst_n),
        .power(dip[14]),
        .frame_update(frame_update),
        .I_move(move),
        .data_0(data_0),
        .data_1(data_1),
        .data_2(data_2),
        .data_3(data_3),
        .data_4(data_4),
        .data_5(data_5),
        .data_6(data_6),
        .chicken(chicken),
        .position_y_background(position_y_background),
        .render_ready(O_render_ready),
        .level_crossing_light(level_crossing_light),
        .counter_score(score),
        .counter_coin(coin),
        .game_state(game_state)
    );

	render render(
	    .clk(clk),    // Clock
	    .rst_n(rst_n),  // Asynchronous reset active low
	    .frame_update(frame_update),
	    .I_character(character),
	    .I_position_y_background(position_y_background),
	    .I_chicken(chicken),
	    .I_data_0(data_0),
	    .I_data_1(data_1),
	    .I_data_2(data_2),
	    .I_data_3(data_3),
	    .I_data_4(data_4),
	    .I_data_5(data_5),
	    .I_data_6(data_6),
	    .O_x(I_x),
	    .O_y(I_y),
	    .O_colour(I_colour),
	    .O_valid(valid),
	    .O_render_ready(O_render_ready),
	    .game_state(game_state)
	);

	vga_driver vga_driver (
	    .clk(clk),            // system clock (100Mhz)
	    .rst_n(rst_n),          // active low reset
	    .hs(hs),             // vga horizontal sync.
	    .vs(vs),             // vga vertical sync.
	    .red(red),            // vga red output
	    .green(green),          // vga green output
	    .blue(blue),           // vga blue output
	    .frame_update(frame_update),   // frame update
	    .valid(valid),          // valid input signal
	    .I_x(I_x),            // input x position
	    .I_y(I_y),            // input y position
	    .I_colour(I_colour)        // input colour
	);
	
	clock frequency_divier(
	   .clk(clk), 
	   .rst_n(rst_n), 
	   .clk_100(clk_100),
	   .clk_1(clk_1),
	   .clk_scan(clk_scan)
    );
    
    sound sound_control(
        .clk(clk), 
        .rst_n(rst_n), 
        .audio_mclk(audio_mclk), 
        .audio_lrck(audio_lrck), 
        .audio_sck(audio_sck), 
        .audio_sdin(audio_sdin), 
        .dead(game_state == 3'd2), 
        .light(level_crossing_light)
    );

    ssd_control ssd_controller (
    	.clk(clk),
		.clk_1(clk_1),
		.clk_scan(clk_scan),
		.rst_n(rst_n),
		.game_state(game_state),
		.score(score),
		.coin(coin),
		.ssd(ssd),
		.ssd_ctl(ssd_ctl),
		.led(led[14:0]),
		.coin_store(coin_store),
		.character(character)
 	);
endmodule

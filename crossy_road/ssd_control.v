`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 21:49:25
// Design Name: 
// Module Name: ssd_control
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


module ssd_control(
	clk,
	clk_1,
	clk_scan,
	rst_n,
	game_state,
	character,
	score,
	coin,
	ssd,
	ssd_ctl,
	led,
	coin_store
 );
	
	input clk;
	input clk_1;
	input [1:0] clk_scan;
	input rst_n;
	input [2:0] game_state;
	input character;
	input [9:0] score;
	input [9:0] coin;
	output [7:0] ssd;
	output [3:0] ssd_ctl;
	output reg [14:0] led;
	output [9:0] coin_store;

	reg [9:0] highest_score;

	reg [5:0] state_recognizer;

	integer i;
	reg [9:0] number;
	reg [3:0] digit_1, digit_2, digit_3, digit_4;

	reg [2:0] show_state, show_state_next;

	reg [3:0] ssd_1, ssd_2, ssd_3, ssd_4;

	wire [3:0] ssd_in;

	reg [9:0] coin_store;

	parameter MAIN_STATE = 3'd0, PLAYING_STATE = 3'd1, DEAD_STATE = 3'd2;

	parameter STATE_PLAY = 3'd0, STATE_DEAD = 3'd1, STATE_SCORE_PLAY = 3'd2, STATE_MAIN = 3'd3, STATE_SCORE_DEAD = 3'd4;

	always @ * begin
		case (show_state)
			STATE_MAIN : begin
				ssd_1 = digit_1;
				ssd_2 = digit_2;
				ssd_3 = digit_3;
				ssd_4 = digit_4;
				if (game_state == PLAYING_STATE) begin
					show_state_next = STATE_PLAY;
				end
				else if (game_state == DEAD_STATE) begin
					show_state_next = STATE_DEAD;
				end
				else if (game_state == MAIN_STATE) begin
					show_state_next = STATE_MAIN;
				end
				else begin
					show_state_next = STATE_MAIN;
				end
			end
			STATE_SCORE_PLAY : begin
				ssd_1 = digit_1;
				ssd_2 = digit_2;
				ssd_3 = digit_3;
				ssd_4 = digit_4;
				if (game_state == PLAYING_STATE) begin
					show_state_next = STATE_SCORE_PLAY;
				end
				else if (game_state == DEAD_STATE) begin
					show_state_next = STATE_DEAD;
				end
				else if (game_state == MAIN_STATE) begin
					show_state_next = STATE_MAIN;
				end
				else begin
					show_state_next = STATE_SCORE_PLAY;
				end
			end
			STATE_PLAY : begin
				ssd_1 = 4'hD;		// Y
				ssd_2 = 4'hC;		// A
				ssd_3 = 4'hB;		// L
				ssd_4 = 4'hA;		// P
				if (game_state == PLAYING_STATE) begin
					show_state_next = STATE_SCORE_PLAY;
				end
				else if (game_state == DEAD_STATE) begin
					show_state_next = STATE_DEAD;
				end
				else if (game_state == MAIN_STATE) begin
					show_state_next = STATE_MAIN;
				end
				else begin
					show_state_next = STATE_PLAY;
				end
			end
			STATE_DEAD : begin
				ssd_1 = 4'hE;		// D
				ssd_2 = 4'hC;		// A
				ssd_3 = 4'hF;		// E
				ssd_4 = 4'hE;		// D
				if (game_state == PLAYING_STATE) begin
					show_state_next = STATE_PLAY;
				end
				else if (game_state == DEAD_STATE) begin
					show_state_next = STATE_SCORE_DEAD;
				end
				else if (game_state == MAIN_STATE) begin
					show_state_next = STATE_MAIN;
				end
				else begin
					show_state_next = STATE_DEAD;
				end
			end
			STATE_SCORE_DEAD : begin
				ssd_1 = digit_1;
				ssd_2 = digit_2;
				ssd_3 = digit_3;
				ssd_4 = digit_4;
				if (game_state == PLAYING_STATE) begin
					show_state_next = STATE_PLAY;
				end
				else if (game_state == DEAD_STATE) begin
					show_state_next = STATE_SCORE_DEAD;
				end
				else if (game_state == MAIN_STATE) begin
					show_state_next = STATE_MAIN;
				end
				else begin
					show_state_next = STATE_SCORE_DEAD;
				end
			end
			default : begin
				ssd_1 = 4'd0;
				ssd_2 = 4'd0;
				ssd_3 = 4'd0;
				ssd_4 = 4'd0;
				show_state_next = STATE_MAIN;
			end
		endcase
	end

	always @(posedge clk_1 or negedge rst_n) begin : proc_show_state
		if(~rst_n) begin
			show_state <= STATE_MAIN;
		end else begin
			show_state <= show_state_next;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			state_recognizer <= 6'b0;
		end else begin
			state_recognizer <= {state_recognizer[2:0], game_state};
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			coin_store <= 0;
		end 
		else if (state_recognizer[5:3] == MAIN_STATE && state_recognizer[2:0] == PLAYING_STATE && character == 1'b1) begin
			coin_store <= coin_store - 10'd3;
		end
		else if (state_recognizer[5:3] == PLAYING_STATE && state_recognizer[2:0] == DEAD_STATE) begin
			coin_store <= coin_store + coin;
		end
		else begin
			coin_store <= coin_store;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			highest_score <= 10'd0;
		end 
		else if (score > highest_score) begin
			highest_score <= score;
		end
		else begin
			highest_score <= highest_score;
		end
	end

	always @ * begin
		case (game_state)
			MAIN_STATE : begin
				number = highest_score;
			end
			PLAYING_STATE : begin
				number = score;
			end
			DEAD_STATE : begin
				number = score;
			end
			default : begin
				number = 10'd0;
			end
		endcase
	end

	always @ * begin
		if (coin_store > 10'd3 && coin_store <= 10'd6) begin
			led = 15'b000000000000001;
		end
		else if (coin_store > 10'd6 && coin_store <= 10'd9) begin
			led = 15'b000000000000011;
		end
		else if (coin_store > 10'd9 && coin_store <= 10'd12) begin
			led = 15'b000000000000111;
		end
		else if (coin_store > 10'd12 && coin_store <= 10'd15) begin
			led = 15'b000000000001111;
		end
		else if (coin_store > 10'd15 && coin_store <= 10'd18) begin
			led = 15'b000000000011111;
		end
		else if (coin_store > 10'd18 && coin_store <= 10'd21) begin
			led = 15'b000000000111111;
		end
		else if (coin_store > 10'd21 && coin_store <= 10'd24) begin
			led = 15'b000000001111111;
		end
		else if (coin_store > 10'd24 && coin_store <= 10'd27) begin
			led = 15'b000000011111111;
		end
		else if (coin_store > 10'd27 && coin_store <= 10'd30) begin
			led = 15'b000000111111111;
		end
		else if (coin_store > 10'd30 && coin_store <= 10'd33) begin
			led = 15'b000001111111111;
		end
		else if (coin_store > 10'd33 && coin_store <= 10'd36) begin
			led = 15'b000011111111111;
		end
		else if (coin_store > 10'd36 && coin_store <= 10'd39) begin
			led = 15'b000111111111111;
		end
		else if (coin_store > 10'd39 && coin_store <= 10'd42) begin
			led = 15'b001111111111111;
		end
		else if (coin_store > 10'd42 && coin_store <= 10'd45) begin
			led = 15'b011111111111111;
		end
		else if (coin_store > 10'd45 && coin_store <= 10'd48) begin
			led = 15'b111111111111111;
		end
		else if (coin_store > 10'd48 && coin_store <= 10'd51) begin
			led = 15'b111111111111111;
		end
		else if (coin_store > 10'd51) begin
			led = 15'b111111111111111;
		end
		else begin
			led = 15'b000000000000000;
		end
	end

	always @ * begin
		digit_1 = 4'd0;
		digit_2 = 4'd0;
		digit_3 = 4'd0;
		digit_4 = 4'd0;
		for (i = 9; i >= 0; i = i - 1) begin
			if (digit_4 >= 4'd5) begin
				digit_4 = digit_4 + 4'd3;
			end
			else begin
				digit_4 = digit_4;
			end
			if (digit_3 >= 4'd5) begin
				digit_3 = digit_3 + 4'd3;
			end
			else begin
				digit_3 = digit_3;
			end
			if (digit_2 >= 4'd5) begin
				digit_2 = digit_2 + 4'd3;
			end
			else begin
				digit_2 = digit_2;
			end
			if (digit_1 >= 4'd5) begin
				digit_1 = digit_1 + 4'd3;
			end
			else begin
				digit_1 = digit_1;
			end
			digit_4 = digit_4 << 1;
			digit_4[0] = digit_3[3];
			digit_3 = digit_3 << 1;
			digit_3[0] = digit_2[3];
			digit_2 = digit_2 << 1;
			digit_2[0] = digit_1[3];
			digit_1 = digit_1 << 1;
			digit_1[0] = number[i];
		end
	end

	// Scan controller    
	scan_ctl scan_control(
	    .clk_scan(clk_scan),        // divided clock for scan control
	    .ssd_ctl(ssd_ctl),          // seven segment display control
	    .ssd_output(ssd_in),        // signal input to seven segment display decoder
	    .in_4(ssd_4),             // result 4 input
	    .in_3(ssd_3),             // result 3 input
	    .in_2(ssd_2),             // result 2 input
	    .in_1(ssd_1)              // result 1 input
	);

	// Seven segment display decoder    
    display ssd_decoder(
        .in(ssd_in),                // signal input to seven segment display decoder
        .ssd(ssd)                   // seven segment display output
    );	
endmodule

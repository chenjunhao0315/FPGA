`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 14:12:29
// Design Name: 
// Module Name: data_control
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


module data_control (
	clk,
	clk_100,
	power,
	frame_update,
	render_ready,
	rst_n,
	I_move,
	data_0,
	data_1,
	data_2,
	data_3,
	data_4,
	data_5,
	data_6,
	chicken,
	position_y_background,
	level_crossing_light,
	background_state,
	data_control_state,
	new_data,
	chicken_state,
	data_transfer_finish,
	game_state,
	counter_score,
  counter_coin
);

	input clk;
  	input clk_100;
  	input power;
  	input frame_update;
  	input render_ready;
  	input rst_n;
  	input [2:0] I_move;
  	output [29:0] data_0;
  	output [29:0] data_1;
  	output [29:0] data_2;
  	output [29:0] data_3;
  	output [29:0] data_4;
  	output [29:0] data_5;
  	output [29:0] data_6;
  	output [29:0] chicken;
  	output [9:0] position_y_background;
  	output level_crossing_light;
  	output [3:0] background_state;
  	output [5:0] data_control_state;
  	output [29:0] new_data;
  	output data_transfer_finish;
  	output chicken_state;
  	output [2:0] game_state;
  	output [9:0] counter_score;
    output [9:0] counter_coin;

  	wire [29:0] new_data;
  	reg [29:0] data_0, data_0_next;
  	reg [29:0] data_1, data_1_next;
  	reg [29:0] data_2, data_2_next;
  	reg [29:0] data_3, data_3_next;
  	reg [29:0] data_4, data_4_next;
  	reg [29:0] data_5, data_5_next;
  	reg [29:0] data_6, data_6_next;
  	reg [9:0] position_y_background, position_y_background_next;

  	wire data_valid;
  	wire [19:0] random;

  	parameter VALID = 1'b1, INVALID = 1'b0;

  	parameter GRASS = 2'b00, ROAD = 2'b01, RIVER = 2'b10, RAIL = 2'b11;
  	parameter EMPTY = 2'b00, TREE = 2'b01, ROCK = 2'b10, COIN = 2'b11;
    parameter CAR_1 = 2'b00, CAR_2 = 2'b01, CAR_3 = 2'b10, CAR_4 = 2'b11;
    parameter WATER_1 = 2'b00, WATER_2 = 2'b01, WATER_3 = 2'b10, WATER_4 = 2'b11;
    parameter TRAIN = 2'b00;
    parameter MARGIN = 10'd4;
    parameter LEFT_MARGIN = 10'd10, RIGHT_MARGIN = 10'd10, DOWN_MARGIN = 10'd20, TOP_MARGIN = 10'd20;

    reg [9:0] counter_score, counter_score_next;
    reg [9:0] counter_score_temp, counter_score_temp_next;

    reg level_crossing_light_tmp;

    // var for background
// 	  parameter BACKGROUND_CONTROL_IDLE = 2'b00;
    reg [2:0] background_control;
    reg [3:0] background_state, background_state_next;
    reg [5:0] counter_idle, counter_idle_next;
    reg data_transfer, data_transfer_finish;
    reg [9:0] background_chase, background_chase_next;
    reg [5:0] chase_speed, idle_time;
//    parameter BACKGROUND_WAIT = 3'd0, BACKGROUND_CONTROL = 3'd1, DATA_TRANSFER = 3'd2, BACKGROUND_IDLE = 3'd3;
    // end of var for background

    // var for data control
    reg power_on_reset, power_on_reset_next;
    parameter RIGHT = 1'b0, LEFT = 1'b1;
    parameter SPEED_0 = 3'd0, SPEED_1 = 3'd1, SPEED_2 = 3'd2, SPEED_3 = 3'd3, SPEED_4 = 3'd4, SPEED_5 = 3'd5,
              SPEED_6 = 3'd6, SPEED_7 = 3'd7;
    parameter DATA_IDLE = 3'd0;
    wire [2:0] data_control = DATA_IDLE;
    reg [29:0] data, data_next;
    reg [5:0] data_control_state, data_control_state_next;
    reg [2:0] game_state, game_state_next;
    reg [9:0] counter_coin, counter_coin_next;
    reg [5:0] barrier_code;
    reg [9:0] barrier_width_1, barrier_width_2;
    parameter DATA_WAIT = 6'd0, DATA_CONTROL = 6'd1, DATA_TRANSFER = 6'd2, BACKGROUND_IDLE = 6'd3, DATA_RESET = 6'd4,
              DATA_0 = 6'd5, DATA_1 = 6'd6, DATA_2 = 6'd7, DATA_3 = 6'd8, DATA_4 = 6'd9, DATA_5 = 6'd10, DATA_6 = 6'd11,
              DATA_RESET_0 = 6'd12, DATA_RESET_1 = 6'd13, DATA_RESET_2 = 6'd14, DATA_RESET_3 = 6'd15, DATA_RESET_4 = 6'd16,
              DATA_RESET_5 = 6'd17, DATA_RESET_6 = 6'd18, CHICKEN_IDLE = 6'd19, CHICKEN_JUMP = 6'd20, DEAD_JUDGE = 6'd21,
              DATA_MAIN = 6'd22, DATA_SETTLEMENT = 6'd23, CHICKEN_CASE = 6'd24, DATA_CORRECTION = 6'd25;
    parameter MAIN_STATE = 3'd0, PLAYING_STATE = 3'd1, DEAD_STATE = 3'd2;
    // end of var for data control

    // var for chicken control
    reg [29:0] chicken, chicken_next;
    wire chicken_state;
 //   parameter CHICKEN_WAIT = 6'd0, CHICKEN_CONTROL = 6'd1, CHICKEN_IDLE = 6'd2, CHICKEN_TRANSFER = 6'd3,
 //           CHICKEN_JUMP = 6'd4, CHICKEN_JUMP_UP = 6'd5, CHICKEN_JUMP_DOWN = 6'd6, CHICKEN_JUMP_LEFT = 6'd7,
 //           CHICKEN_JUMP_RIGHT = 6'd8, CHICKEN_STATE_JUDGE = 6'd9;
    parameter JUMP_UP = 2'b00, JUMP_DOWN = 2'b01, JUMP_LEFT = 2'b10, JUMP_RIGHT = 2'b11;
    parameter DEAD = 1'b0, LIVE = 1'b1;
    wire jump_up_valid, jump_down_valid, jump_left_valid, jump_right_valid;
    reg [2:0] move, move_next, move_tmp;
    // end of var for chicken control

    // var for 1 sec
    reg clock_1s_state, clock_1s_state_next;
    reg [27:0] clock_1s, clock_1s_next;
    reg [27:0] clock_half_s;
    reg clock_half_o;
    parameter COUNTING = 1'b0, OUTPUT_1S_CLOCK = 1'b1;
    // end of var for 1 sec

    // input move process
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            move_tmp <= 3'b0;
        end
        else if (power) begin
            if (data_control_state == CHICKEN_JUMP) begin
                move_tmp <= 3'b0;
            end
            else if (move_tmp[2] == VALID && game_state == MAIN_STATE) begin
             	move_tmp <= 3'b0;
            end
            else if (I_move[2] == 1'b1 && game_state == DEAD_STATE) begin
                move_tmp <= I_move;
            end
            else if (I_move[2] == 1'b1 && move_next == 3'b0) begin
                move_tmp <= I_move;
            end
            else begin
                move_tmp <= move_tmp;
            end
        end
        else begin
            move_tmp <= 3'b0;
        end
    end

    always @ *
	    begin
	        if (data_control_state == CHICKEN_JUMP) begin
	            move_next = move_tmp;
	        end
	        else begin
	            move_next = move;
	        end
	    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            move <= 3'b0;
        end else begin
            move <= move_next;
        end
    end
    // end of input move process

    // 1 sec clock
    always @ *
	    begin
	      	case (clock_1s_state)
	        COUNTING : begin
	          	if (clock_1s == 27'd10000) begin
	            	clock_1s_next = 27'd0;
	            	clock_1s_state_next = OUTPUT_1S_CLOCK;
	          	end
	          	else begin
	            	clock_1s_next = clock_1s + 27'd1;
	            	clock_1s_state_next = COUNTING;
	          	end
	        end
	        OUTPUT_1S_CLOCK : begin
	            clock_1s_next = 27'd0;
	            if (data_control_state == DATA_WAIT)
	              	clock_1s_state_next = COUNTING;
	            else
	              	clock_1s_state_next = OUTPUT_1S_CLOCK;
	        end
	        default : begin
	            clock_1s_next = 27'd0;
	            clock_1s_state_next = COUNTING;
	        end
	      	endcase
	    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
          	clock_1s <= 27'd0;
          	clock_1s_state = COUNTING;
        end
        else begin
          	clock_1s <= clock_1s_next;
          	clock_1s_state <= clock_1s_state_next;
        end
    end

    always @ (posedge clk or negedge rst_n) begin
    	if(~rst_n) begin
    		clock_half_s <= 27'd0;
    		clock_half_o <= 1'd0;
    	end 
    	else if (clock_half_s == 27'd25000000) begin
    		clock_half_s <= 27'd0;
    		clock_half_o <= ~clock_half_o;
    	end
    	else begin
    		clock_half_s <= clock_half_s + 1'd1;
    		clock_half_o <= clock_half_o;
    	end
    end
    // end of 1 sec clock

    // level crossing light
    always @ * begin
      if (data_1[29:28] == RAIL && data_1[1] == VALID && data_1[2] == INVALID) begin
    		level_crossing_light_tmp = VALID;
    	end
    	else if (data_2[29:28] == RAIL && data_2[1] == VALID && data_2[2] == INVALID) begin
    		level_crossing_light_tmp = VALID;
    	end
    	else if (data_3[29:28] == RAIL && data_3[1] == VALID && data_3[2] == INVALID) begin
    		level_crossing_light_tmp = VALID;
    	end
    	else if (data_4[29:28] == RAIL && data_4[1] == VALID && data_4[2] == INVALID) begin
    		level_crossing_light_tmp = VALID;
    	end
    	else if (data_5[29:28] == RAIL && data_5[1] == VALID && data_5[2] == INVALID) begin
    		level_crossing_light_tmp = VALID;
    	end
    	else if (data_6[29:28] == RAIL && data_6[1] == VALID && data_6[2] == INVALID) begin
    		level_crossing_light_tmp = VALID;
    	end
    	else begin
    		level_crossing_light_tmp = INVALID;
    	end
    end

    assign level_crossing_light = level_crossing_light_tmp;

    // end of level crossing light

    // FSM for data control
  	always @ * begin
     	case (data_control_state)
	     	DATA_WAIT : begin
	         	// retain
	         	data_transfer_finish = INVALID;
	         	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	         	// end of retain

	         	if (render_ready) begin
	             	data_control_state_next = DATA_CONTROL;
	         	end
	         	else begin
	             	data_control_state_next = DATA_WAIT;
	         	end
	     	end
	     	DATA_CONTROL : begin
	         	// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	           	counter_coin_next = counter_coin;
	         	// end of retain
	         
	         	if (power) begin
	            	if (power_on_reset == 1'b0) begin
	                	data_control_state_next = DATA_RESET;
	                	game_state_next = game_state;
	            	end
	            	else begin
		                if (game_state == MAIN_STATE) begin
		                    data_control_state_next = DATA_0;
		                    if (move_tmp[2] == VALID) begin
		                        game_state_next = PLAYING_STATE;
		                    end
		                    else begin
		                        game_state_next = MAIN_STATE;
		                    end
		                end
		                else if (game_state == PLAYING_STATE)begin
		                    data_control_state_next = BACKGROUND_IDLE;
		                    game_state_next = game_state;
		                end
		                else if (game_state == DEAD_STATE) begin
		                    
		                    if (move_tmp[2] == VALID) begin
		                        game_state_next = MAIN_STATE;
		                        data_control_state_next = DATA_RESET;
		                    end
		                    else begin
		                        game_state_next = game_state;
		                        data_control_state_next = DATA_0;
		                    end
		                end
		                else begin
		                    data_control_state_next = BACKGROUND_IDLE;
		                    game_state_next = game_state;
		                end
		            end
	        	end
	         	else begin
		            data_control_state_next = DATA_CONTROL;
		            game_state_next = game_state;
	         	end
	     	end
	     	BACKGROUND_IDLE : begin
                // retain
                data_transfer_finish = INVALID;
                data_0_next = data_0;
                data_1_next = data_1;
                data_2_next = data_2;
                data_3_next = data_3;
                data_4_next = data_4;
                data_5_next = data_5;
                data_6_next = data_6;
                data = 30'b0;
                power_on_reset_next = power_on_reset;
                chicken_next[29:18] = chicken[29:18];
                chicken_next[7:5] = chicken[7:5];
                chicken_next[1:0] = chicken[1:0];
                game_state_next = game_state;
                counter_coin_next = counter_coin;
                counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
                // end of retain
             
                if (counter_idle >= idle_time) begin
                	counter_idle_next = 6'd0;
                	if (background_chase > 10'd0) begin
                		background_chase_next = background_chase - chase_speed - 10'd1;
                	end
                	else begin
                		background_chase_next = 10'd0;
                	end

                	if (chicken[17:8] + (chase_speed + 10'd1) > 10'd239) begin
                		chicken_next[17:8] = chicken[17:8] + chase_speed - 10'd240;
                	end
                	else begin
                		chicken_next[17:8] = chicken[17:8] + chase_speed + 10'd1;
               		end

                	if (position_y_background + (chase_speed + 10'd1) > 10'd39) begin
                		data_control_state_next = DATA_TRANSFER;
                		position_y_background_next = (position_y_background + chase_speed - 10'd39);
                		
                		if (chicken[4:2] == 3'd6) begin
                			chicken_next[4:2] = 3'd1;
                		end
                		else begin
                			chicken_next[4:2] = chicken[4:2] + 3'd1;
                		end
                	end
                	else begin
                		data_control_state_next = CHICKEN_JUMP;
                		position_y_background_next = position_y_background + chase_speed + 10'd1;

                		chicken_next[4:2] = chicken[4:2];
                	end
                end
                else begin
                	counter_idle_next = counter_idle + 6'd1;
                	background_chase_next = background_chase;
                	position_y_background_next = position_y_background;
                	data_control_state_next = CHICKEN_JUMP;
                	chicken_next[17:8] = chicken[17:8];
                	chicken_next[4:2] = chicken[4:2];
                end
            end
	     	DEAD_JUDGE : begin
	      		// retain
	         	data_transfer_finish = INVALID;
	         	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	         	// end of retain

	         	if (chicken_state == LIVE) begin
	            	data_control_state_next = DATA_0;
	            	game_state_next = game_state;
	         	end
	         	else if (chicken_state == DEAD) begin
		            data_control_state_next = DATA_WAIT;
		            game_state_next = DEAD_STATE;
	         	end
	         	else begin
		            data_control_state_next = DATA_0;
		            game_state_next = game_state;
	         	end
	     	end
	     	CHICKEN_CASE : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	         	data_0_next = data_0;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	         	// end of retain

	         	data_control_state_next = DEAD_JUDGE;

	         	case (chicken[4:2])
	            	3'd1 : begin
		              	data_2_next = data_2;
		              	data_3_next = data_3;
		              	data_4_next = data_4;
		              	data_5_next = data_5;
		              	data_6_next = data_6;
	              		if (data_1[29:28] == GRASS) begin
	                		if ({data_1[19 - 2 * chicken[7:5]], data_1[19 - 2 * chicken[7:5] - 1]} == COIN) begin
	                			counter_coin_next = counter_coin + 10'd1;
	                    		case (chicken[7:5])
	                      			3'd0 : begin
	                        			data_1_next[29:20] = data_1[29:20];
				                        data_1_next[19:18] = EMPTY;
				                        data_1_next[17:0] = data_1[17:0];
	                      			end
	                      			3'd1 : begin
				                        data_1_next[29:18] = data_1[29:18];
				                        data_1_next[17:16] = EMPTY;
				                        data_1_next[15:0] = data_1[15:0];
	                      			end
	                      			3'd2 : begin
				                        data_1_next[29:16] = data_1[29:16];
				                        data_1_next[15:14] = EMPTY;
				                        data_1_next[13:0] = data_1[13:0];
	                      			end
	                      			3'd3 : begin
				                        data_1_next[29:14] = data_1[29:14];
				                        data_1_next[13:12] = EMPTY;
				                        data_1_next[11:0] = data_1[11:0];
	                      			end
	                      			3'd4 : begin
				                        data_1_next[29:12] = data_1[29:12];
				                        data_1_next[11:10] = EMPTY;
				                        data_1_next[9:0] = data_1[9:0];
	                      			end
	                      			3'd5 : begin
				                        data_1_next[29:10] = data_1[29:10];
				                        data_1_next[9:8] = EMPTY;
				                        data_1_next[7:0] = data_1[7:0];
	                      			end
	                      			3'd6 : begin
				                        data_1_next[29:8] = data_1[29:8];
				                        data_1_next[7:6] = EMPTY;
				                        data_1_next[5:0] = data_1[5:0];
	                      			end
	                      			3'd7 : begin
				                        data_1_next[29:6] = data_1[29:6];
				                        data_1_next[5:4] = EMPTY;
				                        data_1_next[3:0] = data_1[3:0];
	                      			end
	                      			default : begin
	                        			data_1_next = data_1;
	                      			end
	                    		endcase
	                		end
	                		else begin
	                			counter_coin_next = counter_coin;
	                  			data_1_next = data_1;
	                		end
	              		end
	              		else begin
	              			counter_coin_next = counter_coin;
	                		data_1_next = data_1;
	              		end
	            	end
	            	3'd2 : begin
		              	data_1_next = data_1;
		              	data_3_next = data_3;
		              	data_4_next = data_4;
		              	data_5_next = data_5;
		              	data_6_next = data_6;
			            if (data_2[29:28] == GRASS) begin
			                if ({data_2[19 - 2 * chicken[7:5]], data_2[19 - 2 * chicken[7:5] - 1]} == COIN) begin
			                	counter_coin_next = counter_coin + 10'd1;
	                    		case (chicken[7:5])
	                      			3'd0 : begin
				                    	data_2_next[29:20] = data_2[29:20];
				                        data_2_next[19:18] = EMPTY;
				                        data_2_next[17:0] = data_2[17:0];
				                    end
				                    3'd1 : begin
				                        data_2_next[29:18] = data_2[29:18];
				                        data_2_next[17:16] = EMPTY;
				                        data_2_next[15:0] = data_2[15:0];
	                      			end
	                      			3'd2 : begin
				                        data_2_next[29:16] = data_2[29:16];
				                        data_2_next[15:14] = EMPTY;
				                        data_2_next[13:0] = data_2[13:0];
	                      			end
	                      			3'd3 : begin
				                        data_2_next[29:14] = data_2[29:14];
				                        data_2_next[13:12] = EMPTY;
				                        data_2_next[11:0] = data_2[11:0];
	                      			end
	                      			3'd4 : begin
				                        data_2_next[29:12] = data_2[29:12];
				                        data_2_next[11:10] = EMPTY;
				                        data_2_next[9:0] = data_2[9:0];
	                      			end
	                      			3'd5 : begin
				                        data_2_next[29:10] = data_2[29:10];
				                        data_2_next[9:8] = EMPTY;
				                        data_2_next[7:0] = data_2[7:0];
	                      			end
	                      			3'd6 : begin
				                        data_2_next[29:8] = data_2[29:8];
				                        data_2_next[7:6] = EMPTY;
				                        data_2_next[5:0] = data_2[5:0];
	                      			end
	                      			3'd7 : begin
				                        data_2_next[29:6] = data_2[29:6];
				                        data_2_next[5:4] = EMPTY;
				                        data_2_next[3:0] = data_2[3:0];
	                      			end
	                      			default : begin
	                        			data_2_next = data_2;
	                      			end
	                    		endcase
	                		end
	                		else begin
	                  			data_2_next = data_2;
	                  			counter_coin_next = counter_coin;
	                		end
	              		end
	              		else begin
	                		data_2_next = data_2;
	                		counter_coin_next = counter_coin;
	              		end
	            	end
	            	3'd3 : begin
		              	data_1_next = data_1;
		              	data_2_next = data_2;
		              	data_4_next = data_4;
		              	data_5_next = data_5;
		              	data_6_next = data_6;
	              		if (data_3[29:28] == GRASS) begin
	                		if ({data_3[19 - 2 * chicken[7:5]], data_3[19 - 2 * chicken[7:5] - 1]} == COIN) begin
	                			counter_coin_next = counter_coin + 10'd1;
	                    		case (chicken[7:5])
		                      		3'd0 : begin
				                        data_3_next[29:20] = data_3[29:20];
				                        data_3_next[19:18] = EMPTY;
				                        data_3_next[17:0] = data_3[17:0];
		                      		end
		                      		3'd1 : begin
				                        data_3_next[29:18] = data_3[29:18];
				                        data_3_next[17:16] = EMPTY;
				                        data_3_next[15:0] = data_3[15:0];
		                      		end
		                      		3'd2 : begin
				                        data_3_next[29:16] = data_3[29:16];
				                        data_3_next[15:14] = EMPTY;
				                        data_3_next[13:0] = data_3[13:0];
		                      		end
		                      		3'd3 : begin
				                        data_3_next[29:14] = data_3[29:14];
				                        data_3_next[13:12] = EMPTY;
				                        data_3_next[11:0] = data_3[11:0];
		                      		end
		                      		3'd4 : begin
				                        data_3_next[29:12] = data_3[29:12];
				                        data_3_next[11:10] = EMPTY;
				                        data_3_next[9:0] = data_3[9:0];
		                      		end
		                      		3'd5 : begin
				                        data_3_next[29:10] = data_3[29:10];
				                        data_3_next[9:8] = EMPTY;
				                        data_3_next[7:0] = data_3[7:0];
		                      		end
		                      		3'd6 : begin
				                        data_3_next[29:8] = data_3[29:8];
				                        data_3_next[7:6] = EMPTY;
				                        data_3_next[5:0] = data_3[5:0];
		                      		end
		                      		3'd7 : begin
				                        data_3_next[29:6] = data_3[29:6];
				                        data_3_next[5:4] = EMPTY;
				                        data_3_next[3:0] = data_3[3:0];
		                      		end
		                      		default : begin
		                        		data_3_next = data_3;
		                      		end
	                    		endcase
		                	end
		                	else begin
		                  		data_3_next = data_3;
		                  		counter_coin_next = counter_coin;
		                	end
		              	end
		              	else begin
		                	data_3_next = data_3;
		                	counter_coin_next = counter_coin;
		              	end
	            	end
	            	3'd4 : begin
		              	data_1_next = data_1;
		              	data_2_next = data_2;
		              	data_3_next = data_3;
		              	data_5_next = data_5;
		              	data_6_next = data_6;
		              	if (data_4[29:28] == GRASS) begin
		                	if ({data_4[19 - 2 * chicken[7:5]], data_4[19 - 2 * chicken[7:5] - 1]} == COIN) begin
		                		counter_coin_next = counter_coin + 10'd1;
		                    	case (chicken[7:5])
	                      			3'd0 : begin
				                        data_4_next[29:20] = data_4[29:20];
				                        data_4_next[19:18] = EMPTY;
				                        data_4_next[17:0] = data_4[17:0];
	                      			end
	                      			3'd1 : begin
				                        data_4_next[29:18] = data_4[29:18];
				                        data_4_next[17:16] = EMPTY;
				                        data_4_next[15:0] = data_4[15:0];
	                      			end
	                      			3'd2 : begin
				                        data_4_next[29:16] = data_4[29:16];
				                        data_4_next[15:14] = EMPTY;
				                        data_4_next[13:0] = data_4[13:0];
	                      			end
	                      			3'd3 : begin
				                        data_4_next[29:14] = data_4[29:14];
				                        data_4_next[13:12] = EMPTY;
				                        data_4_next[11:0] = data_4[11:0];
	                      			end
	                      			3'd4 : begin
				                        data_4_next[29:12] = data_4[29:12];
				                        data_4_next[11:10] = EMPTY;
				                        data_4_next[9:0] = data_4[9:0];
	                      			end
	                      			3'd5 : begin
				                        data_4_next[29:10] = data_4[29:10];
				                        data_4_next[9:8] = EMPTY;
				                        data_4_next[7:0] = data_4[7:0];
	                      			end
	                      			3'd6 : begin
				                        data_4_next[29:8] = data_4[29:8];
				                        data_4_next[7:6] = EMPTY;
				                        data_4_next[5:0] = data_4[5:0];
	                      			end
	                      			3'd7 : begin
				                        data_4_next[29:6] = data_4[29:6];
				                        data_4_next[5:4] = EMPTY;
				                        data_4_next[3:0] = data_4[3:0];
	                      			end
	                      			default : begin
	                        			data_4_next = data_4;
	                      			end
	                    		endcase
	                		end
	                		else begin
	                  			data_4_next = data_4;
	                  			counter_coin_next = counter_coin;
	                		end
	              		end
	              		else begin
	                		data_4_next = data_4;
	                		counter_coin_next = counter_coin;
	              		end
	            	end
	            	3'd5 : begin
	              		data_1_next = data_1;
	              		data_2_next = data_2;
	              		data_3_next = data_3;
	              		data_4_next = data_4;
	              		data_6_next = data_6;
	              		if (data_5[29:28] == GRASS) begin
	                		if ({data_5[19 - 2 * chicken[7:5]], data_5[19 - 2 * chicken[7:5] - 1]} == COIN) begin
	                			counter_coin_next = counter_coin + 10'd1;
	                    		case (chicken[7:5])
	                      			3'd0 : begin
				                        data_5_next[29:20] = data_5[29:20];
				                        data_5_next[19:18] = EMPTY;
				                        data_5_next[17:0] = data_5[17:0];
	                      			end
	                      			3'd1 : begin
				                        data_5_next[29:18] = data_5[29:18];
				                        data_5_next[17:16] = EMPTY;
				                        data_5_next[15:0] = data_5[15:0];
	                      			end
	                      			3'd2 : begin
				                        data_5_next[29:16] = data_5[29:16];
				                        data_5_next[15:14] = EMPTY;
				                        data_5_next[13:0] = data_5[13:0];
	                      			end
	                      			3'd3 : begin
				                        data_5_next[29:14] = data_5[29:14];
				                        data_5_next[13:12] = EMPTY;
				                        data_5_next[11:0] = data_5[11:0];
	                      			end
	                      			3'd4 : begin
				                        data_5_next[29:12] = data_5[29:12];
				                        data_5_next[11:10] = EMPTY;
				                        data_5_next[9:0] = data_5[9:0];
	                      			end
	                      			3'd5 : begin
				                        data_5_next[29:10] = data_5[29:10];
				                        data_5_next[9:8] = EMPTY;
				                        data_5_next[7:0] = data_5[7:0];
	                      			end
	                      			3'd6 : begin
				                        data_5_next[29:8] = data_5[29:8];
				                        data_5_next[7:6] = EMPTY;
				                        data_5_next[5:0] = data_5[5:0];
	                      			end
	                      			3'd7 : begin
				                        data_5_next[29:6] = data_5[29:6];
				                        data_5_next[5:4] = EMPTY;
				                        data_5_next[3:0] = data_5[3:0];
	                      			end
	                      			default : begin
	                        			data_5_next = data_5;
	                      			end
	                    		endcase
	                		end
	                		else begin
	                  			data_5_next = data_5;
	                  			counter_coin_next = counter_coin;
	                		end
	              		end
	              		else begin
	                		data_5_next = data_5;
	                		counter_coin_next = counter_coin;
	              		end
	            	end
	            	3'd6 : begin
	              			data_1_next = data_1;
	              			data_2_next = data_2;
	              			data_3_next = data_3;
	              			data_4_next = data_4;
	              			data_5_next = data_5;
	              			if (data_6[29:28] == GRASS) begin
	                			if ({data_6[19 - 2 * chicken[7:5]], data_6[19 - 2 * chicken[7:5] - 1]} == COIN) begin
	                				counter_coin_next = counter_coin + 10'd1;
	                    			case (chicken[7:5])
	                      			3'd0 : begin
				                        data_6_next[29:20] = data_6[29:20];
				                        data_6_next[19:18] = EMPTY;
				                        data_6_next[17:0] = data_6[17:0];
	                      			end
	                      			3'd1 : begin
				                        data_6_next[29:18] = data_6[29:18];
				                        data_6_next[17:16] = EMPTY;
				                        data_6_next[15:0] = data_6[15:0];
	                      			end
	                      			3'd2 : begin
				                        data_6_next[29:16] = data_6[29:16];
				                        data_6_next[15:14] = EMPTY;
				                        data_6_next[13:0] = data_6[13:0];
	                      			end
	                      			3'd3 : begin
				                        data_6_next[29:14] = data_6[29:14];
				                        data_6_next[13:12] = EMPTY;
				                        data_6_next[11:0] = data_6[11:0];
	                      			end
	                      			3'd4 : begin
				                        data_6_next[29:12] = data_6[29:12];
				                        data_6_next[11:10] = EMPTY;
				                        data_6_next[9:0] = data_6[9:0];
	                      			end
	                      			3'd5 : begin
				                        data_6_next[29:10] = data_6[29:10];
				                        data_6_next[9:8] = EMPTY;
				                        data_6_next[7:0] = data_6[7:0];
	                      			end
	                      			3'd6 : begin
				                        data_6_next[29:8] = data_6[29:8];
				                        data_6_next[7:6] = EMPTY;
				                        data_6_next[5:0] = data_6[5:0];
	                      			end
	                      			3'd7 : begin
				                        data_6_next[29:6] = data_6[29:6];
				                        data_6_next[5:4] = EMPTY;
				                        data_6_next[3:0] = data_6[3:0];
	                      			end
	                      			default : begin
	                        			data_6_next = data_6;
	                      			end
	                    		endcase
	                		end
	                		else begin
	                  			data_6_next = data_6;
	                  			counter_coin_next = counter_coin;
	                		end
	              		end
	              		else begin
	                		data_6_next = data_6;
	                		counter_coin_next = counter_coin;
	              		end
	            	end
	           		default : begin
		              	data_1_next = data_1;
		              	data_2_next = data_2;
		              	data_3_next = data_3;
		              	data_4_next = data_4;
		              	data_5_next = data_5;
		              	data_6_next = data_6;
                    counter_coin_next = counter_coin;
	           		end
	         	endcase
	     	end
	     	CHICKEN_IDLE : begin
		        // retain
		        data_transfer_finish = INVALID;
		        data_0_next = data_0;
		        data_1_next = data_1;
		        data_2_next = data_2;
		        data_3_next = data_3;
		        data_4_next = data_4;
		        data_5_next = data_5;
		        data_6_next = data_6;
		        data = 30'b0;
		        power_on_reset_next = power_on_reset;
		        position_y_background_next = position_y_background;
		        counter_idle_next = counter_idle;
		        chicken_next[29:28] = chicken[29:28];
		        chicken_next[17:8] = chicken[17:8];
		        chicken_next[4:0] = chicken[4:0];
		        game_state_next = game_state;
		        counter_coin_next = counter_coin;
		        background_chase_next = background_chase;
		        counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
		        // end of retain

		        data_control_state_next = CHICKEN_CASE;

		        case (chicken[4:2])
		            3'd0 : begin
		                if (data_0[29:28] == RIVER) begin
		                    case (data_0[0])
		                        LEFT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd0) begin
		                                if (chicken[7:5] == 3'd0) begin
		                                    chicken_next[7:5] = 3'd7;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] - 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                            
		                            case (data_0[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                            endcase
		                        end
		                        RIGHT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd39) begin
		                                if (chicken[7:5] == 3'd7) begin
		                                    chicken_next[7:5] = 3'd0;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] + 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                                    
		                            case (data_0[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                            endcase
		                        end
		                        default : begin
		                            chicken_next[27:18] = chicken[27:18];
		                            chicken_next[7:5] = chicken[7:5];
		                        end
		                    endcase
		                end
		                else begin
		                    chicken_next[27:18] = chicken[7:5] * 10'd40;
		                    chicken_next[7:5] = chicken[7:5];
		                end
		            end
		            3'd1 : begin
		                if (data_1[29:28] == RIVER) begin
		                    case (data_1[0])
		                        LEFT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd0) begin
		                                if (chicken[7:5] == 3'd0) begin
		                                    chicken_next[7:5] = 3'd7;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] - 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                            
		                            case (data_1[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                            endcase
		                        end
		                        RIGHT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd39) begin
		                                if (chicken[7:5] == 3'd7) begin
		                                    chicken_next[7:5] = 3'd0;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] + 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                                    
		                            case (data_1[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                            endcase
		                        end
		                        default : begin
		                            chicken_next[27:18] = chicken[27:18];
		                            chicken_next[7:5] = chicken[7:5];
		                        end
		                    endcase
		                end
		                else begin
		                    chicken_next[27:18] = chicken[7:5] * 10'd40;
		                    chicken_next[7:5] = chicken[7:5];
		                end
		            end
		            3'd2 : begin
		                if (data_2[29:28] == RIVER) begin
		                    case (data_2[0])
		                        LEFT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd0) begin
		                                if (chicken[7:5] == 3'd0) begin
		                                    chicken_next[7:5] = 3'd7;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] - 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                            
		                            case (data_2[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                            endcase
		                        end
		                        RIGHT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd39) begin
		                                if (chicken[7:5] == 3'd7) begin
		                                    chicken_next[7:5] = 3'd0;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] + 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                                    
		                            case (data_2[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                            endcase
		                        end
		                        default : begin
		                            chicken_next[27:18] = chicken[27:18];
		                            chicken_next[7:5] = chicken[7:5];
		                        end
		                    endcase
		                end
		                else begin
		                    chicken_next[27:18] = chicken[7:5] * 10'd40;
		                    chicken_next[7:5] = chicken[7:5];
		                end
		            end
		            3'd3 : begin
		                if (data_3[29:28] == RIVER) begin
		                    case (data_3[0])
		                        LEFT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd0) begin
		                                if (chicken[7:5] == 3'd0) begin
		                                    chicken_next[7:5] = 3'd7;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] - 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                            
		                            case (data_3[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                            endcase
		                        end
		                        RIGHT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd39) begin
		                                if (chicken[7:5] == 3'd7) begin
		                                    chicken_next[7:5] = 3'd0;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] + 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                                    
		                            case (data_3[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                            endcase
		                        end
		                        default : begin
		                            chicken_next[27:18] = chicken[27:18];
		                            chicken_next[7:5] = chicken[7:5];
		                        end
		                    endcase
		                end
		                else begin
		                    chicken_next[27:18] = chicken[7:5] * 10'd40;
		                    chicken_next[7:5] = chicken[7:5];
		                end
		            end
		            3'd4 : begin
		                if (data_4[29:28] == RIVER) begin
		                    case (data_4[0])
		                        LEFT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd0) begin
		                                if (chicken[7:5] == 3'd0) begin
		                                    chicken_next[7:5] = 3'd7;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] - 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                            
		                            case (data_4[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                            endcase
		                        end
		                        RIGHT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd39) begin
		                                if (chicken[7:5] == 3'd7) begin
		                                    chicken_next[7:5] = 3'd0;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] + 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                                    
		                            case (data_4[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                            endcase
		                        end
		                        default : begin
		                            chicken_next[27:18] = chicken[27:18];
		                            chicken_next[7:5] = chicken[7:5];
		                        end
		                    endcase
		                end
		                else begin
		                    chicken_next[27:18] = chicken[7:5] * 10'd40;
		                    chicken_next[7:5] = chicken[7:5];
		                end
		            end
		            3'd5 : begin
		                if (data_5[29:28] == RIVER) begin
		                    case (data_5[0])
		                        LEFT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd0) begin
		                                if (chicken[7:5] == 3'd0) begin
		                                    chicken_next[7:5] = 3'd7;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] - 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                            
		                            case (data_5[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                            endcase
		                        end
		                        RIGHT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd39) begin
		                                if (chicken[7:5] == 3'd7) begin
		                                    chicken_next[7:5] = 3'd0;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] + 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                                    
		                            case (data_5[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    else begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                            endcase
		                        end
		                        default : begin
		                            chicken_next[27:18] = chicken[27:18];
		                            chicken_next[7:5] = chicken[7:5];
		                        end
		                    endcase
		                end
		                else begin
		                    chicken_next[27:18] = chicken[7:5] * 10'd40;
		                    chicken_next[7:5] = chicken[7:5];
		                end
		            end
		            3'd6 : begin
		                if (data_6[29:28] == RIVER) begin
		                    case (data_6[0])
		                        LEFT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd0) begin
		                                if (chicken[7:5] == 3'd0) begin
		                                    chicken_next[7:5] = 3'd7;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] - 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                            
		                            case (data_6[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320)
		                                        chicken_next[27:18] = chicken[27:18] - 10'd1;
		                                    else
		                                        chicken_next[27:18] = 10'd319;
		                                end
		                            endcase
		                        end
		                        RIGHT : begin
		                            if (chicken[27:18] % 10'd40 == 10'd39) begin
		                                if (chicken[7:5] == 3'd7) begin
		                                    chicken_next[7:5] = 3'd0;
		                                end
		                                else begin
		                                    chicken_next[7:5] = chicken[7:5] + 1'd1;
		                                end
		                            end
		                            else begin
		                                chicken_next[7:5] = chicken[7:5];
		                            end
		                                    
		                            case (data_6[2:1])
		                                SPEED_0 : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                                default : begin
		                                    if (chicken[27:18] >= 10'd0 && chicken[27:18] < 10'd320) begin
		                                        chicken_next[27:18] = chicken[27:18] + 10'd1;
		                                    end
		                                    begin
		                                        chicken_next[27:18] = 10'd0;
		                                    end
		                                end
		                            endcase
		                        end
		                        default : begin
		                            chicken_next[27:18] = chicken[27:18];
		                            chicken_next[7:5] = chicken[7:5];
		                        end
		                    endcase
		                end
		                else begin
		                    chicken_next[27:18] = chicken[7:5] * 10'd40;
		                    chicken_next[7:5] = chicken[7:5];
		                end
		            end
		            default : begin
		                chicken_next[27:18] = chicken[27:18];
		                chicken_next[7:5] = chicken[7:5];
		            end
		        endcase
	     	end
	     	CHICKEN_JUMP : begin
		        // retain
		        data_transfer_finish = INVALID;
		        data_0_next = data_0;
		        data_1_next = data_1;
		        data_2_next = data_2;
		        data_3_next = data_3;
		        data_4_next = data_4;
		        data_5_next = data_5;
		        data_6_next = data_6;
		        data = 30'b0;
		        power_on_reset_next = power_on_reset;
		        position_y_background_next = position_y_background;
		        counter_idle_next = counter_idle;
		        chicken_next[29:28] = chicken[29:28];
		        game_state_next = game_state;
		        counter_coin_next = counter_coin;
		        barrier_code = 6'd0;
		        // end of retain

		        if (move[2] == VALID) begin
		            case (move[1:0])
		                JUMP_UP : begin
		                    // retain
		                    chicken_next[7:5] = chicken[7:5];
		                    chicken_next[27:18] = chicken[27:18];
		                    // end of retain

		                    if (jump_up_valid) begin
		                        chicken_next[4:2] = chicken[4:2] - 3'd1;
		                        chicken_next[17:8] = chicken[17:8] - 10'd40;
		                        chicken_next[1:0] = JUMP_UP;
		                        data_control_state_next = DATA_WAIT;
		                        
		                        counter_score_temp_next = counter_score_temp + 10'd1;
		                        if (counter_score_temp + 10'd1 > counter_score) begin
		                        	counter_score_next = counter_score + 10'd1;
		                        	background_chase_next = background_chase + 10'd40;
		                        end
		                        else begin
		                        	counter_score_next = counter_score;
		                        	background_chase_next = background_chase;
		                        end
		                    end
		                    else begin
		                        chicken_next[4:2] = chicken[4:2];
		                        chicken_next[17:8] = chicken[17:8];
		                        chicken_next[1:0] = move[1:0];
		                        data_control_state_next = DATA_WAIT;
		                        background_chase_next = background_chase;
		                        counter_score_temp_next = counter_score_temp;
		                        counter_score_next = counter_score;
		                    end
		                end
		                JUMP_DOWN : begin
		                    // retain
		                    chicken_next[7:5] = chicken[7:5];
		                    chicken_next[27:18] = chicken[27:18];
		                    background_chase_next = background_chase;
		                    counter_score_next = counter_score;
		                    // end of retain

		                    if (jump_down_valid) begin
		                        chicken_next[4:2] = chicken[4:2] + 3'd1;
		                        chicken_next[17:8] = chicken[17:8] + 10'd40;
		                        chicken_next[1:0] = JUMP_DOWN;
		                        data_control_state_next = DATA_WAIT;
		                        counter_score_temp_next = counter_score_temp - 10'd1;
		                    end
		                    else begin
		                        chicken_next[4:2] = chicken[4:2];
		                        chicken_next[17:8] = chicken[17:8];
		                        chicken_next[1:0] = move[1:0];
		                        data_control_state_next = DATA_WAIT;
		                        counter_score_temp_next = counter_score_temp;
		                    end
		                end
		                JUMP_LEFT : begin
		                    // retain
		                    chicken_next[4:2] = chicken[4:2];
		                    chicken_next[17:8] = chicken[17:8];
		                    background_chase_next = background_chase;
		                    counter_score_temp_next = counter_score_temp;
		                    counter_score_next = counter_score;
		                    // end of retain

		                    if (jump_left_valid) begin
		                        chicken_next[7:5] = chicken[7:5] - 3'd1;
		                        chicken_next[27:18] = chicken[27:18] - 10'd40;
		                        chicken_next[1:0] = JUMP_LEFT;
		                        data_control_state_next = DATA_WAIT;
		                    end
		                    else begin
		                        chicken_next[7:5] = chicken[7:5];
		                        chicken_next[27:18] = chicken[27:18];
		                        chicken_next[1:0] = move[1:0];
		                        data_control_state_next = DATA_WAIT;
		                    end
		                end
		                JUMP_RIGHT : begin
		                    // retain
		                    chicken_next[4:2] = chicken[4:2];
		                    chicken_next[17:8] = chicken[17:8];
		                    background_chase_next = background_chase;
		                    counter_score_temp_next = counter_score_temp;
		                    counter_score_next = counter_score;
		                    // end of retain

		                    if (jump_right_valid) begin
		                        chicken_next[7:5] = chicken[7:5] + 3'd1;
		                        chicken_next[27:18] = chicken[27:18] + 10'd40;
		                        chicken_next[1:0] = JUMP_RIGHT;
		                        data_control_state_next = DATA_WAIT;
		                    end
		                    else begin
		                        chicken_next[7:5] = chicken[7:5];
		                        chicken_next[27:18] = chicken[27:18];
		                        chicken_next[1:0] = move[1:0];
		                        data_control_state_next = DATA_WAIT;
		                    end
		                end
		                default : begin
		                    chicken_next[4:2] = chicken[4:2];
		                    chicken_next[17:8] = chicken[17:8];
		                    chicken_next[7:5] = chicken[7:5];
		                    chicken_next[27:18] = chicken[27:18];
		                    chicken_next[1:0] = chicken[1:0];
		                    data_control_state_next = DATA_WAIT;
		                    background_chase_next = background_chase;
		                    counter_score_temp_next = counter_score_temp;
		                    counter_score_next = counter_score;
		                end
		            endcase
		        end
		        else begin
		            chicken_next[27:0] = chicken[27:0];
		            data_control_state_next = CHICKEN_IDLE;
		            background_chase_next = background_chase;
		            counter_score_temp_next = counter_score_temp;
		            counter_score_next = counter_score;
		        end
		    end
	     	DATA_TRANSFER : begin
		        // retain
		        data = 30'b0;
		        power_on_reset_next = power_on_reset;
		        position_y_background_next = position_y_background;
		        counter_idle_next = counter_idle;
		        chicken_next = chicken;
		        game_state_next = game_state;
		        counter_coin_next = counter_coin;
		        background_chase_next = background_chase;
		        counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
		        // end of retain
		     
		        data_0_next = new_data;
		        data_1_next = data_0;
		        data_2_next = data_1;
		        data_3_next = data_2;
		        data_4_next = data_3;
		        data_5_next = data_4;
		        data_6_next = data_5;

	            data_transfer_finish = VALID;           
	            data_control_state_next = DATA_0;
	     	end
	     	DATA_RESET : begin
	      		// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = 30'd0;
	           	data_1_next = 30'd0;
	           	data_2_next = 30'd0;
	           	data_3_next = 30'd0;
	           	data_4_next = 30'd0;
	           	data_5_next = 30'd0;
	           	data_6_next = 30'd0;
	           	data = 30'b0;
	           	position_y_background_next = 10'd0;
	           	counter_idle_next = counter_idle;
	           	chicken_next = {2'b0, 10'd120, 10'd160, 3'd3, 3'd5, 2'd0};
	           	game_state_next = game_state;
	           	counter_coin_next = 10'd0;
	           	background_chase_next = 10'd0;
	           	counter_score_next = 10'd0;
	           	counter_score_temp_next = 10'd0;
	           	barrier_code = 6'd0;
	         	// end of retain

	         	power_on_reset_next = 1'b1;

	         	data_control_state_next = DATA_RESET_0;
	     	end
	     	DATA_RESET_0 : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	        	// end of retain

	        	data_0_next = new_data;

		        if (data_valid) begin
		            data_control_state_next = DATA_RESET_1;
		        end
		        else begin
		            data_control_state_next = DATA_RESET_0;
		        end
	     	end
	     	DATA_RESET_1 : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	        	// end of retain

	        	data_1_next = new_data;

		        if (data_valid) begin
		            data_control_state_next = DATA_RESET_2;
		        end
		        else begin
		            data_control_state_next = DATA_RESET_1;
		        end
		    end
	     	DATA_RESET_2 : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
		        // end of retain

		        data_2_next = new_data;

		        if (data_valid) begin
		            data_control_state_next = DATA_RESET_3;
		        end
		        else begin
		            data_control_state_next = DATA_RESET_2;
		        end
	     	end
	     	DATA_RESET_3 : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	        	// end of retain

	        	data_3_next = new_data;

		        if (data_valid) begin
		            data_control_state_next = DATA_RESET_4;
		        end
		        else begin
		            data_control_state_next = DATA_RESET_3;
		        end
		    end
	     	DATA_RESET_4 : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	        	// end of retain

		        data_4_next = new_data;

		        if (data_valid) begin
		            data_control_state_next = DATA_RESET_5;
		        end
		        else begin
		            data_control_state_next = DATA_RESET_4;
		        end
	     	end
	     	DATA_RESET_5 : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	        	// end of retain

	        	data_5_next = {GRASS, EMPTY, EMPTY, 4'b0000, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, 3'b000, 1'b0};

	        	if (data_valid) begin
		            data_control_state_next = DATA_RESET_6;
		        end
		        else begin
		            data_control_state_next = DATA_RESET_5;
		        end
	     	end
	     	DATA_RESET_6 : begin
	        	// retain
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	        	// end of retain

		        data_6_next = {GRASS, EMPTY, EMPTY, 4'b0000, ROCK, ROCK, TREE, ROCK, TREE, TREE, TREE, TREE, 3'b000, 1'b0};

		        if (data_valid) begin
		            data_control_state_next = DATA_WAIT;
		        end
		        else begin
		            data_control_state_next = DATA_RESET_6;
		        end
	     	end
	     	DATA_0 : begin
	         	// retain
	         	data_transfer_finish = INVALID;
	         	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	         	// end of retain
	         
	         	data = data_0;
	         	data_0_next = data_next;
	         	data_control_state_next = DATA_1;       
	     	end
	     	DATA_1 : begin
	           	// retain
	           	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	           	// end of retain
	           
	           	data = data_1;
	           	data_1_next = data_next;
	           	data_control_state_next = DATA_2;       
	       	end
	     	DATA_2 : begin
	           	// retain
	           	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	           	// end of retain
	           
	           	data = data_2;
	           	data_2_next = data_next;
	           	data_control_state_next = DATA_3;       
	       	end
	     	DATA_3 : begin
	           	// retain
	           	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	           	// end of retain
	           
	           	data = data_3;
	           	data_3_next = data_next;
	           	data_control_state_next = DATA_4;       
	       	end
	     	DATA_4 : begin
	           	// retain
	           	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	           	// end of retain
	           
	           	data = data_4;
	           	data_4_next = data_next;
	           	data_control_state_next = DATA_5;       
	       	end
	     	DATA_5 : begin
	           	// retain
	           	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_6_next = data_6;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	           	// end of retain
	           
	           	data = data_5;
	           	data_5_next = data_next;
	           	data_control_state_next = DATA_6;       
	       	end
	     	DATA_6 : begin
	           	// retain
	           	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	           	// end of retain
	           
	           	data = data_6;
	           	data_6_next = data_next;
	           	data_control_state_next = DATA_WAIT;       
	       	end
	     	default : begin
	         	data_transfer_finish = INVALID;
	           	data_0_next = data_0;
	           	data_1_next = data_1;
	           	data_2_next = data_2;
	           	data_3_next = data_3;
	           	data_4_next = data_4;
	           	data_5_next = data_5;
	           	data_6_next = data_6;
	           	data = 30'b0;
	           	power_on_reset_next = power_on_reset;
	           	position_y_background_next = position_y_background;
	           	counter_idle_next = counter_idle;
	           	chicken_next = chicken;
	           	data_control_state_next = DATA_WAIT;
	           	game_state_next = game_state;
	           	counter_coin_next = counter_coin;
	           	background_chase_next = background_chase;
	           	counter_score_next = counter_score;
	           	counter_score_temp_next = counter_score_temp;
	           	barrier_code = 6'd0;
	     	end
    	endcase
  	end

  	// chase speed
  	always @ * begin
  		if (background_chase == 10'd0) begin
  			chase_speed = 6'd0;
  			idle_time = 6'd5;
  		end
  		else if (background_chase > 10'd0 && background_chase <= 10'd40) begin
  			chase_speed = 6'd0;
  			idle_time = 6'd2;
  		end
  		else if (background_chase > 10'd40 && background_chase <= 10'd80) begin
  			chase_speed = 6'd0;
  			idle_time = 6'd0;
  		end
  		else if (background_chase > 10'd80 && background_chase <= 10'd120) begin
  			chase_speed = 6'd1;
  			idle_time = 6'd0;
  		end
  		else if (background_chase > 10'd120 && background_chase <= 10'd160) begin
  			chase_speed = 6'd2;
  			idle_time = 6'd0;
  		end
  		else if (background_chase > 10'd160 && background_chase <= 10'd200) begin
  			chase_speed = 6'd3;
  			idle_time = 6'd0;
  		end
  		else begin
  			chase_speed = 6'd0;
  			idle_time = 6'd5;
  		end
  	end
  	// end of chase speed

  	always @ * begin
  		case (barrier_code[5:2])
  			{RIVER, WATER_1} : begin
  				barrier_width_1 = 10'd80;
  			end
  			{RIVER, WATER_2} : begin
  				barrier_width_1 = 10'd120;
  			end
  			default : begin
  				barrier_width_1 = 10'd80;
  			end
  		endcase
  	end

  	always @ * begin
  		case ({barrier_code[5:4], barrier_code[1:0]})
  			{RIVER, WATER_1} : begin
  				barrier_width_2 = 10'd80;
  			end
  			{RIVER, WATER_2} : begin
  				barrier_width_2 = 10'd120;
  			end
  			default : begin
  				barrier_width_2 = 10'd80;
  			end
  		endcase
  	end
  
  	always @ (posedge clk or negedge rst_n) begin
     	if (~rst_n) begin
         	game_state <= MAIN_STATE;
         	power_on_reset <= 1'b0;
         	data_control_state <= DATA_WAIT;
         	counter_idle <= 4'd0;
         	position_y_background <= 10'd0;
         	counter_coin <= 10'd0;
         	background_chase <= 10'd0;
         	counter_score <= 10'd0;
         	counter_score_temp <= 10'd0;
     	end
     	else begin
         	game_state <= game_state_next;
         	power_on_reset <= power_on_reset_next;
         	data_control_state <= data_control_state_next;
         	counter_idle <= counter_idle_next;
         	position_y_background <= position_y_background_next;
         	counter_coin <= counter_coin_next;
         	background_chase <= background_chase_next;
         	counter_score <= counter_score_next;
         	counter_score_temp <= counter_score_temp_next;
     	end    
  	end

  	always @(posedge clk or negedge rst_n) begin
    	if(~rst_n) begin
	        data_0 <= {ROAD, CAR_1, CAR_1, 10'd120, 10'd240, 3'b000, 1'b1};
	        data_1 <= {RIVER, WATER_1, WATER_1, 10'd240, 10'd360, 3'b000, 1'b1};
	        data_2 <= {RAIL, TRAIN, EMPTY, 10'd0, 10'd0, 3'b000, RIGHT};
	        data_3 <= {GRASS, EMPTY, EMPTY, 4'b0000, ROCK, EMPTY, TREE, ROCK, EMPTY, EMPTY, TREE, TREE, 3'b000, 1'b0};
	        data_4 <= {GRASS, EMPTY, EMPTY, 4'b0000, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, 3'b000, 1'b0};
	        data_5 <= {GRASS, EMPTY, EMPTY, 4'b0000, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, 3'b000, 1'b0};
	        data_6 <= {GRASS, EMPTY, EMPTY, 4'b0000, ROCK, ROCK, TREE, ROCK, TREE, TREE, TREE, TREE, 3'b000, 1'b0};
	        chicken <= {2'b0, 10'd120, 10'd160, 3'd3, 3'd5, 2'd0};
	    end else begin
	      	data_0 <= data_0_next;
	      	data_1 <= data_1_next;
	      	data_2 <= data_2_next;
	      	data_3 <= data_3_next;
	      	data_4 <= data_4_next;
	      	data_5 <= data_5_next;
	      	data_6 <= data_6_next;
	      	chicken <= chicken_next;
	    end
  	end
  	// end of FSM for data control

  	// data control
  	always @ *
  		begin
     		case (data_control)
     			DATA_IDLE : begin
         			case (data[29:28])
         				GRASS : begin
             				data_next = data;
         				end
         				ROAD : begin
             				data_next[29:24] = data[29:24];
             				data_next[3:0] = data[3:0];
             				case (data[0])
             					RIGHT : begin
                 					case (data[3:1])
                     					SPEED_0 : begin
                         					if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
                             					data_next[23:14] = data[23:14] + 10'd1;
                         					end
                         					else begin
                             					data_next[23:14] = 10'd0;
                         					end

                         					if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
                             					data_next[13:4] = data[13:4] + 10'd1;
                         					end
                         					else begin
                             					data_next[13:4] = 10'd0;
                         					end
                         
                     					end
                     					SPEED_1 : begin
                         					if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
                             					data_next[23:14] = data[23:14] + 10'd2;
                         					end
                         					else begin
                             					data_next[23:14] = 10'd0;
                         					end

                         					if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
                             					data_next[13:4] = data[13:4] + 10'd2;
                         					end
                         					else begin
                             					data_next[13:4] = 10'd0;
                         					end
                     					end
                     					SPEED_2 : begin
                         					if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
                             					data_next[23:14] = data[23:14] + 10'd3;
                         					end
                         					else begin
                             					data_next[23:14] = 10'd0;
                         					end

                         					if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
                             					data_next[13:4] = data[13:4] + 10'd3;
                         					end
                         					else begin
                             					data_next[13:4] = 10'd0;
                         					end
                     					end
                     					SPEED_3 : begin
                         					if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
                             					data_next[23:14] = data[23:14] + 10'd4;
                         					end
                         					else begin
                             					data_next[23:14] = 10'd0;
                         					end

                         					if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
                             					data_next[13:4] = data[13:4] + 10'd4;
                         					end
                         					else begin
                             					data_next[13:4] = 10'd0;
                         					end
                     					end
                     					default : begin
                         					if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
                            					data_next[23:14] = data[23:14] + 1'd1;
                        					end
                        					else begin
					                            data_next[23:14] = 10'd0;
					                        end

					                        if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
					                            data_next[13:4] = data[13:4] + 1'd1;
					                        end
					                        else begin
					                            data_next[13:4] = 10'd0;
					                        end
                     					end
                 					endcase
             					end
             					LEFT : begin
                 					case (data[3:1])
                   						SPEED_0 : begin
                       						if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
                           						data_next[23:14] = data[23:14] - 10'd1;
                       						end
                       						else begin
                           						data_next[23:14] = 10'd439;
                       						end

                       						if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
                           						data_next[13:4] = data[13:4] - 10'd1;
                       						end
                       						else begin
                           						data_next[13:4] = 10'd439;
                       						end
                   						end
                   						SPEED_1 : begin
					                       	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
					                           	data_next[23:14] = data[23:14] - 10'd2;
					                       	end
					                       	else begin
					                           	data_next[23:14] = 10'd439;
					                       	end

					                       	if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
					                           	data_next[13:4] = data[13:4] - 10'd2;
					                       	end
					                       	else begin
					                           	data_next[13:4] = 10'd439;
					                       	end
					                   	end
					                   	SPEED_2 : begin
					                       	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
					                           	data_next[23:14] = data[23:14] - 10'd3;
					                       	end
					                       	else begin
					                           	data_next[23:14] = 10'd439;
					                       	end

					                       	if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
					                           	data_next[13:4] = data[13:4] - 10'd3;
					                       	end
					                       	else begin
					                           	data_next[13:4] = 10'd439;
					                       	end
					                   	end
					                   	SPEED_3 : begin
					                       	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
					                           	data_next[23:14] = data[23:14] - 10'd4;
					                       	end
					                       	else begin
					                           	data_next[23:14] = 10'd439;
					                       	end
					                       	if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
					                           	data_next[13:4] = data[13:4] - 10'd4;
					                       	end
					                       	else begin
					                           	data_next[13:4] = 10'd439;
					                       	end
					                   	end
					                   	default : begin
					                       	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
					                            data_next[23:14] = data[23:14] - 1'd1;
					                        end
					                        else begin
					                            data_next[23:14] = 10'd439;
					                        end
					                        if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
					                            data_next[13:4] = data[13:4] - 1'd1;
					                        end
					                        else begin
					                            data_next[13:4] = 10'd439;
					                        end
					                   	end
                   					endcase
             					end
             					default : begin
                 					data_next[23:4] = data[23:4];
             					end
             				endcase
         				end
         				RIVER : begin
			             	data_next[29:24] = data[29:24];
			             	data_next[3:0] = data[3:0];
			             	case (data[0])
			               		RIGHT : begin
			                   		case (data[3:1])
				                       	SPEED_0 : begin
				                           	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
				                               	data_next[23:14] = data[23:14] + 10'd1;
				                           	end
				                           	else begin
				                               	data_next[23:14] = 10'd0;
				                           	end

				                           	if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
				                               	data_next[13:4] = data[13:4] + 10'd1;
				                           	end
				                           	else begin
				                               	data_next[13:4] = 10'd0;
				                           	end
				                       	end
				                       	default : begin
				                           	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
				                               	data_next[23:14] = data[23:14] + 10'd1;
				                           	end
				                           	else begin
				                               	data_next[23:14] = 10'd0;
				                           	end

				                           	if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
				                               	data_next[13:4] = data[13:4] + 10'd1;
				                           	end
				                           	else begin
				                               	data_next[13:4] = 10'd0;
				                           	end
				                       	end
				                   	endcase
				               	end
				               	LEFT : begin
				                   	case (data[3:1])
				                   	SPEED_0 : begin
				                       	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
				                           	data_next[23:14] = data[23:14] - 10'd1;
				                       	end
				                       	else begin
				                           	data_next[23:14] = 10'd439;
				                       	end

				                       	if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
				                           	data_next[13:4] = data[13:4] - 10'd1;
				                       	end
				                       	else begin
				                           	data_next[13:4] = 10'd439;
				                       	end
				                   	end
				                   	default : begin
				                       	if (data[23:14] >= 10'd0 && data[23:14] < 10'd440) begin
				                           	data_next[23:14] = data[23:14] - 1'd1;
				                       	end
				                       	else begin
				                           	data_next[23:14] = 10'd439;
				                       	end

				                       	if (data[13:4] >= 10'd0 && data[13:4] < 10'd440) begin
				                            data_next[13:4] = data[13:4] - 1'd1;
				                        end
				                        else begin
				                            data_next[13:4] = 10'd439;
				                        end
				                   	end
				                   	endcase
				               	end
			               		default : begin
			                   		data_next = data;
			               		end
			               	endcase
			         	end
			         	RAIL : begin
				            data_next[29:26] = data[29:26];
				            data_next[0] = data[0];
				            if (data[1] == INVALID) begin
				                if (random[19:0] >= 20'd1043333) begin
				                    data_next[1] = VALID;
				                end
				                else begin
				                    data_next[1] = INVALID;
				                end
				            end
				            else begin
				                data_next[1] = data[1];
				            end

			             	if (data[1] == VALID && data[25:24] < 2'd2) begin
			                	if (clock_1s_state == OUTPUT_1S_CLOCK) begin
			                  		data_next[25:24] = data[25:24] + 2'd1;
			                	end
			                	else begin
			                  		data_next[25:24] = data[25:24];
			                	end
			             	end
			             	else begin
			                	data_next[25:24] = data[25:24];
			                	data_next[3] = INVALID;
			             	end

			             	if (data[1] == VALID && data[2] == INVALID) begin
			             		data_next[3] = clock_half_o;
			             	end
			             	else begin
			             		data_next[3] = INVALID;
			             	end

			             	if (data[1] == VALID && data[2] == INVALID && data[25:24] == 2'd2) begin
			                 	case(data[0])
			                     	RIGHT : begin
			                         	if (data[23:14] < 10'd440 && data[23:14] >= 10'd0 && data[13:4] < 10'd440 && data[13:4] >= 10'd0) begin
			                             	if (data[23:14] >= 10'd107) begin
				                                data_next[2] = data[2];
				                                data_next[23:14] = data[23:14] + 10'd8;
				                                data_next[13:4] = data[13:4] + 10'd8;
			                             	end
			                             	else begin
				                                data_next[2] = data[2];
				                                data_next[23:14] = data[23:14] + 10'd8;
				                                data_next[13:4] = data[13:4];
			                             	end
			                         	end
			                         	else if (data[13:4] < 10'd440 && data[13:4] >= 10'd0) begin
				                            data_next[2] = data[2];
				                            data_next[23:14] = data[23:14];
				                            data_next[13:4] = data[13:4] + 10'd8;
			                         	end
			                         	else begin
				                            data_next[2] = VALID;
				                            data_next[23:14] = 10'd0;
				                            data_next[13:4] = 10'd0;
			                         	end
			                     	end
			                     	LEFT : begin
			                         	if (data[23:14] <= 10'd440 && data[23:14] > 10'd0 && data[13:4] <= 10'd440 && data[13:4] > 10'd0) begin
			                            	if (data[23:14] < 10'd333) begin
				                                data_next[2] = data[2];
				                                data_next[23:14] = data[23:14] - 10'd8;
				                                data_next[13:4] = data[13:4] - 10'd8;
				                            end
			                            	else begin
				                                data_next[2] = data[2];
				                                data_next[23:14] = data[23:14] - 10'd8;
				                                data_next[13:4] = data[13:4];
				                            end
			                        	end
				                        else if (data[13:4] <= 10'd440 && data[13:4] > 10'd0) begin
				                            data_next[2] = data[2];
				                            data_next[23:14] = data[23:14];
				                            data_next[13:4] = data[13:4] - 10'd8;
				                        end
				                        else begin
				                            data_next[2] = VALID;
				                            data_next[23:14] = 10'd440;
				                            data_next[13:4] = 10'd440;
				                        end
			                     	end
			                     	default : begin
			                         	data_next[23:14] = data[23:14];
			                         	data_next[13:4] = data[13:4];
			                         	data_next[2] = data[2];
			                     	end
			                 	endcase
			             	end
			             	else begin
				                data_next[23:14] = data[23:14];
				                data_next[13:4] = data[13:4];
				                data_next[2] = data[2];
			             	end
			         	end
         				default : begin
             				data_next = data;
         				end
         			endcase
     			end
     			default : begin
         			data_next = data;
     			end
     		endcase
  		end
  	// data_control
  
  	random_seed random_seed(
      	.clk(clk), 
      	.rst_n(rst_n),
      	.power(game_state == MAIN_STATE),
      	.get_new_data(1'b1),
      	.random(random),
      	.O_new_data(new_data),
      	.data_valid(data_valid)
  	);
  
    jump_valid jump_valid(
        .chicken(chicken),
        .data_0(data_0),
        .data_1(data_1),
        .data_2(data_2),
        .data_3(data_3),
        .data_4(data_4),
        .data_5(data_5),
        .data_6(data_6),
        .jump_up_valid(jump_up_valid),
        .jump_down_valid(jump_down_valid),
        .jump_left_valid(jump_left_valid),
        .jump_right_valid(jump_right_valid)
    );

  	dead_judge dead_judge(
      	.chicken(chicken),
        .data_0(data_0),
        .data_1(data_1),
        .data_2(data_2),
        .data_3(data_3),
        .data_4(data_4),
        .data_5(data_5),
        .data_6(data_6),
        .chicken_state(chicken_state)
  	);
endmodule

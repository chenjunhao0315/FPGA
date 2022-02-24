`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/04 19:46:29
// Design Name: 
// Module Name: random_seed
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


module dead_judge(
	chicken,
	data_0,
	data_1,
	data_2,
	data_3,
	data_4,
	data_5,
	data_6,
	chicken_state
);

	input [29:0] chicken;
	input [29:0] data_0;
	input [29:0] data_1;
	input [29:0] data_2;
	input [29:0] data_3;
	input [29:0] data_4;
	input [29:0] data_5;
	input [29:0] data_6;
	output chicken_state;

	parameter GRASS = 2'b00, ROAD = 2'b01, RIVER = 2'b10, RAIL = 2'b11;
    parameter EMPTY = 2'b00, TREE = 2'b01, ROCK = 2'b10, COIN = 2'b11;
    parameter CAR_1 = 2'b00, CAR_2 = 2'b01, CAR_3 = 2'b10, CAR_4 = 2'b11;
    parameter WATER_1 = 2'b00, WATER_2 = 2'b01, WATER_3 = 2'b10, WATER_4 = 2'b11;
    parameter TRAIN = 2'b00;
    parameter CAR_1_SIZE = 10'd40;
    parameter CAR_2_SIZE = 10'd80;
    parameter WATER_1_SIZE = 10'd80;
    parameter WATER_2_SIZE = 10'd120;
    parameter TRAIN_SIZE = 10'd120;
    parameter MARGIN = 10'd8;

  	reg chicken_state;
  	reg [9:0] barrier_1_line_0, barrier_2_line_0;
  	reg [9:0] barrier_1_line_1, barrier_2_line_1;
  	reg [9:0] barrier_1_line_2, barrier_2_line_2;
  	reg [9:0] barrier_1_line_3, barrier_2_line_3;
  	reg [9:0] barrier_1_line_4, barrier_2_line_4;
  	reg [9:0] barrier_1_line_5, barrier_2_line_5;
  	reg [9:0] barrier_1_line_6, barrier_2_line_6;

  	parameter DEAD = 1'b0, LIVE = 1'b1;
  	parameter LEFT_MARGIN = 10'd20, RIGHT_MARGIN = 10'd20, DOWN_MARGIN = 10'd30, TOP_MARGIN = 10'd20;

	always @ *
	begin
		if ((chicken[27:18] + RIGHT_MARGIN >= 10'd0) && (chicken[27:18] <= 10'd280 + LEFT_MARGIN || chicken[27:18] >= 10'd400) && (chicken[17:8] + TOP_MARGIN >= 10'd0) && (chicken[17:8] <= 10'd199 + DOWN_MARGIN)) begin
			case (chicken[4:2])
				3'd0 : begin
					case (data_0[29:28])
						GRASS : begin
							chicken_state = LIVE;
						end
						RIVER : begin
							if ((chicken[27:18] + 10'd20 + 10'd120 >= data_0[23:14] && chicken[27:18] + 10'd20 + 10'd120 <= data_0[23:14] + barrier_1_line_0 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else if ((chicken[27:18] + 10'd20 + 10'd120 >= data_0[13:4] && chicken[27:18] + 10'd20 + 10'd120 <= data_0[13:4] + barrier_2_line_0 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else begin
								chicken_state = DEAD;
							end
						end
						ROAD, RAIL : begin
							if ((chicken[27:18] + MARGIN + 10'd120 >= data_0[23:14] && chicken[27:18] + MARGIN + 10'd120 <= data_0[23:14] + barrier_1_line_0) || (chicken[27:18] + 10'd40 + 10'd120 >= data_0[23:14] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_0[23:14] + barrier_1_line_0 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else if ((chicken[27:18] + MARGIN + 10'd120 >= data_0[13:4] && chicken[27:18] + MARGIN + 10'd120 <= data_0[13:4] + barrier_2_line_0) || (chicken[27:18] + 10'd40 + 10'd120 >= data_0[13:4] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_0[13:4] + barrier_2_line_0 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else begin
								chicken_state = LIVE;
							end
						end
						default : begin
							chicken_state = LIVE;
						end
					endcase
				end
				3'd1 : begin
					case (data_1[29:28])
						GRASS : begin
							chicken_state = LIVE;
						end
						RIVER : begin
							if ((chicken[27:18] + 10'd20 + 10'd120 >= data_1[23:14] && chicken[27:18] + 10'd20 + 10'd120 <= data_1[23:14] + barrier_1_line_1 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else if ((chicken[27:18] + 10'd20 + 10'd120 >= data_1[13:4] && chicken[27:18] + 10'd20 + 10'd120 <= data_1[13:4] + barrier_2_line_1 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else begin
								chicken_state = DEAD;
							end
						end
						ROAD, RAIL : begin
							if ((chicken[27:18] + MARGIN + 10'd120 >= data_1[23:14] && chicken[27:18] + MARGIN + 10'd120 <= data_1[23:14] + barrier_1_line_1) || (chicken[27:18] + 10'd40 + 10'd120 >= data_1[23:14] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_1[23:14] + barrier_1_line_1 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else if ((chicken[27:18] + MARGIN + 10'd120 >= data_1[13:4] && chicken[27:18] + MARGIN + 10'd120 <= data_1[13:4] + barrier_2_line_1) || (chicken[27:18] + 10'd40 + 10'd120 >= data_1[13:4] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_1[13:4] + barrier_2_line_1 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else begin
								chicken_state = LIVE;
							end
						end
						default : begin
							chicken_state = LIVE;
						end
					endcase
				end
				3'd2 : begin
					case (data_2[29:28])
						GRASS : begin
							chicken_state = LIVE;
						end
						RIVER : begin
							if ((chicken[27:18] + 10'd20 + 10'd120 >= data_2[23:14] && chicken[27:18] + 10'd20 + 10'd120 <= data_2[23:14] + barrier_1_line_2 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else if ((chicken[27:18] + 10'd20 + 10'd120 >= data_2[13:4] && chicken[27:18] + 10'd20 + 10'd120 <= data_2[13:4] + barrier_2_line_2 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else begin
								chicken_state = DEAD;
							end
						end
						ROAD, RAIL : begin
							if ((chicken[27:18] + MARGIN + 10'd120 >= data_2[23:14] && chicken[27:18] + MARGIN + 10'd120 <= data_2[23:14] + barrier_1_line_2) || (chicken[27:18] + 10'd40 + 10'd120 >= data_2[23:14] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_2[23:14] + barrier_1_line_2 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else if ((chicken[27:18] + MARGIN + 10'd120 >= data_2[13:4] && chicken[27:18] + MARGIN + 10'd120 <= data_2[13:4] + barrier_2_line_2) || (chicken[27:18] + 10'd40 + 10'd120 >= data_2[13:4] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_2[13:4] + barrier_2_line_2 + MARGIN)) begin
								chicken_state = DEAD;
							end
								else begin
								chicken_state = LIVE;
							end
						end
						default : begin
							chicken_state = LIVE;
						end
					endcase
				end
				3'd3 : begin
					case (data_3[29:28])
						GRASS : begin
							chicken_state = LIVE;
						end
						RIVER : begin
							if ((chicken[27:18] + 10'd20 + 10'd120 >= data_3[23:14] && chicken[27:18] + 10'd20 + 10'd120 <= data_3[23:14] + barrier_1_line_3 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else if ((chicken[27:18] + 10'd20 + 10'd120 >= data_3[13:4] && chicken[27:18] + 10'd20 + 10'd120 <= data_3[13:4] + barrier_2_line_3 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else begin
								chicken_state = DEAD;
							end
						end
						ROAD, RAIL : begin
							if ((chicken[27:18] + MARGIN + 10'd120 >= data_3[23:14] && chicken[27:18] + MARGIN + 10'd120 <= data_3[23:14] + barrier_1_line_3) || (chicken[27:18] + 10'd40 + 10'd120 >= data_3[23:14] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_3[23:14] + barrier_1_line_3 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else if ((chicken[27:18] + MARGIN + 10'd120 >= data_3[13:4] && chicken[27:18] + MARGIN + 10'd120 <= data_3[13:4] + barrier_2_line_3) || (chicken[27:18] + 10'd40 + 10'd120 >= data_3[13:4] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_3[13:4] + barrier_2_line_3 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else begin
								chicken_state = LIVE;
							end
						end
						default : begin
							chicken_state = LIVE;
						end
					endcase
				end
				3'd4 : begin
					case (data_4[29:28])
						GRASS : begin
							chicken_state = LIVE;
						end
						RIVER : begin
							if ((chicken[27:18] + 10'd20 + 10'd120 >= data_4[23:14] && chicken[27:18] + 10'd20 + 10'd120 <= data_4[23:14] + barrier_1_line_4 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else if ((chicken[27:18] + 10'd20 + 10'd120 >= data_4[13:4] && chicken[27:18] + 10'd20 + 10'd120 <= data_4[13:4] + barrier_2_line_4 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else begin
								chicken_state = DEAD;
							end
						end
						ROAD, RAIL : begin
							if ((chicken[27:18] + MARGIN + 10'd120 >= data_4[23:14] && chicken[27:18] + MARGIN + 10'd120 <= data_4[23:14] + barrier_1_line_4) || (chicken[27:18] + 10'd40 + 10'd120 >= data_4[23:14] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_4[23:14] + barrier_1_line_4 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else if ((chicken[27:18] + MARGIN + 10'd120 >= data_4[13:4] && chicken[27:18] + MARGIN + 10'd120 <= data_4[13:4] + barrier_2_line_4) || (chicken[27:18] + 10'd40 + 10'd120 >= data_4[13:4] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_4[13:4] + barrier_2_line_4 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else begin
								chicken_state = LIVE;
							end
						end
						default : begin
							chicken_state = LIVE;
						end
					endcase
				end
				3'd5 : begin
					case (data_5[29:28])
						GRASS : begin
							chicken_state = LIVE;
						end
						RIVER : begin
							if ((chicken[27:18] + 10'd20 + 10'd120 >= data_5[23:14] && chicken[27:18] + 10'd20 + 10'd120 <= data_5[23:14] + barrier_1_line_5 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else if ((chicken[27:18] + 10'd20 + 10'd120 >= data_5[13:4] && chicken[27:18] + 10'd20 + 10'd120 <= data_5[13:4] + barrier_2_line_5 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else begin
								chicken_state = DEAD;
							end
						end
						ROAD, RAIL : begin
							if ((chicken[27:18] + MARGIN + 10'd120 >= data_5[23:14] && chicken[27:18] + MARGIN + 10'd120 <= data_5[23:14] + barrier_1_line_5) || (chicken[27:18] + 10'd40 + 10'd120 >= data_5[23:14] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_5[23:14] + barrier_1_line_5 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else if ((chicken[27:18] + MARGIN + 10'd120 >= data_5[13:4] && chicken[27:18] + MARGIN + 10'd120 <= data_5[13:4] + barrier_2_line_5) || (chicken[27:18] + 10'd40 + 10'd120 >= data_5[13:4] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_5[13:4] + barrier_2_line_5 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else begin
								chicken_state = LIVE;
							end
						end
						default : begin
							chicken_state = LIVE;
						end
					endcase
				end
				3'd6 : begin
					case (data_6[29:28])
						GRASS : begin
							chicken_state = LIVE;
						end
						RIVER : begin
							if ((chicken[27:18] + 10'd20 + 10'd120 >= data_6[23:14] && chicken[27:18] + 10'd20 + 10'd120 <= data_6[23:14] + barrier_1_line_6 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else if ((chicken[27:18] + 10'd20 + 10'd120 >= data_6[13:4] && chicken[27:18] + 10'd20 + 10'd120 <= data_6[13:4] + barrier_2_line_6 - 10'd13)) begin
								chicken_state = LIVE;
							end
							else begin
								chicken_state = DEAD;
							end
						end
						ROAD, RAIL : begin
							if ((chicken[27:18] + MARGIN + 10'd120 >= data_6[23:14] && chicken[27:18] + MARGIN + 10'd120 <= data_6[23:14] + barrier_1_line_6) || (chicken[27:18] + 10'd40 + 10'd120 >= data_6[23:14] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_6[23:14] + barrier_1_line_6 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else if ((chicken[27:18] + MARGIN + 10'd120 >= data_6[13:4] && chicken[27:18] + MARGIN + 10'd120 <= data_6[13:4] + barrier_2_line_6) || (chicken[27:18] + 10'd40 + 10'd120 >= data_6[13:4] + MARGIN && chicken[27:18] + 10'd40 + 10'd120 <= data_6[13:4] + barrier_2_line_6 + MARGIN)) begin
								chicken_state = DEAD;
							end
							else begin
								chicken_state = LIVE;
							end
						end
						default : begin
							chicken_state = LIVE;
						end
					endcase
				end
				default : begin
					chicken_state = LIVE;
				end
			endcase
		end
		else begin
			chicken_state = DEAD;
		end
	end

	always @ *
	begin
		case (data_0[29:26])
			{ROAD, CAR_1} : begin
				barrier_1_line_0 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_1_line_0 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_1_line_0 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_1_line_0 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_1_line_0 = TRAIN_SIZE;
			end
			default : begin
				barrier_1_line_0 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case ({data_0[29:28], data_0[25:24]})
			{ROAD, CAR_1} : begin
				barrier_2_line_0 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_2_line_0 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_2_line_0 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_2_line_0 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_2_line_0 = TRAIN_SIZE;
			end
			default : begin
				barrier_2_line_0 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case (data_1[29:26])
			{ROAD, CAR_1} : begin
				barrier_1_line_1 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_1_line_1 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_1_line_1 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_1_line_1 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_1_line_1 = TRAIN_SIZE;
			end
			default : begin
				barrier_1_line_1 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case ({data_1[29:28], data_1[25:24]})
			{ROAD, CAR_1} : begin
				barrier_2_line_1 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_2_line_1 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_2_line_1 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_2_line_1 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_2_line_1 = TRAIN_SIZE;
			end
			default : begin
				barrier_2_line_1 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case (data_2[29:26])
			{ROAD, CAR_1} : begin
				barrier_1_line_2 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_1_line_2 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_1_line_2 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_1_line_2 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_1_line_2 = TRAIN_SIZE;
			end
			default : begin
				barrier_1_line_2 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case ({data_2[29:28], data_2[25:24]})
			{ROAD, CAR_1} : begin
				barrier_2_line_2 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_2_line_2 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_2_line_2 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_2_line_2 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_2_line_2 = TRAIN_SIZE;
			end
			default : begin
				barrier_2_line_2 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case (data_3[29:26])
			{ROAD, CAR_1} : begin
				barrier_1_line_3 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_1_line_3 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_1_line_3 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_1_line_3 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_1_line_3 = TRAIN_SIZE;
			end
			default : begin
				barrier_1_line_3 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case ({data_3[29:28], data_3[25:24]})
			{ROAD, CAR_1} : begin
				barrier_2_line_3 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_2_line_3 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_2_line_3 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_2_line_3 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_2_line_3 = TRAIN_SIZE;
			end
			default : begin
				barrier_2_line_3 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case (data_4[29:26])
			{ROAD, CAR_1} : begin
				barrier_1_line_4 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_1_line_4 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_1_line_4 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_1_line_4 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_1_line_4 = TRAIN_SIZE;
			end
			default : begin
				barrier_1_line_4 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case ({data_4[29:28], data_4[25:24]})
			{ROAD, CAR_1} : begin
				barrier_2_line_4 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_2_line_4 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_2_line_4 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_2_line_4 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_2_line_4 = TRAIN_SIZE;
			end
			default : begin
				barrier_2_line_4 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case (data_5[29:26])
			{ROAD, CAR_1} : begin
				barrier_1_line_5 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_1_line_5 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_1_line_5 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_1_line_5 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_1_line_5 = TRAIN_SIZE;
			end
			default : begin
				barrier_1_line_5 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case ({data_5[29:28], data_5[25:24]})
			{ROAD, CAR_1} : begin
				barrier_2_line_5 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_2_line_5 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_2_line_5 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_2_line_5 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_2_line_5 = TRAIN_SIZE;
			end
			default : begin
				barrier_2_line_5 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case (data_6[29:26])
			{ROAD, CAR_1} : begin
				barrier_1_line_6 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_1_line_6 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_1_line_6 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_1_line_6 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_1_line_6 = TRAIN_SIZE;
			end
			default : begin
				barrier_1_line_6 = 10'd40;
			end
		endcase
	end

	always @ *
	begin
		case ({data_6[29:28], data_6[25:24]})
			{ROAD, CAR_1} : begin
				barrier_2_line_6 = CAR_1_SIZE;
			end
			{ROAD, CAR_2} : begin
				barrier_2_line_6 = CAR_2_SIZE;
			end
			{RIVER, WATER_1} : begin
				barrier_2_line_6 = WATER_1_SIZE;
			end
			{RIVER, WATER_2} : begin
				barrier_2_line_6 = WATER_2_SIZE;
			end
			{RAIL, TRAIN} : begin
				barrier_2_line_6 = TRAIN_SIZE;
			end
			default : begin
				barrier_2_line_6 = 10'd40;
			end
		endcase
	end
endmodule
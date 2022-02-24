`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 14:13:21
// Design Name: 
// Module Name: jump_valid
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

module jump_valid(
	input [29:0] chicken,
	input [29:0] data_0,
	input [29:0] data_1,
	input [29:0] data_2,
	input [29:0] data_3,
	input [29:0] data_4,
	input [29:0] data_5,
	input [29:0] data_6,
	output jump_up_valid,
	output jump_down_valid,
	output jump_left_valid,
	output jump_right_valid
);
	parameter VALID = 1'b1, INVALID = 1'b0;
	parameter GRASS = 2'b00, ROAD = 2'b01, RIVER = 2'b10, RAIL = 2'b11;
  	parameter EMPTY = 2'b00, TREE = 2'b01, ROCK = 2'b10, COIN = 2'b11;

	reg jump_up_valid, jump_down_valid, jump_left_valid, jump_right_valid;

	always @ *
	begin
		case (chicken[4:2])
			3'd0 : begin
				jump_up_valid = INVALID;

				if (data_0[29:28] == GRASS) begin
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
						if (data_0[17:16] == ROCK || data_0[17:16] == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
					end
					else if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
						if (data_0[7:6] == ROCK || data_0[7:6] == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
					else begin
						if ({data_0[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_0[6'd16 - ((chicken[7:5]) * 6'd2)]} == ROCK || {data_0[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_0[6'd16 - ((chicken[7:5]) * 6'd2)]} == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
						if ({data_0[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_0[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == ROCK || {data_0[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_0[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
				end
				else begin
					if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
					end
					else begin
						jump_right_valid = VALID;
					end
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
					end
					else begin
						jump_left_valid = VALID;
					end
				end

				if (data_1[29:28] == GRASS) begin
					if ({data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_down_valid = INVALID;
					end
					else begin
						jump_down_valid = VALID;
					end
				end
				else begin
					jump_down_valid = VALID;
				end
			end
			3'd1 : begin
				if (data_1[29:28] == GRASS) begin
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
						if (data_1[17:16] == ROCK || data_1[17:16] == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
					end
					else if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
						if (data_1[7:6] == ROCK || data_1[7:6] == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
					else begin
						if ({data_1[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5]) * 6'd2)]} == ROCK || {data_1[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5]) * 6'd2)]} == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
						if ({data_1[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == ROCK || {data_1[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
				end
				else begin
					if (chicken[7:5] == 3'd7)
						jump_right_valid = INVALID;
					else begin
						jump_right_valid = VALID;
					end
					if (chicken[7:5] == 3'd0)
						jump_left_valid = INVALID;
					else begin
						jump_left_valid = VALID;
					end
				end

				if (data_2[29:28] == GRASS) begin
					if ({data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_down_valid = INVALID;
					end
					else begin
						jump_down_valid = VALID;
					end
				end
				else begin
					jump_down_valid = VALID;
				end

				if (data_0[29:28] == GRASS) begin
					if ({data_0[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_0[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_0[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_0[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_up_valid = INVALID;
					end
					else begin
						jump_up_valid = VALID;
					end
				end
				else begin
					jump_up_valid = VALID;
				end
			end
			3'd2 : begin
				if (data_2[29:28] == GRASS) begin
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
						if (data_2[17:16] == ROCK || data_2[17:16] == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
					end
					else if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
						if (data_2[7:6] == ROCK || data_2[7:6] == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
					else begin
						if ({data_2[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5]) * 6'd2)]} == ROCK || {data_2[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5]) * 6'd2)]} == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
						if ({data_2[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == ROCK || {data_2[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
				end
				else begin
					if (chicken[7:5] == 3'd7)
						jump_right_valid = INVALID;
					else begin
						jump_right_valid = VALID;
					end
					if (chicken[7:5] == 3'd0)
						jump_left_valid = INVALID;
					else begin
						jump_left_valid = VALID;
					end
				end

				if (data_3[29:28] == GRASS) begin
					if ({data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_down_valid = INVALID;
					end
					else begin
						jump_down_valid = VALID;
					end
				end
				else begin
					jump_down_valid = VALID;
				end

				if (data_1[29:28] == GRASS) begin
					if ({data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_1[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_up_valid = INVALID;
					end
					else begin
						jump_up_valid = VALID;
					end
				end
				else begin
					jump_up_valid = VALID;
				end
			end
			3'd3 : begin
				if (data_3[29:28] == GRASS) begin
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
						if (data_3[17:16] == ROCK || data_3[17:16] == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
					end
					else if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
						if (data_3[7:6] == ROCK || data_3[7:6] == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
					else begin
						if ({data_3[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5]) * 6'd2)]} == ROCK || {data_3[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5]) * 6'd2)]} == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
						if ({data_3[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == ROCK || {data_3[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
				end
				else begin
					if (chicken[7:5] == 3'd7)
						jump_right_valid = INVALID;
					else begin
						jump_right_valid = VALID;
					end
					if (chicken[7:5] == 3'd0)
						jump_left_valid = INVALID;
					else begin
						jump_left_valid = VALID;
					end
				end

				if (data_4[29:28] == GRASS) begin
					if ({data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_down_valid = INVALID;
					end
					else begin
						jump_down_valid = VALID;
					end
				end
				else begin
					jump_down_valid = VALID;
				end

				if (data_2[29:28] == GRASS) begin
					if ({data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_2[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_up_valid = INVALID;
					end
					else begin
						jump_up_valid = VALID;
					end
				end
				else begin
					jump_up_valid = VALID;
				end
			end
			3'd4 : begin
				if (data_4[29:28] == GRASS) begin
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
						if (data_4[17:16] == ROCK || data_4[17:16] == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
					end
					else if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
						if (data_4[7:6] == ROCK || data_4[7:6] == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
					else begin
						if ({data_4[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5]) * 6'd2)]} == ROCK || {data_4[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5]) * 6'd2)]} == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
						if ({data_4[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == ROCK || {data_4[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
				end
				else begin
					if (chicken[7:5] == 3'd7)
						jump_right_valid = INVALID;
					else begin
						jump_right_valid = VALID;
					end
					if (chicken[7:5] == 3'd0)
						jump_left_valid = INVALID;
					else begin
						jump_left_valid = VALID;
					end
				end

				if (data_5[29:28] == GRASS) begin
					if ({data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_down_valid = INVALID;
					end
					else begin
						jump_down_valid = VALID;
					end
				end
				else begin
					jump_down_valid = VALID;
				end

				if (data_3[29:28] == GRASS) begin
					if ({data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_3[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_up_valid = INVALID;
					end
					else begin
						jump_up_valid = VALID;
					end
				end
				else begin
					jump_up_valid = VALID;
				end
			end
			3'd5 : begin
				if (data_5[29:28] == GRASS) begin
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
						if (data_5[17:16] == ROCK || data_5[17:16] == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
					end
					else if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
						if (data_5[7:6] == ROCK || data_5[7:6] == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
					else begin
						if ({data_5[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5]) * 6'd2)]} == ROCK || {data_5[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5]) * 6'd2)]} == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
						if ({data_5[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == ROCK || {data_5[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
				end
				else begin
					if (chicken[7:5] == 3'd7)
						jump_right_valid = INVALID;
					else begin
						jump_right_valid = VALID;
					end
					if (chicken[7:5] == 3'd0)
						jump_left_valid = INVALID;
					else begin
						jump_left_valid = VALID;
					end
				end

				if (data_6[29:28] == GRASS) begin
					if ({data_6[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_6[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_6[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_6[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_down_valid = INVALID;
					end
					else begin
						jump_down_valid = VALID;
					end
				end
				else begin
					jump_down_valid = VALID;
				end

				if (data_4[29:28] == GRASS) begin
					if ({data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_4[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_up_valid = INVALID;
					end
					else begin
						jump_up_valid = VALID;
					end
				end
				else begin
					jump_up_valid = VALID;
				end
			end
			3'd6 : begin
				jump_down_valid = INVALID;

				if (data_6[29:28] == GRASS) begin
					if (chicken[7:5] == 3'd0) begin
						jump_left_valid = INVALID;
						if (data_6[17:16] == ROCK || data_6[17:16] == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
					end
					else if (chicken[7:5] == 3'd7) begin
						jump_right_valid = INVALID;
						if (data_6[7:6] == ROCK || data_6[7:6] == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
					else begin
						if ({data_6[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_6[6'd16 - ((chicken[7:5]) * 6'd2)]} == ROCK || {data_6[6'd16 - ((chicken[7:5]) * 6'd2) + 6'd1], data_6[6'd16 - ((chicken[7:5]) * 6'd2)]} == TREE) begin
							jump_right_valid = INVALID;
						end
						else begin
							jump_right_valid = VALID;
						end
						if ({data_6[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_6[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == ROCK || {data_6[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2) + 6'd1], data_6[6'd16 - ((chicken[7:5] - 6'd2) * 6'd2)]} == TREE) begin
							jump_left_valid = INVALID;
						end
						else begin
							jump_left_valid = VALID;
						end
					end
				end
				else begin
					if (chicken[7:5] == 3'd7)
						jump_right_valid = INVALID;
					else begin
						jump_right_valid = VALID;
					end
					if (chicken[7:5] == 3'd0)
						jump_left_valid = INVALID;
					else begin
						jump_left_valid = VALID;
					end
				end

				if (data_5[29:28] == GRASS) begin
					if ({data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == ROCK || {data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2) + 6'd1], data_5[6'd16 - ((chicken[7:5] - 6'd1) * 6'd2)]} == TREE) begin
						jump_up_valid = INVALID;
					end
					else begin
						jump_up_valid = VALID;
					end
				end
				else begin
					jump_up_valid = VALID;
				end
			end
			default : begin
				jump_up_valid = INVALID;
				jump_down_valid = INVALID;
				jump_left_valid = INVALID;
				jump_right_valid = INVALID;
			end
		endcase
	end
endmodule


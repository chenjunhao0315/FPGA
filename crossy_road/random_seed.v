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


module random_seed(
	clk, 
	rst_n,
	power,
	get_new_data,
	random,
	O_new_data,
	data_valid
);
	input clk;
	input rst_n;
	input power;
	input get_new_data;
	output [19:0] random;
	output [29:0] O_new_data;
	output reg data_valid;

    // var for LFSR
	reg [19:0] random_time, random_time_next;
	reg [19:0] random, random_next;
	reg random_xnor;
	// end of var for LFSR
	
	// var for generate data
	reg [4:0] generate_state, generate_state_next;
	reg [29:0] O_new_data, O_new_data_next, new_data, new_data_next;
	parameter GRASS = 2'b00, ROAD = 2'b01, RIVER = 2'b10, RAIL = 2'b11;
    parameter EMPTY = 2'b00, TREE = 2'b01, ROCK = 2'b10, COIN = 2'b11;
    parameter CAR_1 = 2'b00, CAR_2 = 2'b01, CAR_3 = 2'b10, CAR_4 = 2'b11;
    parameter WATER_1 = 2'b00, WATER_2 = 2'b01, WATER_3 = 2'b10, WATER_4 = 2'b11;
    parameter TRAIN = 2'b00;
	parameter WAIT = 5'd0, GENERATE_CONTROL = 5'd1, GENERATE_GROUND = 5'd2, GENERATE_BARRIER = 5'd3;
	reg [3:0] counter_barrier, counter_barrier_next;
	reg [3:0] barrier_quantity;
	reg [3:0] barrier_size;
	// end of var for generate data
	
	// generate data
	always @ *
	begin
	   	case (generate_state)
	       	WAIT : begin
	           	// retain
               	new_data_next = new_data;
               	counter_barrier_next = 4'd0;
               	barrier_quantity = 4'd0;
               	// end of retain

               	data_valid = 1'b1;
               
	           	if (get_new_data) begin
	            	generate_state_next = GENERATE_CONTROL;
	           	end
	           	else begin
	               	generate_state_next = WAIT;
	           	end
	       	end
	       	GENERATE_CONTROL : begin
	           	// retain
	           	new_data_next = 30'd0;
	           	counter_barrier_next = 4'd0;
	           	barrier_quantity = 4'd0;
	           	data_valid = 1'b0;
	           	// end of retain
	           
	           	generate_state_next = GENERATE_GROUND;
	       	end
	       	GENERATE_GROUND : begin
	           	// retain
	           	new_data_next[27:0] = new_data[27:0];
	           	counter_barrier_next = 4'd0;
               	barrier_quantity = 4'd0;
               	data_valid = 1'b0;
	           	// end of retain
	           
	           	if (random[9:0] >= 10'd650) begin
	               	new_data_next[29:28] = GRASS;
	           	end
	           	else if (random[9:0] >= 10'd300) begin
	               	new_data_next[29:28] = ROAD;
	           	end
	           	else if (random[9:0] >= 10'd100) begin
	               	new_data_next[29:28] = RIVER;
	           	end
	           	else if (random[9:0] >= 10'd0) begin
	               	new_data_next[29:28] = RAIL;
	           	end
	           	else begin
	               	new_data_next[29:28] = GRASS;
	           	end
	           
	           	generate_state_next = GENERATE_BARRIER;
	       end
	       GENERATE_BARRIER : begin
	           // retain
	           new_data_next[29:28] = new_data[29:28];
	           data_valid = 1'b0;
	           // end of retain
	           
	           case (new_data[29:28])
	               GRASS : begin
	                   barrier_quantity = 4'd8;
	                   new_data_next[27:20] = 8'b0;
	                   new_data_next[3:0] = 4'b0;
	                   if (counter_barrier == barrier_quantity) begin
	                       generate_state_next = WAIT;
	                       counter_barrier_next = 4'd0;
	                   end
	                   else begin
	                       generate_state_next = GENERATE_BARRIER;
	                       counter_barrier_next = counter_barrier + 4'd1;
	                       	case (counter_barrier)
	                       		4'd0 : begin
	                       			// retain
	                       			new_data_next[19:6] = new_data[19:6];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[5:4] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[5:4] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[5:4] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[5:4] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[5:4] = 16'd0;
			                       	end
	                       		end
	                       		4'd1 : begin
	                       			// retain
	                       			new_data_next[19:8] = new_data[19:8];
	                       			new_data_next[5:4] = new_data[5:4];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[7:6] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[7:6] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[7:6] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[7:6] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[7:6] = 16'd0;
			                       	end
	                       		end
	                       		4'd2 : begin
	                       			// retain
	                       			new_data_next[19:10] = new_data[19:10];
	                       			new_data_next[7:4] = new_data[7:4];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[9:8] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[9:8] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[9:8] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[9:8] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[9:8] = 16'd0;
			                       	end
	                       		end
	                       		4'd3 : begin
	                       			// retain
	                       			new_data_next[19:12] = new_data[19:12];
	                       			new_data_next[9:4] = new_data[9:4];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[11:10] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[11:10] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[11:10] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[11:10] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[11:10] = 16'd0;
			                       	end
	                       		end
	                       		4'd4 : begin
	                       			// retain
	                       			new_data_next[19:14] = new_data[19:14];
	                       			new_data_next[11:4] = new_data[11:4];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[13:12] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[13:12] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[13:12] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[13:12] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[13:12] = 16'd0;
			                       	end
	                       		end
	                       		4'd5 : begin
	                       			// retain
	                       			new_data_next[19:16] = new_data[19:16];
	                       			new_data_next[13:4] = new_data[13:4];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[15:14] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[15:14] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[15:14] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[15:14] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[15:14] = 16'd0;
			                       	end
	                       		end
	                       		4'd6 : begin
	                       			// retain
	                       			new_data_next[19:18] = new_data[19:18];
	                       			new_data_next[15:4] = new_data[15:4];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[17:16] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[17:16] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[17:16] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[17:16] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[17:16] = 16'd0;
			                       	end
	                       		end
	                       		4'd7 : begin
	                       			// retain
	                       			new_data_next[17:4] = new_data[17:4];
	                       			// end of retain

	                       			if (random[9:0] >= 10'd450) begin
			                           	new_data_next[19:18] = EMPTY;
			                       	end
			                       	else if (random[9:0] >= 10'd250) begin
			                           	new_data_next[19:18] = ROCK;
			                       	end
			                       	else if (random[9:0] >= 10'd50) begin
			                           	new_data_next[19:18] = TREE;
			                       	end
			                       	else if (random[9:0] >= 10'd0) begin
			                           	new_data_next[19:18] = COIN;
			                       	end
			                       	else begin
			                           	new_data_next[19:18] = 16'd0;
			                       	end
	                       		end
	                       		default : begin
	                       			new_data_next[19:4] = 16'b0;
	                       		end
	                       	endcase
	                   end
	               end
	               ROAD : begin
	                   barrier_quantity = 4'd6;
	                   case (counter_barrier)
	                       4'd0 : begin
	                           // retain
	                           new_data_next[25:0] = new_data[25:0];
	                           generate_state_next = GENERATE_BARRIER;
	                           // end of retain
	                           
	                           counter_barrier_next = counter_barrier + 4'd1;
	                           if (random[9:0] >= 10'd500) begin
	                               new_data_next[27:26] = CAR_1;
                               end
                               else if (random[9:0] >= 10'd0) begin
                                   new_data_next[27:26] = CAR_2;
                               end
                               else begin
                                   new_data_next[27:26] = CAR_1;
                               end
	                       end
	                       4'd1 : begin
	                           // retain
                               new_data_next[27:26] = new_data[27:26];
                               new_data_next[23:0] = new_data[23:0];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
	                           counter_barrier_next = counter_barrier + 4'd1;
	                           if (random[9:0] >= 10'd500) begin
	                               new_data_next[25:24] = CAR_1;
	                           end
	                           else if (random[9:0] >= 10'd0) begin
	                               new_data_next[25:24] = CAR_2;
	                           end
	                           else begin
	                               new_data_next[25:24] = CAR_1;
	                           end
	                       end
	                       4'd2 : begin
	                           // retain
                               new_data_next[27:24] = new_data[27:24];
                               new_data_next[13:0] = new_data[13:0];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
	                           if (random[9:0] >= 10'd0 && random[9:0] < 10'd440) begin
	                               counter_barrier_next = counter_barrier + 4'd1;
	                               new_data_next[23:14] = random[9:0];
	                           end
	                           else begin
	                               counter_barrier_next = counter_barrier;
	                               new_data_next[23:14] = new_data[23:14];
	                           end
	                       end
	                       	4'd3 : begin
	                           	// retain
                               	new_data_next[27:14] = new_data[27:14];
                               	new_data_next[3:0] = new_data[3:0];
                               	generate_state_next = GENERATE_BARRIER;
                               	// end of retain

                               	if (new_data[23:14] + barrier_size * 10'd40 + random[9:0] % 10'd200 >= 10'd440) begin
                               		new_data_next[13:4] = new_data[23:14] + barrier_size * 10'd40 + random[9:0] % 10'd200 - 10'd440;
                               	end
                               	else begin
                               		new_data_next[13:4] = new_data[23:14] + barrier_size * 10'd40 + random[9:0] % 10'd200;
                               	end
                               	
                               	counter_barrier_next = counter_barrier + 4'd1;
	                       end
	                       4'd4 : begin
	                           // retain
                               new_data_next[27:4] = new_data[27:4];
                               new_data_next[0] = new_data[0];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
                               counter_barrier_next = counter_barrier + 4'd1;
                               new_data_next[3:1] = random[3:1];
                           end
                           4'd5 : begin
	                           // retain
                               new_data_next[27:1] = new_data[27:1];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
                               counter_barrier_next = counter_barrier + 4'd1;
                               new_data_next[0] = random[0];
	                       end
	                       4'd6 : begin
	                           new_data_next[27:0] = new_data[27:0];
	                           counter_barrier_next = 4'd0;
	                           generate_state_next = WAIT;
	                       end
	                       
	                       default : begin
	                           new_data_next[27:0] = new_data[27:0];
	                           counter_barrier_next = 4'd0;
	                           generate_state_next = WAIT;
	                       end
	                   endcase
	               end
	               RIVER : begin
                       barrier_quantity = 4'd6;
                       case (counter_barrier)
                           4'd0 : begin
                               // retain
                               new_data_next[25:0] = new_data[25:0];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
                               counter_barrier_next = counter_barrier + 4'd1;
                               if (random[9:0] >= 10'd500) begin
                                   new_data_next[27:26] = WATER_1;
                               end
                               else if (random[9:0] >= 10'd0) begin
                                   new_data_next[27:26] = WATER_2;
                               end
                               else begin
                                   new_data_next[27:26] = WATER_1;
                               end
                           end
                           4'd1 : begin
                               // retain
                               new_data_next[27:26] = new_data[27:26];
                               new_data_next[23:0] = new_data[23:0];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
                               counter_barrier_next = counter_barrier + 4'd1;
                               if (random[9:0] >= 10'd500) begin
                                   new_data_next[25:24] = WATER_1;
                               end
                               else if (random[9:0] >= 10'd0) begin
                                   new_data_next[25:24] = WATER_2;
                               end
                               else begin
                                   new_data_next[25:24] = WATER_1;
                               end
                           end
                           4'd2 : begin
                               // retain
                               new_data_next[27:24] = new_data[27:24];
                               new_data_next[13:0] = new_data[13:0];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
                               if (random[9:0] >= 10'd0 && random[9:0] < 10'd440) begin
                                   counter_barrier_next = counter_barrier + 4'd1;
                                   new_data_next[23:14] = random[9:0];
                               end
                               else begin
                                   counter_barrier_next = counter_barrier;
                                   new_data_next[23:14] = new_data[23:14];
                               end
                           end
                           	4'd3 : begin
                               	// retain
                               	new_data_next[27:14] = new_data[27:14];
                               	new_data_next[3:0] = new_data[3:0];
                               	generate_state_next = GENERATE_BARRIER;
                               	// end of retain
                          
                               	if (new_data[23:14] + barrier_size * 10'd40 + random[9:0] % 10'd200 >= 10'd440) begin
                               		new_data_next[13:4] = new_data[23:14] + barrier_size * 10'd40 + random[9:0] % 10'd200 - 10'd440;
                               	end
                               	else begin
                               		new_data_next[13:4] = new_data[23:14] + barrier_size * 10'd40 + random[9:0] % 10'd200;
                               	end
                               	
                               	counter_barrier_next = counter_barrier + 4'd1;
                           end
                           4'd4 : begin
                               // retain
                               new_data_next[27:4] = new_data[27:4];
                               new_data_next[0] = new_data[0];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
                               counter_barrier_next = counter_barrier + 4'd1;
                               new_data_next[3:1] = random[3:1];
                           end
                           4'd5 : begin
                               // retain
                               new_data_next[27:1] = new_data[27:1];
                               generate_state_next = GENERATE_BARRIER;
                               // end of retain
                               
                               counter_barrier_next = counter_barrier + 4'd1;
                               new_data_next[0] = random[0];
                           end
                           4'd6 : begin
                               new_data_next[27:0] = new_data[27:0];
                               counter_barrier_next = 4'd0;
                               generate_state_next = WAIT;
                           end
                           
                           default : begin
                               new_data_next[27:0] = new_data[27:0];
                               counter_barrier_next = 4'd0;
                               generate_state_next = WAIT;
                           end
                       endcase
                   end
	               RAIL : begin
                       // retain
                       barrier_quantity = 4'd0;
                       counter_barrier_next = 4'd0;
                       // end of retain
                       if (random[0] == 1'b0) begin
                           new_data_next[27:0] = {4'b0, 10'd0, 10'd0, 3'd0, 1'b0};
                       end
                       else if (random[0] == 1'b1) begin
                           new_data_next[27:0] = {4'b0, 10'd440, 10'd440, 3'd0, 1'b1};
                       end
                       else begin
                           new_data_next[27:0] = new_data[27:0];
                       end
                       
                       generate_state_next = WAIT;
                   end
	               default : begin
	                   generate_state_next = WAIT;
	                   barrier_quantity = 4'd0;
	                   counter_barrier_next = 4'd0;
	                   new_data_next[27:0] = new_data[27:0]; 
	               end
	           endcase
	       end
	       default : begin
	           barrier_quantity = 4'd0;
	           counter_barrier_next = 4'd0;
	           generate_state_next = WAIT;
	           new_data_next = 30'd0;
	           data_valid = 1'b0;
	       end
	   endcase
	end
	
	always @ *
	begin
	   case (new_data[29:26])
	       {ROAD, CAR_1} : begin
	           barrier_size = 4'd1;
	       end
	       {ROAD, CAR_2} : begin
	           barrier_size = 4'd2;
	       end
	       {RIVER, WATER_1} : begin
	           barrier_size = 4'd2;
	       end
	       {RIVER, WATER_2} : begin
	           barrier_size = 4'd3;
	       end
	       default : begin
	           barrier_size = 4'd0;
	       end
	   endcase
	end
	
	always @ *
	begin
	   if (data_valid == 1'b1)
	       O_new_data_next = new_data;
	   else
	       O_new_data_next = O_new_data;
	end
	
	always @ (posedge clk or negedge rst_n) begin
	   if (~rst_n) begin
	       generate_state <= WAIT;
	       O_new_data <= 30'd0;
	       new_data <= 30'd0;
	       counter_barrier <= 4'd0;
	   end
	   else begin
	       generate_state <= generate_state_next;
	       O_new_data <= O_new_data_next;
	       new_data <= new_data_next;
	       counter_barrier <= counter_barrier_next;
	   end
	end
	// end of generate data

	// LFSR
	always @ *
	begin
		if (power) begin
			random_next = random_time;
		end
		else begin
			random_next = {random[18:0], random_xnor};
		end

	end

	always @ *
	begin
		random_time_next = {random_time[18:0], random_time[19] ^ ~random_time[6] ^ ~random_time[2] ^ ~random_time[1]};
		random_xnor = random[19] ^ ~random[6] ^ ~random[2] ^ ~random[1];
	end

	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			random <= 20'b10001000111000110101;
			random_time <= 20'b11011000100111000101;
		end
		else begin
			random <= random_next;
			random_time <= random_time_next;
		end
	end
	// end of LFSR

endmodule

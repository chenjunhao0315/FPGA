`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/28 04:03:59
// Design Name: 
// Module Name: input_control
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


module input_control(clk, clk_100, rst_n, bp, move, PS2_CLK, PS2_DATA, character, coin_store, input_mode);
    input clk;
    input clk_100;
    input rst_n;
    input [4:0]bp;
    input [9:0]coin_store;
    inout PS2_CLK;
    inout PS2_DATA;
    output reg [2:0] move;
    output character;
    output input_mode;
    
    reg [9:0] timer, timer_next;
    
    reg input_mode_state, input_mode_state_next;
    parameter BUTTON_INPUT = 1'b0, KEYBOARD_INPUT = 1'b1;
    
    reg character_state, character_state_next;
    parameter CHICKEN = 1'b0, SQUIRREL = 1'b1;
    
    wire [4:0] bp_d;
    reg input_up, input_down, input_left, input_right;
    reg mode_change, character_change;
    wire output_up, output_down, output_left, output_right;
    wire input_change_mode;
    
    wire [511:0] key_down;
    
    assign character = (coin_store >= 10'd3) ? character_state : CHICKEN;
    assign input_mode = input_mode_state;
    
    always @ *
        if (input_mode_state != input_mode_state_next || character_change)
            timer_next = 10'd0;
        else if (bp_d[4])
            timer_next = timer + 1'b1;
        else
            timer_next = timer;
    
    always @ (posedge clk_100 or negedge rst_n)
        if (~rst_n)
            timer <= 10'd0;
        else
            timer <= timer_next;
            
    always @ *
        if (~bp_d[4])
            begin
            if (timer > 10'd0 && timer < 10'd32)
                begin
                character_change = 1'b1;;
                mode_change = 1'b0;
                end
            else if (timer >= 10'd3)
                begin
                character_change = 1'b0;
                mode_change = 1'b1;
                end
            else
                begin
                character_change = 1'b0;
                mode_change = 1'b0;
                end
            end
        else
            begin
            character_change = 1'b0;
            mode_change = 1'b0;
            end 
            
    always @ * begin
        case(character_state)
            CHICKEN : begin
                if (character_change) begin
                    character_state_next = SQUIRREL;
                end
                else begin
                    character_state_next = CHICKEN;
                end
            end
            SQUIRREL : begin
                if (character_change) begin
                    character_state_next = CHICKEN;
                end
                else begin
                    character_state_next = SQUIRREL;
                end
            end
            default : begin
                character_state_next = CHICKEN;
            end
        endcase
    end
    
    always @ (posedge clk_100 or negedge rst_n) begin
        if (~rst_n) begin
            character_state <= CHICKEN;
        end
        else begin
            character_state <= character_state_next;
        end
    end
    
    always @ *
    begin
        case(input_mode_state)
            BUTTON_INPUT : begin
                input_up = bp_d[3];
                input_down = bp_d[2];
                input_left = bp_d[1];
                input_right = bp_d[0];
                if (input_change_mode) begin
                    input_mode_state_next = KEYBOARD_INPUT;
                end
                else begin
                    input_mode_state_next = BUTTON_INPUT;
                    
                end
            end
            KEYBOARD_INPUT : begin
                input_up = key_down[{1'b0, 8'h1d}];
                input_down = key_down[{1'b0, 8'h1b}];
                input_left = key_down[{1'b0, 8'h1c}];
                input_right = key_down[{1'b0, 8'h23}];
                if (input_change_mode) begin
                    input_mode_state_next = BUTTON_INPUT;
                end
                else begin
                    input_mode_state_next = KEYBOARD_INPUT;
                end
            end
            default : begin
                input_mode_state_next = BUTTON_INPUT;
            end
        endcase
    end
    
    always @ (posedge clk_100 or negedge rst_n) begin
        if (~rst_n) begin
            input_mode_state <= BUTTON_INPUT;
        end
        else begin
            input_mode_state <= input_mode_state_next;
        end
    end
    
    always @ *
    begin
        if (output_up) begin
            move = 3'b100;
        end
        else if (output_down) begin
            move = 3'b101;
        end
        else if (output_left) begin
            move = 3'b110;
        end
        else if (output_right) begin
            move = 3'b111;
        end
        else begin
            move = 3'b000;
        end
    end
    
    KeyboardDecoder KeyBoardDecoder(
        .clk(clk), 
        .rst(~rst_n), 
        .PS2_CLK(PS2_CLK), 
        .PS2_DATA(PS2_DATA), 
        .key_valid(key_valid), 
        .last_change(last_change), 
        .key_down(key_down)
    );    
    
    one_pulse bp_1_o(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_debounced(input_up), 
        .out_pulse(output_up)
    );
    
    one_pulse bp_2_o(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_debounced(input_down), 
        .out_pulse(output_down)
    );
    
    one_pulse bp_3_o(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_debounced(input_left), 
        .out_pulse(output_left)
    );
    
    one_pulse bp_4_o(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_debounced(input_right), 
        .out_pulse(output_right)
    );
    
    one_pulse bp_5_o(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_debounced(mode_change), 
        .out_pulse(input_change_mode)
    );
    
    debounce_circuit debouncer_1(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_in(bp[0]), 
        .pb_debounced(bp_d[0])
    );
    
    debounce_circuit debouncer_2(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_in(bp[1]), 
        .pb_debounced(bp_d[1])
    );
    
    debounce_circuit debouncer_3(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_in(bp[2]), 
        .pb_debounced(bp_d[2])
    );
    
    debounce_circuit debouncer_4(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_in(bp[3]), 
        .pb_debounced(bp_d[3])
    );
    
    debounce_circuit debouncer_5(
        .clk(clk_100), 
        .rst_n(rst_n), 
        .pb_in(bp[4]), 
        .pb_debounced(bp_d[4])
    );
endmodule

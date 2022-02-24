module render(
    clk,
    rst_n,
    frame_update,
    game_state,
    I_character,
    I_position_y_background,
    I_chicken,
    I_data_0,
    I_data_1,
    I_data_2,
    I_data_3,
    I_data_4,
    I_data_5,
    I_data_6,
    O_x,
    O_y,
    O_colour,
    O_valid,
    O_render_ready,
    draw_state,
    barrier_counter,
    counter_x_background,
    counter_y_background
);

    input clk;
    input rst_n;
    input frame_update;
    input [2:0] game_state;
    input I_character;
    input [9:0] I_position_y_background;
    input [29:0] I_chicken;
    input [29:0] I_data_0;
    input [29:0] I_data_1;
    input [29:0] I_data_2;
    input [29:0] I_data_3;
    input [29:0] I_data_4;
    input [29:0] I_data_5;
    input [29:0] I_data_6;
    output [9:0] O_x;
    output [9:0] O_y;
    output [3:0] O_colour;
    output O_valid;
    output O_render_ready;
    output [5:0] draw_state;
    output [3:0] barrier_counter;
    output [9:0] counter_x_background;
    output [9:0] counter_y_background;
    
    // var for frequency divider
    reg clk_50M;
    reg [26:0] clk_half_s;
    reg clk_half;
    // end of var for frequency divider
    
    // var for output stabilizer
    reg [9:0] O_x_out, O_x_next;
    reg [9:0] O_y_out, O_y_next;
    reg valid_out, valid_next;
    reg [3:0] colour, colour_out;
    // end of var for output stabilizer

    parameter INVALID = 1'b0, VALID = 1'b1;
    parameter TRANSPARENT = 4'd0;
    parameter MAIN_STATE = 3'd0, PLAYING_STATE = 3'd1, DEAD_STATE = 3'd2;
    parameter CHICKEN = 1'b0, SQUIRREL = 1'b1;

    // var for FSM
    reg [5:0] draw_state, draw_state_next;
    parameter WAIT = 6'd0, RENDER_CONTROL = 6'd1, DRAW_BACKGROUND = 6'd2, DRAW_LINE_0 = 6'd3, DRAW_LINE_1 = 6'd4,
              DRAW_LINE_2 = 6'd5, DRAW_LINE_3 = 6'd6, DRAW_LINE_4 = 6'd7, DRAW_LINE_5 = 6'd8, DRAW_LINE_6 = 6'd9,
              DRAW_BARRIER = 6'd10, DRAW_BARRIER_0 = 6'd11, DRAW_BARRIER_1 = 6'd12, DRAW_BARRIER_2 = 6'd13,
              DRAW_BARRIER_3 = 6'd14, DRAW_BARRIER_4 = 6'd15, DRAW_BARRIER_5 = 6'd16, DRAW_BARRIER_6 = 6'd17,
              WAIT_BARRIER_0 = 6'd19, WAIT_BARRIER_1 = 6'd20, WAIT_BARRIER_2 = 6'd21, WAIT_BARRIER_3 = 6'd22,
              WAIT_BARRIER_4 = 6'd23, WAIT_BARRIER_5 = 6'd24, WAIT_BARRIER_6 = 6'd25,
              DRAW_CHICKEN = 6'd18, DRAW_MAIN = 6'd26, DRAW_DEAD = 6'd27;
    // end of var for FSM

    // var for background
    parameter GRASS = 2'b00, ROAD = 2'b01, RIVER = 2'b10, RAIL = 2'b11;
    parameter EMPTY = 2'b00, TREE = 2'b01, ROCK = 2'b10, COIN = 2'b11;
    parameter CAR_1 = 2'b00, CAR_2 = 2'b01, CAR_3 = 2'b10, CAR_4 = 2'b11;
    parameter WATER_1 = 2'b00, WATER_2 = 2'b01, WATER_3 = 2'b10, WATER_4 = 2'b11;
    parameter TRAIN = 2'b00;
    parameter JUMP_UP = 2'b00, JUMP_DOWN = 2'b01, JUMP_LEFT = 2'b10, JUMP_RIGHT = 2'b11;
    parameter RIGHT = 1'b0, LEFT = 1'b1;
    reg [9:0] counter_x_background, counter_x_background_next;
    reg [9:0] counter_y_background, counter_y_background_next;
    reg [1:0] ground_code;
    reg [3:0] colour_ground;
    reg valid_ground;
    wire [3:0] colour_grass, colour_road, colour_river, colour_rail;
    wire [3:0] colour_main, colour_hand, colour_hand_push, colour_dead;
    // end of var for background
    
    // var for barrier
    reg [9:0] pos_x_barrier, pos_y_barrier;
    reg [3:0] colour_barrier;
    reg [5:0] barrier_code;
    reg [3:0] barrier_state;
    reg [3:0] barrier_quantity;
    reg [3:0] barrier_counter, barrier_counter_next;
    reg valid_barrier;
    reg [9:0] counter_x_barrier, counter_x_barrier_next;
    reg [9:0] counter_y_barrier, counter_y_barrier_next;
    reg [9:0] width_barrier, height_barrier;
    reg [19:0] barrier_position;
    wire [3:0] colour_tree, colour_rock, colour_coin;
    wire [3:0] colour_car_1_left, colour_car_1_right, colour_car_2_left, colour_car_2_right;
    wire [3:0] colour_water_1, colour_water_2, colour_water_3, colour_water_4;
    wire [3:0] colour_train_left, colour_train_right, colour_level_crossing_on_left, colour_level_crossing_on_right, colour_level_crossing_off;
    // end of var for barrier

    // var for chicken
    reg [9:0] counter_x_chicken, counter_x_chicken_next;
    reg [9:0] counter_y_chicken, counter_y_chicken_next;
    wire [3:0] colour_chicken_up, colour_chicken_down, colour_chicken_left, colour_chicken_right, colour_chicken_dead;
    wire [3:0] colour_squirrel_up, colour_squirrel_down, colour_squirrel_left, colour_squirrel_right, colour_squirrel_dead;
    // end of var for chicken
    
    // data = {BACKGROUND, BARRIER_1, BARRIER_2, POSITION_1, POSITION_2, SPEED, DIRECTION}
    // chicken = {TYPE, POSITION_X, POSITION_Y, POSITION_X_EASY, POSITION_Y_EASY, DIRECTION}

    // control
    reg [9:0] position_y_background;

    reg [29:0] chicken;
    reg character;
    
    reg [29:0] data_0;
    reg [29:0] data_1;
    reg [29:0] data_2;
    reg [29:0] data_3;
    reg [29:0] data_4;
    reg [29:0] data_5;
    reg [29:0] data_6;
    // end of control

    // frequency divider
    always @ (posedge clk or negedge rst_n)
        if (~rst_n) begin
            clk_50M <= 1'b0;
        end
        else begin
            clk_50M <= ~clk_50M;
        end

    always @ (posedge clk or negedge rst_n)
        if (~rst_n) begin
            clk_half_s <= 27'b0;
            clk_half <= 1'b0;
        end
        else if (clk_half_s == 27'd25000000) begin
            clk_half_s <= 27'b0;
            clk_half <= ~clk_half;
        end
        else begin
            clk_half_s <= clk_half_s + 27'd1;
            clk_half <= clk_half;
        end
    // end of frequency divider

    // output stablilizer
    always @ (posedge clk or negedge rst_n)
    begin
        if (~rst_n) begin
            O_x_out <= 10'd0;
            O_y_out <= 10'd0;
            valid_out <= 1'd0;
            colour_out <= 4'd0;
        end
        else begin
            O_x_out <= O_x_next;
            O_y_out <= O_y_next;
            valid_out <= valid_next;
            colour_out <= colour;
        end
    end
    
    assign O_x = O_x_out;
    assign O_y = O_y_out;
    assign O_valid = valid_out;
    assign O_colour = colour_out;
    assign O_render_ready = draw_state == RENDER_CONTROL;
    
    // end of output stabilizer
    
    // input stabilizer
    always @ (posedge clk or negedge rst_n) 
    begin
        if (~rst_n) begin
            position_y_background <= 10'd0;
            chicken <= 10'd0;
            data_0 <= 30'b0;
            data_1 <= 30'b0;
            data_2 <= 30'b0;
            data_3 <= 30'b0;
            data_4 <= 30'b0;
            data_5 <= 30'b0;
            data_6 <= 30'b0;
        end
        else if (frame_update) begin
            position_y_background <= I_position_y_background;
            chicken <= I_chicken;
            data_0 <= I_data_0;
            data_1 <= I_data_1;
            data_2 <= I_data_2;
            data_3 <= I_data_3;
            data_4 <= I_data_4;
            data_5 <= I_data_5;
            data_6 <= I_data_6;
        end
        else begin
            position_y_background <= position_y_background;
            chicken <= chicken;
            data_0 <= data_0;
            data_1 <= data_1;
            data_2 <= data_2;
            data_3 <= data_3;
            data_4 <= data_4;
            data_5 <= data_5;
            data_6 <= data_6;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            character <= CHICKEN;
        end 
        else if (game_state == MAIN_STATE) begin
            character <= I_character;
        end
        else begin
            character <= character;
        end
    end
    // end of input stabilizer

    // FSM for render
    always @ *
    begin
        case (draw_state)
            WAIT : begin
                // retain
                O_x_next = 10'd0;
                O_y_next = 10'd0;

                valid_next = INVALID;

                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                ground_code = 2'd0;
                
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                
                colour = TRANSPARENT;
                // end of retain

                if (frame_update) begin
                    draw_state_next = RENDER_CONTROL;
                end
                else begin
                    draw_state_next = WAIT;
                end
            end
            RENDER_CONTROL : begin
                // retain
                O_x_next = 10'd0;
                O_y_next = 10'd0;

                valid_next = INVALID;

                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                ground_code = 2'd0;
                
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                
                colour = TRANSPARENT;
                // end of retain

                draw_state_next = DRAW_BACKGROUND;
            end
            DRAW_BACKGROUND : begin
                // retain
                O_x_next = 10'd0;
                O_y_next = 10'd0;

                valid_next = INVALID;

                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                ground_code = 2'd0;
                
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                
                colour = TRANSPARENT;
                // end of retain

                draw_state_next = DRAW_LINE_0;
            end
            DRAW_LINE_0 : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain
                // position
                O_x_next = counter_x_background;
                O_y_next = position_y_background + counter_y_background - 10'd40;
                // end of position

                // image address
                if (counter_x_background == 10'd319 && counter_y_background == 10'd39) begin
                    draw_state_next = DRAW_LINE_1;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_LINE_0;
                    
                    if (counter_x_background == 10'd319) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                ground_code = data_0[29:28];
                colour = colour_ground;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && valid_ground)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            DRAW_LINE_1 : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain
                
                // position
                O_x_next = counter_x_background;
                O_y_next = position_y_background + counter_y_background;
                // end of position

                // image address
                if (counter_x_background == 10'd319 && counter_y_background == 10'd39) begin
                    draw_state_next = DRAW_LINE_2;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_LINE_1;
                    
                    if (counter_x_background == 10'd319) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                ground_code = data_1[29:28];
                colour = colour_ground;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && valid_ground)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            DRAW_LINE_2 : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain
                
                // position
                O_x_next = counter_x_background;
                O_y_next = position_y_background + counter_y_background + 10'd40;
                // end of position

                // image address
                if (counter_x_background == 10'd319 && counter_y_background == 10'd39) begin
                    draw_state_next = DRAW_LINE_3;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_LINE_2;
                    
                    if (counter_x_background == 10'd319) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                ground_code = data_2[29:28];
                colour = colour_ground;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && valid_ground)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            DRAW_LINE_3 : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain
                
                // position
                O_x_next = counter_x_background;
                O_y_next = position_y_background + counter_y_background + 10'd80;
                // end of position

                // image address
                if (counter_x_background == 10'd319 && counter_y_background == 10'd39) begin
                    draw_state_next = DRAW_LINE_4;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_LINE_3;
                    
                    if (counter_x_background == 10'd319) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                ground_code = data_3[29:28];
                colour = colour_ground;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && valid_ground)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            DRAW_LINE_4 : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain
                
                // position
                O_x_next = counter_x_background;
                O_y_next = position_y_background + counter_y_background + 10'd120;
                // end of position

                // image address
                if (counter_x_background == 10'd319 && counter_y_background == 10'd39) begin
                    draw_state_next = DRAW_LINE_5;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_LINE_4;
                    
                    if (counter_x_background == 10'd319) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                ground_code = data_4[29:28];
                colour = colour_ground;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && valid_ground)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            DRAW_LINE_5 : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain
                
                // position
                O_x_next = counter_x_background;
                O_y_next = position_y_background + counter_y_background + 10'd160;
                // end of position

                // image address
                if (counter_x_background == 10'd319 && counter_y_background == 10'd39) begin
                    draw_state_next = DRAW_LINE_6;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_LINE_5;
                    
                    if (counter_x_background == 10'd319) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                ground_code = data_5[29:28];
                colour = colour_ground;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && valid_ground)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            DRAW_LINE_6 : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain
                
                // position
                O_x_next = counter_x_background;
                O_y_next = position_y_background + counter_y_background + 10'd200;
                // end of position

                // image address
                if (counter_x_background == 10'd319 && counter_y_background == 10'd39) begin
                    if (game_state == DEAD_STATE) begin
                        draw_state_next = DRAW_CHICKEN;
                    end
                    else begin
                        draw_state_next = DRAW_BARRIER;
                    end
                    
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_LINE_6;
                    
                    if (counter_x_background == 10'd319) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                ground_code = data_6[29:28];
                colour = colour_ground;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && valid_ground)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            DRAW_BARRIER : begin
                // retain
                O_x_next = 10'd0;
                O_y_next = 10'd0;
                colour = TRANSPARENT;
                valid_next = INVALID;

                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                ground_code = 2'd0;    

                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 6'd0; 
                barrier_state = 4'd0;   
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                draw_state_next = DRAW_BARRIER_0;
            end
            DRAW_BARRIER_0 : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                // position
                O_x_next = pos_x_barrier;
                O_y_next = position_y_background + pos_y_barrier - 10'd40;
                // end of position

                // image address
                if (barrier_counter == barrier_quantity) begin
                    draw_state_next = DRAW_BARRIER_1;
                    barrier_counter_next = 4'd0;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else if (counter_x_barrier == width_barrier - 1'b1 && counter_y_barrier == height_barrier - 1'b1) begin
                    draw_state_next = DRAW_BARRIER_0;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_BARRIER_0;
                    barrier_counter_next = barrier_counter;
                    if (counter_x_barrier == width_barrier - 1'b1) begin
                        counter_x_barrier_next = 10'd0;
                        counter_y_barrier_next = counter_y_barrier + 10'd1;
                    end
                    else begin
                        counter_x_barrier_next = counter_x_barrier + 1'b1;
                        counter_y_barrier_next = counter_y_barrier;
                    end
                end
                // end of image address

                // get barrier position
                barrier_position = data_0[23:4];
                // end of get barrier position

                // get colour
                ground_code = data_0[29:28];
                barrier_code = data_0[27:24];
                barrier_state = data_0[3:0];
                colour = colour_barrier;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_barrier != TRANSPARENT && valid_barrier == VALID && barrier_counter != barrier_quantity)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end valid control
            end
            DRAW_BARRIER_1 : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                // position
                O_x_next = pos_x_barrier;
                O_y_next = position_y_background + pos_y_barrier;
                // end of position

                // image address
                if (barrier_counter == barrier_quantity) begin
                    draw_state_next = DRAW_BARRIER_2;
                    barrier_counter_next = 4'd0;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else if (counter_x_barrier == width_barrier - 1'b1 && counter_y_barrier == height_barrier - 1'b1) begin
                    draw_state_next = DRAW_BARRIER_1;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_BARRIER_1;
                    barrier_counter_next = barrier_counter;
                    if (counter_x_barrier == width_barrier - 1'b1) begin
                        counter_x_barrier_next = 10'd0;
                        counter_y_barrier_next = counter_y_barrier + 10'd1;
                    end
                    else begin
                        counter_x_barrier_next = counter_x_barrier + 1'b1;
                        counter_y_barrier_next = counter_y_barrier;
                    end
                end
                // end of image address

                // get barrier position
                barrier_position = data_1[23:4];
                // end of get barrier position

                // get colour
                ground_code = data_1[29:28];
                barrier_code = data_1[27:24];
                barrier_state = data_1[3:0];
                colour = colour_barrier;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_barrier != TRANSPARENT && valid_barrier == VALID && barrier_counter != barrier_quantity)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end valid control
            end
            DRAW_BARRIER_2 : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                // position
                O_x_next = pos_x_barrier;
                O_y_next = position_y_background + pos_y_barrier + 10'd40;
                // end of position

                // image address
                if (barrier_counter == barrier_quantity) begin
                    draw_state_next = DRAW_BARRIER_3;
                    barrier_counter_next = 4'd0;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else if (counter_x_barrier == width_barrier - 1'b1 && counter_y_barrier == height_barrier - 1'b1) begin
                    draw_state_next = DRAW_BARRIER_2;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_BARRIER_2;
                    barrier_counter_next = barrier_counter;
                    if (counter_x_barrier == width_barrier - 1'b1) begin
                        counter_x_barrier_next = 10'd0;
                        counter_y_barrier_next = counter_y_barrier + 10'd1;
                    end
                    else begin
                        counter_x_barrier_next = counter_x_barrier + 1'b1;
                        counter_y_barrier_next = counter_y_barrier;
                    end
                end
                // end of image address

                // get barrier position
                barrier_position = data_2[23:4];
                // end of get barrier position

                // get colour
                ground_code = data_2[29:28];
                barrier_code = data_2[27:24];
                barrier_state = data_2[3:0];
                colour = colour_barrier;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_barrier != TRANSPARENT && valid_barrier == VALID && barrier_counter != barrier_quantity)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end valid control
            end
            DRAW_BARRIER_3 : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                // position
                O_x_next = pos_x_barrier;
                O_y_next = position_y_background + pos_y_barrier + 10'd80;
                // end of position

                // image address
                if (barrier_counter == barrier_quantity) begin
                    draw_state_next = DRAW_BARRIER_4;
                    barrier_counter_next = 4'd0;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else if (counter_x_barrier == width_barrier - 1'b1 && counter_y_barrier == height_barrier - 1'b1) begin
                    draw_state_next = DRAW_BARRIER_3;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_BARRIER_3;
                    barrier_counter_next = barrier_counter;
                    if (counter_x_barrier == width_barrier - 1'b1) begin
                        counter_x_barrier_next = 10'd0;
                        counter_y_barrier_next = counter_y_barrier + 10'd1;
                    end
                    else begin
                        counter_x_barrier_next = counter_x_barrier + 1'b1;
                        counter_y_barrier_next = counter_y_barrier;
                    end
                end
                // end of image address

                // get barrier position
                barrier_position = data_3[23:4];
                // end of get barrier position

                // get colour
                ground_code = data_3[29:28];
                barrier_code = data_3[27:24];
                barrier_state = data_3[3:0];
                colour = colour_barrier;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_barrier != TRANSPARENT && valid_barrier == VALID && barrier_counter != barrier_quantity)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end valid control
            end
            DRAW_BARRIER_4 : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                // position
                O_x_next = pos_x_barrier;
                O_y_next = position_y_background + pos_y_barrier + 10'd120;
                // end of position

                // image address
                if (barrier_counter == barrier_quantity) begin
                    draw_state_next = DRAW_BARRIER_5;
                    barrier_counter_next = 4'd0;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else if (counter_x_barrier == width_barrier - 1'b1 && counter_y_barrier == height_barrier - 1'b1) begin
                    draw_state_next = DRAW_BARRIER_4;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_BARRIER_4;
                    barrier_counter_next = barrier_counter;
                    if (counter_x_barrier == width_barrier - 1'b1) begin
                        counter_x_barrier_next = 10'd0;
                        counter_y_barrier_next = counter_y_barrier + 10'd1;
                    end
                    else begin
                        counter_x_barrier_next = counter_x_barrier + 1'b1;
                        counter_y_barrier_next = counter_y_barrier;
                    end
                end
                // end of image address

                // get barrier position
                barrier_position = data_4[23:4];
                // end of get barrier position

                // get colour
                ground_code = data_4[29:28];
                barrier_code = data_4[27:24];
                barrier_state = data_4[3:0];
                colour = colour_barrier;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_barrier != TRANSPARENT && valid_barrier == VALID && barrier_counter != barrier_quantity)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end valid control
            end
            DRAW_BARRIER_5 : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                // position
                O_x_next = pos_x_barrier;
                O_y_next = position_y_background + pos_y_barrier + 10'd160;
                // end of position

                // image address
                if (barrier_counter == barrier_quantity) begin
                    draw_state_next = DRAW_BARRIER_6;
                    barrier_counter_next = 4'd0;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else if (counter_x_barrier == width_barrier - 1'b1 && counter_y_barrier == height_barrier - 1'b1) begin
                    draw_state_next = DRAW_BARRIER_5;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_BARRIER_5;
                    barrier_counter_next = barrier_counter;
                    if (counter_x_barrier == width_barrier - 1'b1) begin
                        counter_x_barrier_next = 10'd0;
                        counter_y_barrier_next = counter_y_barrier + 10'd1;
                    end
                    else begin
                        counter_x_barrier_next = counter_x_barrier + 1'b1;
                        counter_y_barrier_next = counter_y_barrier;
                    end
                end
                // end of image address

                // get barrier position
                barrier_position = data_5[23:4];
                // end of get barrier position

                // get colour
                ground_code = data_5[29:28];
                barrier_code = data_5[27:24];
                barrier_state = data_5[3:0];
                colour = colour_barrier;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_barrier != TRANSPARENT && valid_barrier == VALID && barrier_counter != barrier_quantity)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end valid control
            end
            DRAW_BARRIER_6 : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
                // end of retain

                // position
                O_x_next = pos_x_barrier;
                O_y_next = position_y_background + pos_y_barrier + 10'd200;
                // end of position

                // image address
                if (barrier_counter == barrier_quantity) begin
                    if (game_state == DEAD_STATE) begin
                        draw_state_next = DRAW_DEAD;
                    end
                    else begin
                        draw_state_next = DRAW_CHICKEN;
                    end
                    
                    barrier_counter_next = 4'd0;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else if (counter_x_barrier == width_barrier - 1'b1 && counter_y_barrier == height_barrier - 1'b1) begin
                    draw_state_next = DRAW_BARRIER_6;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_barrier_next = 10'd0;
                    counter_y_barrier_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_BARRIER_6;
                    barrier_counter_next = barrier_counter;
                    if (counter_x_barrier == width_barrier - 1'b1) begin
                        counter_x_barrier_next = 10'd0;
                        counter_y_barrier_next = counter_y_barrier + 10'd1;
                    end
                    else begin
                        counter_x_barrier_next = counter_x_barrier + 1'b1;
                        counter_y_barrier_next = counter_y_barrier;
                    end
                end
                // end of image address

                // get barrier position
                barrier_position = data_6[23:4];
                // end of get barrier position

                // get colour
                ground_code = data_6[29:28];
                barrier_code = data_6[27:24];
                barrier_state = data_6[3:0];
                colour = colour_barrier;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_barrier != TRANSPARENT && valid_barrier == VALID && barrier_counter != barrier_quantity)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end valid control
            end
            DRAW_CHICKEN : begin
                // retain
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                ground_code = 2'd0; 
                
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                // end of retain

                // position
                if (game_state == DEAD_STATE) begin
                    O_x_next = I_chicken[27:18] + counter_x_chicken;
                    O_y_next = I_chicken[17:8] + counter_y_chicken;
                end
                else begin
                    if (character == SQUIRREL && chicken[1:0] == JUMP_DOWN) begin
                        O_x_next = I_chicken[27:18] + counter_x_chicken;
                        O_y_next = I_chicken[17:8] + counter_y_chicken - 10'd6;
                    end
                    else begin
                        O_x_next = I_chicken[27:18] + counter_x_chicken;
                        O_y_next = I_chicken[17:8] + counter_y_chicken - 10'd12;
                    end
                end
                // end of position

                // image address
                if (counter_x_chicken == 10'd39 && counter_y_chicken == 10'd39) begin
                    if (game_state == MAIN_STATE) begin
                        draw_state_next = DRAW_MAIN;
                    end
                    else if (game_state == PLAYING_STATE) begin
                        draw_state_next = WAIT;
                    end
                    else if (game_state == DEAD_STATE) begin
                        draw_state_next = DRAW_BARRIER;
                    end
                    else begin
                        draw_state_next = WAIT;
                    end
                    counter_x_chicken_next = 10'd0;
                    counter_y_chicken_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_CHICKEN;
                    
                    if (counter_x_chicken == 10'd39) begin
                        counter_x_chicken_next = 10'd0;
                        counter_y_chicken_next = counter_y_chicken + 10'd1;
                    end
                    else begin
                        counter_x_chicken_next = counter_x_chicken + 10'd1;
                        counter_y_chicken_next = counter_y_chicken;
                    end
                end
                // end of image address

                // get colour
                if (game_state == DEAD_STATE) begin
                    if (character == CHICKEN) begin
                        colour = colour_chicken_dead;
                    end
                    else if (character == SQUIRREL) begin
                        colour = colour_squirrel_dead;
                    end
                    else begin
                        colour = colour_chicken_dead;
                    end
                end
                else begin
                    if (character == CHICKEN) begin
                        case (chicken[1:0])
                            JUMP_UP : begin
                                colour = colour_chicken_up;
                            end
                            JUMP_DOWN : begin
                                colour = colour_chicken_down;
                            end
                            JUMP_LEFT : begin
                                colour = colour_chicken_left;
                            end
                            JUMP_RIGHT : begin
                                colour = colour_chicken_right;
                            end
                            default : begin
                                colour = colour_chicken_up;
                            end
                        endcase
                    end
                    else if (character == SQUIRREL) begin
                        case (chicken[1:0])
                            JUMP_UP : begin
                                colour = colour_squirrel_up;
                            end
                            JUMP_DOWN : begin
                                colour = colour_squirrel_down;
                            end
                            JUMP_LEFT : begin
                                colour = colour_squirrel_left;
                            end
                            JUMP_RIGHT : begin
                                colour = colour_squirrel_right;
                            end
                            default : begin
                                colour = colour_squirrel_up;
                            end
                        endcase
                    end
                    else begin
                        colour = colour_chicken_up;
                    end
                end
                
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320) begin
                    if (game_state == DEAD_STATE) begin
                        if (character == CHICKEN) begin
                            if (colour_chicken_dead != TRANSPARENT) begin
                                valid_next = VALID;
                            end
                            else begin
                                valid_next = INVALID;
                            end
                        end
                        else if (character == SQUIRREL) begin
                            if (colour_squirrel_dead != TRANSPARENT) begin
                                valid_next = VALID;
                            end
                            else begin
                                valid_next = INVALID;
                            end
                        end
                        else begin
                            valid_next = INVALID;
                        end
                    end
                    else begin
                        if (character == CHICKEN) begin
                            case (chicken[1:0])
                                JUMP_UP : begin
                                    if (colour_chicken_up != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                JUMP_DOWN : begin
                                    if (colour_chicken_down != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                JUMP_LEFT : begin
                                    if (colour_chicken_left != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                JUMP_RIGHT : begin
                                    if (colour_chicken_right != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                default : begin
                                    if (colour_chicken_up != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                            endcase
                        end
                        else if (character == SQUIRREL) begin
                            case (chicken[1:0])
                                JUMP_UP : begin
                                    if (colour_squirrel_up != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                JUMP_DOWN : begin
                                    if (colour_squirrel_down != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                JUMP_LEFT : begin
                                    if (colour_squirrel_left != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                JUMP_RIGHT : begin
                                    if (colour_squirrel_right != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                                default : begin
                                    if (colour_squirrel_up != TRANSPARENT)
                                        valid_next = VALID;
                                    else
                                        valid_next = INVALID;
                                end
                            endcase
                        end
                        else begin
                            valid_next = INVALID;
                        end
                    end
                end
                else begin
                    valid_next = INVALID;
                end
                // end valid control
            end
            DRAW_MAIN : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;

                ground_code = 2'd0;
                // end of retain
                
                // position
                if (barrier_counter == 4'd0) begin
                    O_x_next = 10'd85 + counter_x_background;
                    O_y_next = 10'd40 + counter_y_background;
                end
                else if (barrier_counter == 4'd1 && clk_half == 1'b0) begin
                    O_x_next = 10'd120 + counter_x_background;
                    O_y_next = 10'd195 + counter_y_background;
                end
                else if (barrier_counter == 4'd1 && clk_half == 1'b1) begin
                    O_x_next = 10'd120 + counter_x_background;
                    O_y_next = 10'd190 + counter_y_background;
                end
                else begin
                    O_x_next = 10'd240;
                    O_y_next = 10'd320;
                end
                // end of position

                // image address
                if (barrier_counter == 4'd2) begin
                    colour = TRANSPARENT;
                    draw_state_next = WAIT;
                    barrier_counter_next = 4'd0;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else if (counter_x_background == 10'd149 && counter_y_background == 10'd59 && barrier_counter == 4'd0) begin
                    colour = TRANSPARENT;
                    draw_state_next = DRAW_MAIN;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else if (counter_x_background == 10'd39 && counter_y_background == 10'd39 && barrier_counter == 4'd1) begin
                    colour = TRANSPARENT;
                    draw_state_next = DRAW_MAIN;
                    barrier_counter_next = barrier_counter + 4'd1;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_MAIN;
                    barrier_counter_next = barrier_counter;
                    if (barrier_counter == 4'd0) begin
                        colour = colour_main;
                        if (counter_x_background == 10'd149) begin
                            counter_x_background_next = 10'd0;
                            counter_y_background_next = counter_y_background + 10'd1;
                        end
                        else begin
                            counter_x_background_next = counter_x_background + 10'd1;
                            counter_y_background_next = counter_y_background;
                        end
                    end
                    else if (barrier_counter == 4'd1) begin
                        if (clk_half == 1'b1) begin
                            colour = colour_hand;
                        end
                        else begin
                            colour = colour_hand_push;
                        end
                        
                        if (counter_x_background == 10'd39) begin
                            counter_x_background_next = 10'd0;
                            counter_y_background_next = counter_y_background + 10'd1;
                        end
                        else begin
                            counter_x_background_next = counter_x_background + 10'd1;
                            counter_y_background_next = counter_y_background;
                        end
                    end
                    else begin
                        colour = TRANSPARENT;
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = 10'd0;
                    end
                end
                // end of image address

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320) begin
                    if (barrier_counter == 4'd0 && colour_main != TRANSPARENT) begin
                        valid_next = VALID;
                    end
                    else if (barrier_counter == 4'd1 && clk_half == 1'b1 && colour_hand != TRANSPARENT) begin
                        valid_next = VALID;
                    end
                    else if (barrier_counter == 4'd1 && clk_half == 1'b0 && colour_hand_push != TRANSPARENT) begin
                        valid_next = VALID;
                    end
                    else begin
                        valid_next = INVALID;
                    end
                end
                else begin
                    valid_next = INVALID;
                end
                // end of valid control
            end
            DRAW_DEAD : begin
                // retain
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;

                ground_code = 2'd0;
                // end of retain
                
                // position
                O_x_next = 10'd70 + counter_x_background;
                O_y_next = 10'd40 + counter_y_background;
                // end of position

                // image address
                if (counter_x_background == 10'd179 && counter_y_background == 10'd119) begin
                    draw_state_next = WAIT;
                    counter_x_background_next = 10'd0;
                    counter_y_background_next = 10'd0;
                end
                else begin
                    draw_state_next = DRAW_DEAD;
                    
                    if (counter_x_background == 10'd179) begin
                        counter_x_background_next = 10'd0;
                        counter_y_background_next = counter_y_background + 10'd1;
                    end
                    else begin
                        counter_x_background_next = counter_x_background + 10'd1;
                        counter_y_background_next = counter_y_background;
                    end
                end
                // end of image address

                // get colour
                colour = colour_dead;
                // end of get colour

                // valid control
                if (O_y_next >= 10'd0 && O_y_next < 10'd240 && O_x_next >= 10'd0 && O_y_next < 10'd320 && colour_dead != TRANSPARENT)
                    valid_next = VALID;
                else
                    valid_next = INVALID;
                // end of valid control
            end
            default : begin
                draw_state_next = WAIT;
                O_x_next = 10'd0;
                O_y_next = 10'd0;
                valid_next = INVALID;
                colour = 4'd0;
                
                counter_x_background_next = 10'd0;
                counter_y_background_next = 10'd0;
                ground_code = 2'd0; 
                
                counter_x_barrier_next = 10'd0;
                counter_y_barrier_next = 10'd0;
                barrier_code = 4'd0;
                barrier_state = 4'd0;
                barrier_counter_next = 4'd0;
                barrier_position = 20'd0;
                
                counter_x_chicken_next = 10'd0;
                counter_y_chicken_next = 10'd0;
            end
        endcase
    end

    always @(posedge clk_50M or negedge rst_n) begin
        if(~rst_n) begin
            draw_state <= WAIT;
            counter_x_background <= 10'd0;
            counter_y_background <= 10'd0;
            
            counter_x_barrier <= 10'd0;
            counter_y_barrier <= 10'd0;
            barrier_counter <= 4'd0;

            counter_x_chicken <= 10'd0;
            counter_y_chicken <= 10'd0;
        end else begin
            draw_state <= draw_state_next;
            counter_x_background <= counter_x_background_next;
            counter_y_background <= counter_y_background_next;
            
            counter_x_barrier <= counter_x_barrier_next;
            counter_y_barrier <= counter_y_barrier_next;
            barrier_counter <= barrier_counter_next;

            counter_x_chicken <= counter_x_chicken_next;
            counter_y_chicken <= counter_y_chicken_next;
        end
    end
    // end of FSM for render

    // render ground
    always @ *
    begin
        case (ground_code)
            GRASS : begin
                valid_ground = VALID;
                colour_ground = colour_grass;
            end
            ROAD : begin
                valid_ground = VALID;
                colour_ground = colour_road;
            end
            RIVER : begin
                valid_ground = VALID;
                colour_ground = colour_river;
            end
            RAIL : begin
                valid_ground = VALID;
                colour_ground = colour_rail;
            end
            default : begin
                valid_ground = VALID;
                colour_ground = 4'd0;
            end
        endcase
    end
    // end of render ground

    // barrier render
    always @ *
    begin
        case (ground_code)
            GRASS : begin
                barrier_quantity = 4'd8;
                width_barrier = 10'd40;
                height_barrier = 10'd40;

                pos_x_barrier = barrier_counter * 10'd40 + counter_x_barrier;
                pos_y_barrier = counter_y_barrier;

                case ({barrier_position[16 - (2 * barrier_counter + 1)], barrier_position[16 - (2 * barrier_counter + 2)]})
                    EMPTY : begin
                        colour_barrier = TRANSPARENT;
                        valid_barrier = INVALID;
                    end
                    TREE : begin
                        colour_barrier = colour_tree;
                        valid_barrier = VALID;
                    end
                    ROCK : begin
                        colour_barrier = colour_rock;
                        valid_barrier = VALID;
                    end
                    COIN : begin
                        colour_barrier = colour_coin;
                        valid_barrier = VALID;
                    end
                    default : begin
                        colour_barrier = TRANSPARENT;
                        valid_barrier = INVALID;
                    end
                endcase
            end
            ROAD : begin
                barrier_quantity = 4'd2;

                if (barrier_counter == 4'd0) begin
                    // barrier position
                    pos_x_barrier = barrier_position[19:10] + counter_x_barrier - 120;  // 120 for invisible area
                    pos_y_barrier = counter_y_barrier;
                    // end of barrier position

                    // visible area condition
                    if (pos_x_barrier >= 0 && pos_x_barrier < 320) begin
                        valid_barrier = VALID;
                    end
                    else begin
                        valid_barrier = INVALID;
                    end
                    // end of visible area condition

                    // barrier type
                    case (barrier_code[3:2])
                        CAR_1 : begin
                            width_barrier = 10'd40;
                            height_barrier = 10'd40;

                            case (barrier_state[0])
                                RIGHT : begin
                                    colour_barrier = colour_car_1_right;
                                end
                                LEFT : begin
                                    colour_barrier = colour_car_1_left;
                                end
                                default : begin
                                    colour_barrier = colour_car_1_right;
                                end
                            endcase
                        end
                        CAR_2 : begin
                            width_barrier = 10'd80;
                            height_barrier = 10'd40;

                            case (barrier_state[0])
                                RIGHT : begin
                                    colour_barrier = colour_car_2_right;
                                end
                                LEFT : begin
                                    colour_barrier = colour_car_2_left;
                                end
                                default : begin
                                    colour_barrier = colour_car_2_right;
                                end
                            endcase
                        end
                        default : begin
                            width_barrier = 10'd0;
                            height_barrier = 10'd0;

                            colour_barrier = TRANSPARENT;
                        end
                    endcase
                    // end of barrier type
                end
                else if (barrier_counter == 4'd1) begin
                    // barrier position
                    pos_x_barrier = barrier_position[9:0] + counter_x_barrier - 120;    // 120 for invisible area
                    pos_y_barrier = counter_y_barrier;
                    // end of barrier position

                    // visible area condition
                    if (pos_x_barrier >= 0 && pos_x_barrier < 320) begin
                        valid_barrier = VALID;
                    end
                    else begin
                        valid_barrier = INVALID;
                    end
                    // end of visible area condition

                    // barrier type
                    case (barrier_code[1:0])
                        CAR_1 : begin
                            width_barrier = 10'd40;
                            height_barrier = 10'd40;

                            case (barrier_state[0])
                                RIGHT : begin
                                    colour_barrier = colour_car_1_right;
                                end
                                LEFT : begin
                                    colour_barrier = colour_car_1_left;
                                end
                                default : begin
                                    colour_barrier = colour_car_1_right;
                                end
                            endcase
                        end
                        CAR_2 : begin
                            width_barrier = 10'd80;
                            height_barrier = 10'd40;

                            case (barrier_state[0])
                                RIGHT : begin
                                    colour_barrier = colour_car_2_right;
                                end
                                LEFT : begin
                                    colour_barrier = colour_car_2_left;
                                end
                                default : begin
                                    colour_barrier = colour_car_2_right;
                                end
                            endcase
                        end
                        default : begin
                            width_barrier = 10'd0;
                            height_barrier = 10'd0;

                            colour_barrier = TRANSPARENT;
                        end
                    endcase
                    // end of barrier type
                end
                else begin
                    pos_x_barrier = 10'd0;
                    pos_y_barrier = 10'd0;
                    valid_barrier = INVALID;
                    colour_barrier = TRANSPARENT;

                    width_barrier = 10'd0;
                    height_barrier = 10'd0;
                end
            end
            RIVER : begin
                barrier_quantity = 4'd2;

                if (barrier_counter == 4'd0) begin
                    // barrier position
                    pos_x_barrier = barrier_position[19:10] + counter_x_barrier - 120;  // 120 for invisible area
                    pos_y_barrier = counter_y_barrier;
                    // end of barrier position

                    // visible area condition
                    if (pos_x_barrier >= 0 && pos_x_barrier < 320) begin
                        valid_barrier = VALID;
                    end
                    else begin
                        valid_barrier = INVALID;
                    end
                    // end of visible area condition

                    // barrier type
                    case (barrier_code[3:2])
                        WATER_1 : begin
                            width_barrier = 10'd80;
                            height_barrier = 10'd40;

                            colour_barrier = colour_water_1;
                        end
                        WATER_2 : begin
                            width_barrier = 10'd120;
                            height_barrier = 10'd40;

                            colour_barrier = colour_water_2;
                        end
                        default : begin
                            width_barrier = 10'd0;
                            height_barrier = 10'd0;

                            colour_barrier = TRANSPARENT;
                        end
                    endcase
                    // end of barrier type
                end
                else if (barrier_counter == 4'd1) begin
                    // barrier position
                    pos_x_barrier = barrier_position[9:0] + counter_x_barrier - 120;    // 120 for invisible area
                    pos_y_barrier = counter_y_barrier;
                    // end of barrier position

                    // visible area condition
                    if (pos_x_barrier >= 0 && pos_x_barrier < 320) begin
                        valid_barrier = VALID;
                    end
                    else begin
                        valid_barrier = INVALID;
                    end
                    // end of visible area condition

                    // barrier type
                    case (barrier_code[1:0])
                        WATER_1 : begin
                            width_barrier = 10'd80;
                            height_barrier = 10'd40;

                            colour_barrier = colour_water_1;
                        end
                        WATER_2 : begin
                            width_barrier = 10'd120;
                            height_barrier = 10'd40;

                            colour_barrier = colour_water_2;
                        end
                        default : begin
                            width_barrier = 10'd0;
                            height_barrier = 10'd0;

                            colour_barrier = TRANSPARENT;
                        end
                    endcase
                    // end of barrier type
                end
                else begin
                    pos_x_barrier = 10'd0;
                    pos_y_barrier = 10'd0;
                    valid_barrier = INVALID;
                    colour_barrier = TRANSPARENT;

                    width_barrier = 10'd0;
                    height_barrier = 10'd0;
                end
            end
            RAIL : begin
                barrier_quantity = 4'd3;

                if (barrier_counter == 4'd0) begin
                    // barrier position
                    if (barrier_state[0] == RIGHT) begin
                        pos_x_barrier = barrier_position[9:0] + counter_x_barrier - 10'd120;
                    end
                    else begin
                        pos_x_barrier = barrier_position[19:10] + counter_x_barrier - 10'd120;  // 120 for invisible area
                    end
                    pos_y_barrier = counter_y_barrier - 10'd7;
                    // end of barrier position

                    // visible area condition
                    if (pos_x_barrier >= 10'd0 && pos_x_barrier < 10'd320) begin
                        valid_barrier = VALID;
                    end
                    else begin
                        valid_barrier = INVALID;
                    end
                    // end of visible area condition

                    // barrier type
                    width_barrier = 10'd120;
                    height_barrier = 10'd40;

                    colour_barrier = colour_train_left;
                end
                else if (barrier_counter == 4'd1) begin
                    // barrier position
                    if (barrier_state[0] == RIGHT) begin
                        pos_x_barrier = barrier_position[19:10] + counter_x_barrier - 10'd120;
                    end
                    else begin
                        pos_x_barrier = barrier_position[9:0] + counter_x_barrier - 10'd120;    // 120 for invisible area
                    end
                    pos_y_barrier = counter_y_barrier - 10'd7;
                    // end of barrier position

                    // visible area condition
                    if (pos_x_barrier >= 10'd0 && pos_x_barrier < 10'd320) begin
                        valid_barrier = VALID;
                    end
                    else begin
                        valid_barrier = INVALID;
                    end
                    // end of visible area condition

                    // barrier type
                    width_barrier = 10'd120;
                    height_barrier = 10'd40;

                    colour_barrier = colour_train_right;
                end
                else if (barrier_counter == 4'd2) begin
                    // barrier position
                    pos_x_barrier = 10'd260 + counter_x_barrier - 10'd120;    // 120 for invisible area
                    pos_y_barrier = counter_y_barrier;
                    // end of barrier position

                    // visible area condition
                    if (pos_x_barrier >= 10'd0 && pos_x_barrier < 10'd320) begin
                        valid_barrier = VALID;
                    end
                    else begin
                        valid_barrier = INVALID;
                    end
                    // end of visible area condition

                    // barrier type
                    width_barrier = 10'd40;
                    height_barrier = 10'd40;

                    if (barrier_state[1] == VALID && barrier_state[2] == INVALID) begin
                        if (barrier_state[3] == VALID) begin
                            colour_barrier = colour_level_crossing_on_left;
                        end
                        else begin
                            colour_barrier = colour_level_crossing_on_right;
                        end
                    end
                    else begin
                        colour_barrier = colour_level_crossing_off;
                    end
                end
                else begin
                    pos_x_barrier = 10'd0;
                    pos_y_barrier = 10'd0;
                    valid_barrier = INVALID;
                    colour_barrier = TRANSPARENT;

                    width_barrier = 10'd0;
                    height_barrier = 10'd0;
                end
            end
            default : begin
                barrier_quantity = 4'd0;
                width_barrier = 10'd0;
                height_barrier = 10'd0;

                pos_x_barrier = 10'd0;
                pos_y_barrier = 10'd0;

                colour_barrier = TRANSPARENT;
                valid_barrier = INVALID;
            end
        endcase
    end
    // end of barrier render
    
    
    // MEMORY
    memory_chicken_up image_chicken_up (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_chicken_up)
    );

    memory_chicken_down image_chicken_down (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_chicken_down)
    );

    memory_chicken_left image_chicken_left (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_chicken_left)
    );

    memory_chicken_right image_chicken_right (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_chicken_right)
    );

    memory_chicken_dead image_chicken_dead (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_chicken_dead)
    );

    memory_squirrel_up image_squirrel_up (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_squirrel_up)
    );

    memory_squirrel_down image_squirrel_down (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_squirrel_down)
    );

    memory_squirrel_left image_squirrel_left (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_squirrel_left)
    );

    memory_squirrel_right image_squirrel_right (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_squirrel_right)
    );

    memory_squirrel_dead image_squirrel_dead (
        .clka(clk),
        .wea(0),
        .addra((counter_y_chicken * 40 + counter_x_chicken) % 1600),
        .dina(4'b0),
        .douta(colour_squirrel_dead)
    );

    memory_grass image_grass (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 320 + counter_x_background) % 12800),
        .dina(4'b0),
        .douta(colour_grass)
    );

    memory_road image_road (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 320 + counter_x_background) % 12800),
        .dina(4'b0),
        .douta(colour_road)
    );

    memory_river image_river (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 320 + counter_x_background) % 12800),
        .dina(4'b0),
        .douta(colour_river)
    );

    memory_rail image_rail (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 320 + counter_x_background) % 12800),
        .dina(4'b0),
        .douta(colour_rail)
    );
    
    memory_tree image_tree (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_tree)
    );

    memory_rock image_rock (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_rock)
    );

    memory_coin image_coin (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_coin)
    );

    memory_car_1_left image_car_1_left (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_car_1_left)
    );

    memory_car_1_right image_car_1_right (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_car_1_right)
    );

    memory_car_2_left image_car_2_left (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 80 + counter_x_barrier) % 3200),
        .dina(4'b0),
        .douta(colour_car_2_left)
    );

    memory_car_2_right image_car_2_right (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 80 + counter_x_barrier) % 3200),
        .dina(4'b0),
        .douta(colour_car_2_right)
    );

    memory_water_1 image_water_1 (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 80 + counter_x_barrier) % 3200),
        .dina(4'b0),
        .douta(colour_water_1)
    );

    memory_water_2 image_water_2 (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 120 + counter_x_barrier) % 4800),
        .dina(4'b0),
        .douta(colour_water_2)
    );

    memory_train_left image_train_left (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 120 + counter_x_barrier) % 4800),
        .dina(4'b0),
        .douta(colour_train_left)
    );

    memory_train_right image_train_right (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 120 + counter_x_barrier) % 4800),
        .dina(4'b0),
        .douta(colour_train_right)
    );

    memory_level_crossing_on_left image_level_crossing_on_left (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_level_crossing_on_left)
    );

    memory_level_crossing_on_right image_level_crossing_on_right (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_level_crossing_on_right)
    );

    memory_level_crossing_off image_level_crossing_off (
        .clka(clk),
        .wea(0),
        .addra((counter_y_barrier * 40 + counter_x_barrier) % 1600),
        .dina(4'b0),
        .douta(colour_level_crossing_off)
    );

    memory_main image_main (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 150 + counter_x_background) % 9000),
        .dina(4'b0),
        .douta(colour_main)
    );

    memory_hand image_hand (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 40 + counter_x_background) % 1600),
        .dina(4'b0),
        .douta(colour_hand)
    );

    memory_hand_push image_hand_push (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 40 + counter_x_background) % 1600),
        .dina(4'b0),
        .douta(colour_hand_push)
    );

    memory_dead image_dead (
        .clka(clk),
        .wea(0),
        .addra((counter_y_background * 180 + counter_x_background) % 21600),
        .dina(4'b0),
        .douta(colour_dead)
    );
    // end of MEMORY
endmodule
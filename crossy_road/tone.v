`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/05 11:46:00
// Design Name: 
// Module Name: register
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


module tone(clk, rst_n, out_note_left, out_note_right, dead, light);
    input clk, rst_n;
    input dead, light;
    output reg [21:0]out_note_left, out_note_right;
    reg [26:0]cnt_1, cnt_1_tmp, cnt_3, cnt_3_tmp;
    reg clk_1, clk_3;
    reg [639:0]q_left, q_right;
    reg [775:0]q_dead;
    reg [1:0]q_light;
    reg [4:0]note_left, note_right;
    reg [3:0]note_dead;
    reg note_light;

    always @(posedge clk or negedge rst_n)
    if(~rst_n)
        cnt_1 <= 27'b0;
    else
    begin
        cnt_1 <= cnt_1_tmp;
        if(cnt_1 == 27'd10000000)
        begin
            clk_1 <= ~clk_1;
            cnt_1 <= 27'b0;
        end
    end
    
    always @*
        cnt_1_tmp = cnt_1 + 1'b1;
    
    always @(posedge clk or negedge rst_n)
    if(~rst_n)
        cnt_3 <= 27'b0;
    else
    begin
        cnt_3 <= cnt_3_tmp;
        if(cnt_3 == 27'd4000000)
        begin
            clk_3 <= ~clk_3;
            cnt_3 <= 27'b0;
        end
    end
    
    always @*
        cnt_3_tmp = cnt_3 + 1'b1;
    
    always @(posedge clk_1 or negedge rst_n)
    if(~rst_n)
        begin
            q_left <= {5'd0, 5'd0, 5'd0, 5'd0, 5'd6, 5'd7, 5'd15, 5'd0, 5'd8, 5'd11, 5'd0, 5'd9, 5'd11, 5'd0, 5'd9, 5'd0,
                       5'd8, 5'd0, 5'd6, 5'd4, 5'd0, 5'd4, 5'd1, 5'd16, 5'd2, 5'd5, 5'd0, 5'd2, 5'd5, 5'd0, 5'd2, 5'd5,
                       5'd5, 5'd0, 5'd0, 5'd0, 5'd0, 5'd5, 5'd18, 5'd17, 5'd3, 5'd8, 5'd0, 5'd3, 5'd8, 5'd0, 5'd19, 5'd0,
                       5'd7, 5'd0, 5'd5, 5'd3, 5'd0, 5'd1, 5'd15, 5'd14, 5'd21, 5'd1, 5'd4, 5'd2, 5'd2, 5'd4, 5'd7, 5'd0,
                       5'd5, 5'd7, 5'd20, 5'd8, 5'd8, 5'd6, 5'd7, 5'd19, 5'd8, 5'd11, 5'd0, 5'd9, 5'd11, 5'd0, 5'd9, 5'd0,
                       5'd11, 5'd0, 5'd9, 5'd8, 5'd0, 5'd6, 5'd7, 5'd8, 5'd19, 5'd12, 5'd0, 5'd10, 5'd12, 5'd0, 5'd10, 5'd9,
                       5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd11, 5'd10, 5'd20, 5'd9, 5'd10, 5'd0, 5'd9, 5'd10, 5'd0, 5'd11, 5'd0,
                       5'd13, 5'd11, 5'd9, 5'd8, 5'd0, 5'd9, 5'd8, 5'd0, 5'd15, 5'd9, 5'd11, 5'd13, 5'd0, 5'd11, 5'd12, 5'd0};
                       
            q_right <= {5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd5, 5'd0, 5'd7, 5'd0, 5'd2, 5'd0, 5'd7, 5'd0,
                        5'd5, 5'd0, 5'd7, 5'd0, 5'd2, 5'd0, 5'd7, 5'd0, 5'd6, 5'd0, 5'd12, 5'd0, 5'd3, 5'd0, 5'd8, 5'd0,
                        5'd6, 5'd0, 5'd11, 5'd0, 5'd14, 5'd0, 5'd3, 5'd0, 5'd2, 5'd0, 5'd8, 5'd0, 5'd4, 5'd0, 5'd8, 5'd0,
                        5'd6, 5'd0, 5'd8, 5'd0, 5'd2, 5'd0, 5'd8, 5'd0, 5'd5, 5'd0, 5'd7, 5'd0, 5'd1, 5'd0, 5'd3, 5'd0,
                        5'd13, 5'd0, 5'd10, 5'd0, 5'd9, 5'd0, 5'd10, 5'd0, 5'd5, 5'd0, 5'd7, 5'd0, 5'd2, 5'd0, 5'd7, 5'd0,
                        5'd5, 5'd0, 5'd7, 5'd0, 5'd2, 5'd0, 5'd7, 5'd0, 5'd6, 5'd0, 5'd12, 5'd0, 5'd3, 5'd0, 5'd8, 5'd0,
                        5'd6, 5'd0, 5'd3, 5'd0, 5'd4, 5'd0, 5'd5, 5'd0, 5'd8, 5'd0, 5'd8, 5'd0, 5'd12, 5'd0, 5'd8, 5'd0,
                        5'd9, 5'd0, 5'd9, 5'd0, 5'd9, 5'd0, 5'd9, 5'd0, 5'd12, 5'd0, 5'd8, 5'd0, 5'd15, 5'd0, 5'd8, 5'd0};
                        
            q_light <= 2'b10;
        end
    else
        begin
            q_left <= { q_left[634:0], q_left[639:635]};
            q_right <= { q_right[634:0], q_right[639:635]};
            q_light <= { q_light[0], q_light[1]};
        end
        
    always @(posedge clk_3 or negedge rst_n)
    if(~rst_n)
        begin
            q_dead <= {4'd0, 4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3,
                   4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd3, 4'd0, 4'd0, 4'd0,
                   4'd0, 4'd0, 4'd4, 4'd0, 4'd4, 4'd0, 4'd4, 4'd0, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2,
                   4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0,
                   4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd0, 4'd6, 4'd0, 4'd6, 4'd0, 4'd6, 4'd0, 4'd0, 4'd9, 4'd0, 4'd9, 4'd0, 4'd9, 4'd0, 4'd7, 4'd7, 4'd7, 4'd7,
                   4'd7, 4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd0, 4'd6, 4'd0, 4'd6, 4'd0, 4'd6, 4'd0, 4'd0, 4'd10, 4'd0, 4'd10, 4'd0, 4'd10, 4'd0, 4'd8, 4'd8, 4'd8, 4'd8,
                   4'd8, 4'd0, 4'd11, 4'd0, 4'd11, 4'd0, 4'd10, 4'd0, 4'd9, 4'd9, 4'd9, 4'd9, 4'd9, 4'd0, 4'd11, 4'd0, 4'd11, 4'd0, 4'd10, 4'd0, 4'd9, 4'd9, 4'd9, 4'd9,
                   4'd9, 4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd5, 4'd0, 4'd3, 4'd0, 4'd0, 4'd0, 4'd0, 4'd1, 4'd0, 4'd0, 4'd0, 4'd0, 4'd5, 4'd0, 4'd0, 4'd0, 4'd0,
                   4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5,
                   4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd0, 4'd0, 4'd0};
        end
    else
        begin
            q_dead <= { q_dead[771:0], q_dead[775:772]};
        end
            
    always @*
    begin
        note_left = q_left[639:635];
        note_right = q_right[639:635];
        note_light = q_light[1];
        note_dead = q_dead[775:772];
    end

    always @*
    begin
        if(dead)
        begin
            case(note_dead)
                4'd0: 
                begin
                    out_note_left = 22'd0;
                    out_note_right = 22'd0;
                end
                4'd1:
                begin
                    out_note_left = 22'd227272;
                    out_note_right = 22'd227272;
                end
                4'd2: 
                begin
                    out_note_left = 22'd202478;
                    out_note_right = 22'd202478;
                end
                4'd3:
                begin
                    out_note_left = 22'd191571;
                    out_note_right = 22'd191571;
                end
                4'd4:
                begin
                    out_note_left = 22'd170648;
                    out_note_right = 22'd170648;
                end
                4'd5: 
                begin
                    out_note_left = 22'd151515;
                    out_note_right = 22'd151515;
                end
                4'd6: 
                begin
                    out_note_left = 22'd143266;
                    out_note_right = 22'd143266;
                end
                4'd7:
                begin
                    out_note_left = 22'd113636;
                    out_note_right = 22'd113636;
                end
                4'd8:
                begin
                    out_note_left = 22'd101215;
                    out_note_right = 22'd101215;
                end
                4'd9:
                begin
                    out_note_left = 22'd95420;
                    out_note_right = 22'd95420;
                end
                4'd10:
                begin
                    out_note_left = 22'd85034;
                    out_note_right = 22'd85034;
                end
                4'd11:
                begin
                    out_note_left = 22'd75758;
                    out_note_right = 22'd75758;
                end
                default:
                begin
                    out_note_left = 22'd0;
                    out_note_right = 22'd0;
                end
            endcase
        end
        else if(light)
        begin 
            if(note_light)
                out_note_right = 22'd95420;
            else
                out_note_right = 22'd0;
                    case(note_left)
                    5'd0: out_note_left = 22'd0;
                    5'd1: out_note_left = 22'd255102;
                    5'd2: out_note_left = 22'd227272;
                    5'd3: out_note_left = 22'd202478;
                    5'd4: out_note_left = 22'd191571;
                    5'd5: out_note_left = 22'd170648;
                    5'd6: out_note_left = 22'd151515;
                    5'd7: out_note_left = 22'd143266;
                    5'd8: out_note_left = 22'd127551;
                    5'd9: out_note_left = 22'd113636;
                    5'd10: out_note_left = 22'd101215;
                    5'd11: out_note_left = 22'd95420;
                    5'd12: out_note_left = 22'd85034;
                    5'd13: out_note_left = 22'd75758;
                    5'd14: out_note_left = 22'd303380;
                    5'd15: out_note_left = 22'd270270;
                    5'd16: out_note_left = 22'd240790;
                    5'd17: out_note_left = 22'd202478;
                    5'd18: out_note_left = 22'd180388;
                    5'd19: out_note_left = 22'd135139;
                    5'd20: out_note_left = 22'd107259;
                    5'd21: out_note_left = 22'd303380;
                    default: out_note_left = 22'd0;
                endcase      
        end
        else
        begin
            case(note_right)
                5'd0: out_note_right = 22'd0;
                5'd1: out_note_right = 22'd1145475;
                5'd2: out_note_right = 22'd1020408;
                5'd3: out_note_right = 22'd909091;
                5'd4: out_note_right = 22'd809848;
                5'd5: out_note_right = 22'd764409;
                5'd6: out_note_right = 22'd681013;
                5'd7: out_note_right = 22'd606722;
                5'd8: out_note_right = 22'd572672;
                5'd9: out_note_right = 22'd510204;
                5'd10: out_note_right = 22'd341577;
                5'd11: out_note_right = 22'd721501;
                5'd12: out_note_right = 22'd540541;
                5'd13: out_note_right = 22'd429037;
                5'd14: out_note_right = 22'd809848;
                5'd15: out_note_right = 22'd606722;
                default: out_note_right = 22'd0;
            endcase
                    case(note_left)
                5'd0: out_note_left = 22'd0;
                5'd1: out_note_left = 22'd255102;
                5'd2: out_note_left = 22'd227272;
                5'd3: out_note_left = 22'd202478;
                5'd4: out_note_left = 22'd191571;
                5'd5: out_note_left = 22'd170648;
                5'd6: out_note_left = 22'd151515;
                5'd7: out_note_left = 22'd143266;
                5'd8: out_note_left = 22'd127551;
                5'd9: out_note_left = 22'd113636;
                5'd10: out_note_left = 22'd101215;
                5'd11: out_note_left = 22'd95420;
                5'd12: out_note_left = 22'd85034;
                5'd13: out_note_left = 22'd75758;
                5'd14: out_note_left = 22'd303380;
                5'd15: out_note_left = 22'd270270;
                5'd16: out_note_left = 22'd240790;
                5'd17: out_note_left = 22'd202478;
                5'd18: out_note_left = 22'd180388;
                5'd19: out_note_left = 22'd135139;
                5'd20: out_note_left = 22'd107259;
                5'd21: out_note_left = 22'd303380;
                default: out_note_left = 22'd0;
            endcase
        end
    end
        
endmodule

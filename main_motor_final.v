`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dankook
// Engineer: Hosung
// 
// Create Date: 2023/06/04 15:58:05
// Design Name: 
// Module Name: main_motor
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

module main_motor(
        output move_motor_A, move_motor_B,
        output reg moving_check = 0,
        input [1:0] move_encoder,
        input signed [31:0] floor_move_cnt,
        input move_stop_start, move_clk
    );
    parameter floor_length = 32'd7000;
    
    reg signed [31:0] goal_encoder_data = 0;
    wire [31:0] current_encoder_data;
    reg [31:0] move_pwm = 0;
    reg move_dir = 0, move_brake = 1;
    
    get_encoder_data motor_encoder( .encoder_data(current_encoder_data),
                                    .encoder_reset(0),
                                    .encoder_clk(move_clk),
                                    .encoder_state(move_encoder));
    
    motor_ctrl mt_ctrl( .motor_A(move_motor_A), 
                        .motor_B(move_motor_B),
                        .motor_pwm(move_pwm),
                        .motor_dir(move_dir), 
                        .motor_brake(move_brake), 
                        .motor_clk(move_clk));

    reg [31:0] move_distance;
        
    always@(posedge move_clk) begin
        if(move_stop_start == 1)
            if(moving_check == 0) begin
                goal_encoder_data = goal_encoder_data + (floor_move_cnt * floor_length);
                moving_check <=1;
            end
        move_distance =  current_encoder_data - goal_encoder_data;
        if(move_distance > 32'hFFFF + 32'd500) begin
            move_pwm <= 32'd1000;
            move_brake <= 0;
            move_dir <= 0;
            moving_check = 1;
        end
        else if(move_distance < 32'hFFFF - 32'd500) begin
            move_pwm <= 32'd1000;
            move_brake <= 0;
            move_dir <= 1;
            moving_check = 1;
        end
        else if(move_distance > 32'hFFFF + 32'd100) begin
            move_pwm <= 32'd600;
            move_brake <= 0;
            move_dir <= 0;
            moving_check = 1;
        end
        else if(move_distance < 32'hFFFF - 32'd100) begin
            move_pwm <= 32'd600;
            move_brake <= 0;
            move_dir <= 1;
            moving_check = 1;
        end
        else if(move_distance > 32'hFFFF + 10'd10) begin
            move_pwm <= 32'd380;
            move_brake <= 0;
            move_dir <= 0;
            moving_check = 1;
        end
        else if(move_distance < 32'hFFFF - 10'd10) begin
            move_pwm <= 32'd380;
            move_brake <= 0;
            move_dir <= 1;
            moving_check = 1;
        end
        else begin
            move_pwm <= 32'd0;
            move_brake <= 1;
            moving_check = 0;
        end
    end
endmodule

module pwm_generator( 
    output reg      pwm_state,
    input  [31:0]   pwm_period, pwm_cc, pwm_clk
    );

    reg [31:0] count = 0;
    
    always @(posedge pwm_clk) begin
        if(count >= pwm_period) 
            count <= 32'b0;
        else
            count <= count + 32'b1;

        if(count <= pwm_cc)
            pwm_state <= 1'b1;
        else
            pwm_state <= 1'b0;

    end
endmodule

module get_encoder_data(
    output reg [31:0] encoder_data = 32'hFFFF,
    input encoder_reset,
    input encoder_clk,
    input [1:0] encoder_state
    );
    reg [1:0] n_state;

    always@(posedge encoder_clk)
        if(encoder_reset == 1'b1)
            encoder_data[15:0] = 0;
        else
            case(encoder_state)
            2'b00 : begin if(n_state == 10)        encoder_data = encoder_data - 1;
                    else if(n_state == 01)   encoder_data = encoder_data + 1;
                    n_state = 2'b00;end
            2'b10 : begin if(n_state == 11)        encoder_data = encoder_data - 1;
                    else if(n_state == 00)   encoder_data = encoder_data + 1;
                    n_state = 2'b10;end
            2'b11 : begin if(n_state == 01)        encoder_data = encoder_data - 1;
                    else if(n_state == 10)   encoder_data = encoder_data + 1;
                    n_state = 2'b11;end
            2'b01 : begin if(n_state == 00)        encoder_data = encoder_data - 1;
                    else if(n_state == 11)   encoder_data = encoder_data + 1;
                    n_state = 2'b01; end
           endcase
    
endmodule

module motor_ctrl( 
    output              motor_A, motor_B,
    input  [31:0]       motor_pwm,
    input               motor_dir, motor_brake, motor_clk
    );
    reg [31:0] motor_pwm_A, motor_pwm_B;
    pwm_generator pwmA( .pwm_state(motor_A),
                        .pwm_period(32'd1000), 
                        .pwm_cc(motor_pwm_A), 
                        .pwm_clk(motor_clk));

    pwm_generator pwmB( .pwm_state(motor_B),
                        .pwm_period(32'd1000), 
                        .pwm_cc(motor_pwm_B), 
                        .pwm_clk(motor_clk));
                        
    always @(motor_pwm, motor_dir, motor_brake) begin
        if(motor_brake) begin
            motor_pwm_A <= 0;
            motor_pwm_B <= 0;
        end
        else begin
            if(motor_dir == 1'b0) begin
                motor_pwm_A <= motor_pwm;
                motor_pwm_B <= 0;
            end
            else begin
                motor_pwm_A <= 0;
                motor_pwm_B <= motor_pwm;
            end
        end
    end
endmodule

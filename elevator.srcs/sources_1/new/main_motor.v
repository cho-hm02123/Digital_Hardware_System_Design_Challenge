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
    output [15:0] led,
    input [15:0] sw,
    inout [3:0] JB,
    input btnC, btnU, btnL, btnR, btnD,
    input clk
    );
//    reg [15:0] led_buff;
//    assign led = led_buff;
    // pwm_generator pwm0( .pwm_state(led[0]),
    //                     .pwm_period(32'd1000), 
    //                     .pwm_cc(32'd200), 
    //                     .pwm_clk(clk));
    
    // get_encoder_data(   .encoder_data(led),
    //                     .encoder_reset(sw[15]),
    //                     .encoder_clk(clk),
    //                     .encoder_state(JB[3:2]));
    
    // reg [31:0] elevator_pwm = 0;
    // reg elevator_dir = 0, elevator_brake = 1;
    
    // motor_ctrl mt_ctrl( .motor_A(JB[0]), 
    //                     .motor_B(JB[1]),
    //                     .motor_pwm(elevator_pwm),
    //                     .motor_dir(elevator_dir), 
    //                     .motor_brake(elevator_brake), 
    //                     .motor_clk(clk));

    reg signed [31:0]elveator_move_cnt = 0;
    reg elveator_move_flg = 0;
    wire elveator_move_check;

    move_stop move_s(
        .move_motor_A(JB[0]),
        .move_motor_B(JB[1]),
        .moving_check(elveator_move_check),
        .move_encoder(JB[3:2]),
        .floor_move_cnt(elveator_move_cnt),
        .move_stop_start(elveator_move_flg), 
        .move_clk(clk),
        .led_test(led)
    );

    always@(posedge clk) begin
        if(elveator_move_check == 1) begin
            elveator_move_flg <= 0;
        end
        else begin
            if(btnU == 1)begin
                elveator_move_cnt = 32'd1;
                elveator_move_flg <= 1;
//                led_buff[0] = 1'b1;
            end
            if(btnD == 1)begin
                elveator_move_cnt = -32'd1;
                elveator_move_flg <= 1;
                //led_buff[1] = 1'b1;
            end
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
            2'b00 : begin if(n_state == 10)        encoder_data = encoder_data + 1;
                    else if(n_state == 01)   encoder_data = encoder_data - 1;
                    n_state = 2'b00;end
            2'b10 : begin if(n_state == 11)        encoder_data = encoder_data + 1;
                    else if(n_state == 00)   encoder_data = encoder_data - 1;
                    n_state = 2'b10;end
            2'b11 : begin if(n_state == 01)        encoder_data = encoder_data + 1;
                    else if(n_state == 10)   encoder_data = encoder_data - 1;
                    n_state = 2'b11;end
            2'b01 : begin if(n_state == 00)        encoder_data = encoder_data + 1;
                    else if(n_state == 11)   encoder_data = encoder_data - 1;
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

module move_stop(
        output move_motor_A, move_motor_B,
        output reg moving_check = 0,
        input [1:0] move_encoder,
        input signed [31:0] floor_move_cnt,
        input move_stop_start, move_clk,
        output [15:0] led_test
    );
    parameter floor_length = 32'd8000;
    
    reg signed [31:0] goal_encoder_data = 0;
    wire [31:0] current_encoder_data;
    reg [31:0] move_pwm = 0;
    reg move_dir = 0, move_brake = 1;
    
    assign led_test = goal_encoder_data[24:9];
    
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
        else if(move_distance > 32'hFFFF + 32'd10) begin
            move_pwm <= 32'd380;
            move_brake <= 0;
            move_dir <= 0;
            moving_check = 1;
        end
        else if(move_distance < 32'hFFFF - 32'd10) begin
            move_pwm <= 32'd380;
            move_brake <= 0;
            move_dir <= 1;
            moving_check = 1;
        end
        else begin
            move_pwm <= 32'd1;
            move_brake <= 1;
            moving_check = 0;
        end
    end
endmodule
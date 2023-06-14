`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: dankook univ
// Engineer: 
// 
// Create Date: 2023/06/11 16:54:13
// Design Name: 
// Module Name: door_control
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


module door_control(
    input clk,                      //클럭
    input door_open,                //문열림 상태 변수
    input [3:0] present_floar,      //현재 층수 변수
    input [3:0] set_floar,          //목표 층수 변수
    input [0:0] block_open,         //문닫힘 상태 변수
    output reg [3:0] JC             //pmod 제어
);

    // Setting Counter
    reg [20:0] counter;             //counter 사용 변수
    reg [1:0] servo_state;          //서보모터 출력 변수
    reg [16:0] control = 0;
    reg toggle = 1;
    
    always @(posedge clk) begin
        if(door_open == 1 && block_open == 0)               //문 열림 버튼 작동
            begin
                counter <= counter + 1;                     //counter
                if(counter == 'd999999)
                    counter <= 0;
                if(counter < ('d100000 + control)) begin
                    if(present_floar == 4'b0001)            //현재 1층
                        JC <= 4'b0001;                      //1층 문 서보모터 작동
                    else if(present_floar == 4'b0010)       //현재 2층
                        JC <= 4'b0010;                      //2층 문 서보모터 작동
                    else if(present_floar == 4'b0011)       //현재 3층
                        JC <= 4'b0100;                      //3층 문 서보모터 작동
                    else if(present_floar == 4'b0100)       //현재 4층
                        JC <= 4'b1000;                      //4층 문 서보모터 작동
                    end   
                else
                    JC <= 0;
                    
                if(control == 'd100000)
                    toggle <= 0;

                if(counter == 0)
                    begin
                        if(toggle == 1)
                            control <= control + 500;
                    end
            end
 
         
        if(block_open == 1)                                 //문 닫힘 버튼 작동
            begin
                counter <= counter + 1;
                if(counter == 'd999999)
                    counter <= 0;
                if(counter < ('d100000 + control))begin
                    if(present_floar == 4'b0001)            //현재 1층
                        JC <= 4'b0001;                      //1층 문 서보모터 작동
                    else if(present_floar == 4'b0010)       //현재 2층
                        JC <= 4'b0010;                      //2층 문 서보모터 작동
                    else if(present_floar == 4'b0011)       //현재 3층
                        JC <= 4'b0100;                      //3층 문 서보모터 작동
                    else if(present_floar == 4'b0100)       //현재 4층
                        JC <= 4'b1000;                      //4층 문 서보모터 작동
                    end
                else
                    JC <= 0;
                    
                if(control == 'd100000)
                    toggle <= 0;
                if(control == 0)
                    toggle <= 1;
                if(counter == 0)
                    begin
                        if(toggle == 0)
                            control <= control - 500;
                    end
            end
        end
endmodule

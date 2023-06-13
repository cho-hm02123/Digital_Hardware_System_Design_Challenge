`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
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
    input clk,
    input btnL,btnR,
    output reg [0:0] led,
    output reg [0:0] JA
);

    // Setting Counter
    reg [20:0] counter;
    reg servo_reg;
    reg [1:0] servo_state;
    reg [16:0] control = 0;
    reg toggle = 1;
    
    always @(posedge clk) begin
        if(btnL == 1)
            begin
                counter <= counter + 1;
                if(counter == 'd999999)
                    counter <= 0;
                if(counter < ('d100000 + control))
                    JA[0] <= 1;
                else
                    JA[0] <= 0;
                    
                if(control == 'd100000)
                    toggle <= 0;
//                if(control == 0)
//                    toggle <= 1;
                if(counter == 0)
                    begin
                        if(toggle == 1)
                            control <= control + 500;
                    end
            end
         
        if(btnR == 1)
            begin
                counter <= counter + 1;
                if(counter == 'd999999)
                    counter <= 0;
                if(counter < ('d100000 + control))
                    JA[0] <= 1;
                else
                    JA[0] <= 0;
                    
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

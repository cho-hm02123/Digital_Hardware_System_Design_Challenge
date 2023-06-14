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
    output reg [0:0] JA
);

    /* 100 MHz Clock on Board  -> transfer to time : 10 ns
     20 ms Counter -> Output 20 ms using the Counter 
     Then 20 ms = 20,000,000 ns 
     20,000,000 ns / 10 ns = 2,000,000  -> 21bit required
     Therefore, Counter needs 21 bits [20:0]
     So Count up 0 to 1,999,999
     
     We use SG-90 180 Degree Servo So,
     Assumed Max (180 Deg) 2 ms                   = clks * 10 ns -> clks = 200,000
     Assumed Min (0   Deg) 1 ms                   = clks * 10 ns -> clks = 100,000
     Positions 200,000 - 100,000                 = 100,000       -> Consist of 10,000 Position From 0 ~ 180 Deg
     ReSolution (180 Deg) / (100,000 (Positions))    = 0.0018 Degree
*/
    
    // Setting Counter
    reg [20:0] counter;
    reg servo_reg;
    reg [1:0] servo_state;
    reg [16:0] control = 0;
    reg toggle = 1;                                         // Determinig the Direction (Clockwise, Counterclockwise)
    
    always @(posedge clk) begin
        if(btnL == 1)                                       // Open the door
            begin
                counter <= counter + 1;                     // Increase the servo angle while increasing the counter
                if(counter == 'd999999)                     // Cause 999,999 is Maximum, reset counter
                    counter <= 0;
                if(counter < ('d100000 + control))          // Adjust the duty ratio of the PWM
                    JA[0] <= 1;
                else
                    JA[0] <= 0;
                    
                if(control == 'd100000)                     // Use toggle to control direction
                    toggle <= 0;                            // Clockwise relative to the line facing down
                if(control == 0)
                    toggle <= 1;                            // Counterclockwise with respect to the line facing down
                if(counter == 0)
                    begin
                        if(toggle == 1)
                            control <= control + 500;       // Use control to control speed
                    end
            end
         
        if(btnR == 1)                                       // Close the door
            begin                                           // he same as above
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

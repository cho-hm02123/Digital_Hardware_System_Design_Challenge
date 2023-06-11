`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/04 23:37:59
// Design Name: 
// Module Name: door_controller_tb
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


module door_controller_tb(

    );
    reg [7:0] switches;
    wire [7:0] leds;
    
    integer i;
    
    door_controller door(.led(leds),.swt(switches));
    
    initial
    begin
        switches = 0;
        #100
        switches[0] = 1;
        #100
        switches[1] = 1;
        #100
        switches[2] = 1;
        #100
        switches[3] = 1;
        #100
        switches[4] = 1;
        #100
        switches[5] = 1;
        #100
        switches[6] = 1;
        #100
        switches[7] = 1;
    end
endmodule


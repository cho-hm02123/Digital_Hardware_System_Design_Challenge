//////////////////////////////////////////////////////////////////////////////////
// Company: Dankook Univ.
// Engineer: Kim Hyunwook, Kim sumin
// 
// Create Date: 2023/06/14
// Design Name: 
// Module Name: elevator
// Project Name: elevator
// Target Devices: Basys 3
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
module elevator(clk, open_btn, close_btn, seg, an, JA, JB, JC);

input clk;
input [0:0] open_btn, close_btn;
inout [7:0] JA;
inout [3:0] JB;
inout [3:0] JC;

output reg[6:0] seg;
output reg[3:0] an;
reg[0:0] door_open = 1'b0;
reg[3:0] present_floar = 4'b0001;
reg[3:0] set_floar;
wire[3:0] goal_floar;
wire signed [31:0] floor_move;
reg[0:0] block_open;
//reg[3:0] close;

//assign JC = close;

assign floor_move = set_floar - present_floar;

pmod_keypad keypad(
        .clk(clk), 
        .col(JA[3:0]), 
        .row(JA[7:4]), 
        .key(goal_floar)
    );
    
    
    door_control door(
    .clk(clk),
    .door_open(door_open),
    .present_floar(present_floar),
    .set_floar(set_floar),
    .block_open(block_open),
    .JC(JC)
);
    
wire moving_cleck_e; //0 stop
reg move_stop_start_e = 0;

main_motor mt(
        .move_motor_A(JB[0]), .move_motor_B(JB[1]),
        .moving_check(moving_cleck_e),
        .move_encoder(JB[3:2]),
        .floor_move_cnt(floor_move),
        .move_stop_start(move_stop_start_e), .move_clk(clk)
    );


always@(posedge clk)
begin
    
    if(moving_cleck_e != 1)
        block_open <= 1'b0;
    
    else if(moving_cleck_e)
        move_stop_start_e <= 0;
      
    
    if(open_btn == 1 && block_open == 0)
    begin
        door_open <= 1'b1;
        present_floar <= set_floar;
    end
    
    else if(close_btn)  //door close
    begin
        door_open <= 1'b0;
        move_stop_start_e <= 1'b1;
        block_open <= 1'b1;
    end
    
    if(door_open == 1)
    begin
        an <= 4'b1011;
    end
    
    else if(door_open == 0)
    begin
        an <= 4'b1110;
    end
    
end

always@(door_open)
begin
    if(door_open == 1)
    begin
        case(goal_floar)
            4'h1:begin                      
                          seg[6:0] <= 7'b1111001;
                          set_floar <= 4'b0001;
                 end
                          
            4'h2:begin                          
                          seg[6:0] <= 7'b0100100;
                          set_floar <= 4'b0010;
                 end
            4'h3:begin                         
                          seg[6:0] <= 7'b0110000;
                          set_floar <= 4'b0011;
                 end
                 
            4'h4:begin                          
                          seg[6:0] <= 7'b0011001;
                          set_floar <= 4'b0100;
                 end
                 
            default:begin
                          seg[6:0] <= 7'b0001001;
                          set_floar <= 4'b0001;
                    end
                    
        endcase
            
     end
 end

endmodule

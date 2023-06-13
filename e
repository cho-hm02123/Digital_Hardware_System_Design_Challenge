module e(clk, open_btn, close_btn, seg, an, JA, JB, JC);

input clk;
input [0:0] open_btn, close_btn;
inout [7:0] JA;
inout [3:0] JB;
inout [0:0] JC;

output reg[6:0] seg;
output reg[3:0] an;
reg[0:0] door_open = 1'b0;
reg[3:0] present_floar = 4'b0001;
wire[3:0] goal_floar;

pmod_keypad keypad(
        .clk(clk), 
        .col(JA[3:0]), 
        .row(JA[7:4]), 
        .key(goal_floar)
    );
    
door_control door(
        .clk(clk),
        .btnL(door_open),
        .btnR(door_open),
        .JC(JC)
    );


always@(posedge clk)
begin
    if(open_btn)
    begin
        door_open <= 1'b1;
    end
    
    else if(close_btn)
    begin
        door_open <= 1'b0;
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
                          present_floar <= 4'b0001;
                 end
                          
            4'h2:begin                          
                          seg[6:0] <= 7'b0100100;
                          present_floar <= 4'b0010;
                 end
            4'h3:begin                         
                          seg[6:0] <= 7'b0110000;
                          present_floar <= 4'b0011;
                 end
                 
            4'h4:begin                          
                          seg[6:0] <= 7'b0011001;
                          present_floar <= 4'b0100;
                 end
                 
            default:begin
                          seg[6:0] <= 7'b0001001;
                          present_floar <= 4'b0001;
                    end
                    
        endcase
        
 end
 end

endmodule

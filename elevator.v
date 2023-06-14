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

input clk;                                      //메인 클럭
input [0:0] open_btn, close_btn;                //열림 버튼과 닫힘 버튼 변수
inout [7:0] JA;                                 //pmod 제어
inout [3:0] JB;                                 //pmod 제어
inout [3:0] JC;                                 //pmod 제어

output reg[6:0] seg;                            //7-segment 제어
output reg[3:0] an;                             //7-segment 제어
reg[0:0] door_open = 1'b0;                      //문열림 상태 판단 변수
reg[3:0] present_floar = 4'b0001;               //현재 층 저장 변수
reg[3:0] set_floar;                             //목표 층 저장 변수
wire[3:0] goal_floar;                           //keypad 출력 값
wire signed [31:0] floor_move;                  //motor 제어의 입력으로 쓰이는 움직여야하는 층 수
reg[0:0] block_open;                            //motor 동작 중 열림 버튼 제어 변수
assign floor_move = set_floar - present_floar;  //motor 제어의 입력으로 쓰이는 움직여야하는 층 수

pmod_keypad keypad(                             //keypad 모듈 instance
        .clk(clk), 
        .col(JA[3:0]), 
        .row(JA[7:4]), 
        .key(goal_floar)
    );
    
    
door_control door(                              //문 제어 모듈 instancd
    .clk(clk),
    .door_open(door_open),
    .present_floar(present_floar),
    .set_floar(set_floar),
    .block_open(block_open),
    .JC(JC)
);
    
wire moving_cleck_e;                            //모터의 작동 상태 0 : stop
reg move_stop_start_e = 0;                      //모터 시작 제어 변수

main_motor mt(                                  //모터 제어 모듈 instance
        .move_motor_A(JB[0]), .move_motor_B(JB[1]),
        .moving_check(moving_cleck_e),
        .move_encoder(JB[3:2]),
        .floor_move_cnt(floor_move),
        .move_stop_start(move_stop_start_e), .move_clk(clk)
    );


always@(posedge clk)
begin
    
    if(moving_cleck_e != 1)                     //모터 동작을 멈췄을 때
        block_open <= 1'b0;                     //motor 동작 중 열림 버튼 제어 변수 초기화
    
    else if(moving_cleck_e)                     //모터 동작 중
        move_stop_start_e <= 0;                 //모터 동작 trriger 초기화
      
    
    if(open_btn == 1 && block_open == 0)        //모터 동작을 안할 때 열림 버튼을 눌렀을 때
    begin
        door_open <= 1'b1;                      //문열림 변수
        present_floar <= set_floar;             //현재 층 저장
    end
    
    else if(close_btn)                          //닫힘 버튼을 눌렀을 때
    begin
        door_open <= 1'b0;                      //문열림 변수
        move_stop_start_e <= 1'b1;              //모터 동작 trriger
        block_open <= 1'b1;                     //동작 중 열림 버튼 방지를 위한 
    end
    
    if(door_open == 1)                          //문이 열려있을 때
    begin
        an <= 4'b1011;                          //2번째 7-segment에 정보 표시
    end
    
    else if(door_open == 0)                     //문이 닫혀있을 때
    begin
        an <= 4'b1110;                          //4번째 7-segment에 정보 표시
    end
    
end

always@(door_open)                                      //문이 열렸을 때
begin
    if(door_open == 1)
    begin
       case(goal_floar)                                //keypad에서 받는 정보
            4'h1:begin                      
                    seg[6:0] <= 7'b1111001;       //1
                    set_floar <= 4'b0001;         //1층을 변수에 저장
                 end
                          
            4'h2:begin                          
                    seg[6:0] <= 7'b0100100;       //2
                    set_floar <= 4'b0010;         //2층을 변수에 저장
                 end
            4'h3:begin                         
                    seg[6:0] <= 7'b0110000;       //3
                    set_floar <= 4'b0011;         //3층을 변수에 저장
                 end
                 
            4'h4:begin                          
                    seg[6:0] <= 7'b0011001;       //4
                    set_floar <= 4'b0100;         //4층을 변수에 저장      
                 end
                 
            default:begin
                    seg[6:0] <= 7'b0001001;       //예외 처리. 이외 층수의 버튼을 누르면 X
                    set_floar <= 4'b0001;         //이외 층수의 버튼을 누르면 1층으로 설정
                    end
                    
        endcase
            
     end
 end

endmodule

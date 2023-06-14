module pmod_keypad(
    input clk,                //클럭
    input [3:0] row,          //열
    output reg [3:0] col,     //행
    output reg [3:0] key      //keypad 값
    );

   localparam BITS = 20;      //20비트로 구성된 카운터의 비트수를 나타내는 파라미터
   
   localparam ONE_MS_TICKS = 100000000 / 1000;     //1ms 클릭틱수
    
   localparam SETTLE_TIME = 100000000 / 1000000;    //1us 입력신호 안정시간
    
    wire [BITS - 1 : 0] key_counter;            //keypad 입력신호의 시간 카운트
    reg rst = 1'b0;                             //카운터 초기화 reset
    
    counter_n #(.BITS(BITS)) counter(            //카운터 모듈
        .clk(clk),
        .rst(rst),
        .q(key_counter)
    );

    always @ (posedge clk)            
    begin
      case (key_counter)                //key_counter 값에 따라
            0:                          //0일 때
                rst <= 1'b0;            //rst
                
            ONE_MS_TICKS:               //ONE_MS_TICKS일 때
                col <= 4'b0111;         //keypad 첫번쩨 열

            ONE_MS_TICKS + SETTLE_TIME: //안정시간 지나면
            begin
                case (row)
                    4'b0111:
                        key <= 4'b0001; // key값 1
                    4'b1011:
                        key <= 4'b0100; // key값 4
                    4'b1101:
                        key <= 4'b0111; // key값 7
                    4'b1110:
                        key <= 4'b0000; // key값 0
                endcase
            end
            
            2 * ONE_MS_TICKS:           //2ms 지나면
                col <= 4'b1011;         //두번째 열
            
            2 * ONE_MS_TICKS + SETTLE_TIME:
            begin
                case (row)
                    4'b0111:
                        key <= 4'b0010; // key값 2
                    4'b1011:
                        key <= 4'b0101; // key값 5
                    4'b1101:
                        key <= 4'b1000; // key값 8
                    4'b1110:
                        key <= 4'b1111; // key값 F
                endcase
            end

            3 * ONE_MS_TICKS:           //3ms 지나면
                col <= 4'b1101;

            3 * ONE_MS_TICKS + SETTLE_TIME:
            begin
                case (row)
                    4'b0111:
                        key <= 4'b0011; // key값 3
                    4'b1011:
                        key <= 4'b0110; // key값 6
                    4'b1101:
                        key <= 4'b1001; // key값 9
                    4'b1110:
                        key <= 4'b1110; // key값 E
                endcase
            end
            
            // 4ms
            4 * ONE_MS_TICKS:           //4ms 지나면
                col <= 4'b1110;         //4번째 열 선택
            
            4 * ONE_MS_TICKS + SETTLE_TIME:
            begin
                case (row)
                    4'b0111:
                        key <= 4'b1010; // key값 A
                    4'b1011:
                        key <= 4'b1011; // key값 B
                    4'b1101:
                        key <= 4'b1100; // key값 C
                    4'b1110:
                        key <= 4'b1101; // key값 D
                endcase

                // reset the counter                
                rst <= 1'b1;
            end     
        endcase
    end
    
endmodule

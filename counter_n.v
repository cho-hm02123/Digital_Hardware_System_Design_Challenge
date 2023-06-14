`timescale 1ns / 1ps

module counter_n                           
  # (BITS = 4)                            //매개변수 BITS를 4로 설정
    (
    input clk,
    input rst,
    output tick,
    output [BITS - 1 : 0] q
    );
    
  reg [BITS - 1 : 0] rCounter = 0;        //카운터 레지스터

    always @ (posedge clk, posedge rst)
      if (rst)                          //rst 활성화되면
            rCounter <= 0;              //rCounter 0으로 초기화
        else                            //그렇지 않으면
            rCounter <= rCounter + 1;   //1씩 증가

    assign q = rCounter;                //q 출력신호를 rCounter값에 연결
    
  assign tick = (rCounter == 2 ** BITS - 1) ? 1'b1 : 1'b0;  //tick 출력 신호 설정
        
endmodule

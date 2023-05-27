DATA SEGMENT
    IO8254A EQU 280H
    IO8251A EQU 2B8H
    IO8251B EQU 2B9H
DATA ENDS
STACK SEGMENT PARA STACK
          DB 256 DUP(0)
STACK ENDS
CODE SEGMENT
              ASSUME CS:CODE,DS:DATA,SS:STACK
    START:    
              MOV    AX,DATA
              MOV    DS,AX
              MOV    DX,IO8254A+3
              MOV    AL,00010110B                ;设置8254计数器0工作方式,低字节，8位，方式3，二进制
              OUT    DX,AL
              MOV    DX,IO8254A
              MOV    AL,52                       ;给8254计数器0送初值（波特率1200，因子16，计数初值52）
              OUT    DX,AL
              MOV    DX,IO8251B                  ;对8251进行初始化，输入3遍0
              MOV    AX,0
              MOV    CX,3
    reset8251:
              OUT    DX,AL
              PUSH   CX
              MOV    CX,40H                      ;向8251控制端口送40H,使其复位
              LOOP   $
              POP    CX
              LOOP   reset8251
              MOV    AL,40H
              OUT    DX,AL
              MOV    CX,40H
              LOOP   $
              MOV    AL,5AH
              OUT    DX,AL
              MOV    AL,27H
              OUT    DX,AL
    FOREVER:  
              MOV    DX,IO8251B                  ;从线路状态寄存器读状态
              IN     AL,DX
              TEST   AL,38H                      ;检测是否为00111000，即FE=1，帧格式错，OE=1，超越错，PE=1，奇偶错
              JNZ    ERROR                       ;传输线状态寄存器全部都是0
              TEST   AL,02H                      ;检测接受数据是否准备好了
              JNZ    RECEIVE                     ;等于0则表示数据没有准备好
              TEST   AL,01H                      ;数据没有准备好
              JNZ    send                        ;没有,则跳转等待
              JMP    FOREVER
    send:     
              MOV    AH,1                        ;检测键盘按下
              INT    16H
              JZ     FOREVER                     ;有键盘按下
              MOV    AH,0                        ;读键盘
              INT    16H
              MOV    DX,IO8251A                  ;将键盘的数据输出发送到缓冲器
              OUT    DX,AL
              CMP    AL,03H
              JZ     DONE
              MOV    DL,AL
              MOV    AH,02H
              INT    21H
              CMP    AL,0DH
              JNZ    FOREVER
              MOV    DL,0AH
              MOV    AH,02H
              INT    21H
              JMP    FOREVER
    RECEIVE:  
              MOV    DX,IO8251A                  ;接收数据
              IN     AL,DX
              AND    AL,7FH                      ;最高位为停止位
              CMP    AL,03H                      ;
              JZ     DONE
              MOV    DL,AL
              MOV    AH,02H
              INT    21H
              CMP    AL,0DH
              JNZ    FOREVER
              MOV    DL,0AH
              MOV    AH,02H
              INT    21H
              JMP    FOREVER
              CMP    AL,0DH
              JNZ    FOREVER
    ERROR:    
              MOV    DX,IO8251A
              IN     AL,DX
              MOV    DL,'?'
              MOV    AH,02H
              INT    21H
              JMP    FOREVER
    DONE:     
              MOV    AH,4CH
              INT    21H
CODE ENDS
END START

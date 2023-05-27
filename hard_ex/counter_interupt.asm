
DATAS SEGMENT
    ;�˴��������ݶδ���  
    LED DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
    SEC1 DB 0
    SEC2 DB 0
    MIN1 DB 0
    MIN2 DB 0
    MES DB 42H
    OLD_0A DW 0,0
    OLD_8259 DB 0
    P8259 EQU 20H
    P8255 EQU 288H
    P8253 EQU 280H

DATAS ENDS
    
        
STACKS SEGMENT STACK
    ;�˴������ջ�δ���
    DB 64 DUP(0)
    
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV AX,STACKS
    MOV SS,AX
    ;�˴��������δ���
    CLI
    MOV AL,00110110B
    MOV DX,P8253+3
    OUT DX,AL
    
    MOV AX,10000
    MOV DX,P8253
    OUT DX,AL
    MOV AL,AH    
    OUT DX,AL
    
    MOV AL,01110110B
    MOV DX,P8253+3
    OUT DX,AL
    
    MOV AX,100
    MOV DX,P8253+1
    OUT DX,AL
    MOV AL,AH
    OUT DX,AL

    
    PUSH ES
    PUSH BX
    MOV AL,0BH
    MOV AH,35H
    INT 21H
    MOV OLD_0A+2,ES
    MOV OLD_0A,BX
    POP BX
    POP ES
    PUSH DS
    MOV AL,0BH
    MOV AH,25H
    MOV DX,SEG INT_0A
    MOV DS,DX
    MOV DX,OFFSET INT_0A
    INT 21H
    POP DS
    

    
    IN AL,P8259+1
    MOV OLD_8259,AL
    AND AL,11110111B
    OUT P8259,AL
    STI

PLAY:
    MOV AH,00001110B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    LEA BX,LED
    MOV DL,SEC1
    MOV DH,0
    MOV SI,DX
    MOV AL,[BX][SI]
    MOV DX,P8255+1
    OUT DX,AL
    PUSH CX
    MOV CX,00100H

DELAY1:
    LOOP DELAY1
    POP CX
    MOV AH,00001111B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    MOV DL,SEC2
    MOV DH,0
    MOV SI,DX
    MOV AL,[BX][SI]
    MOV DX,P8255+1
    OUT DX,AL
    MOV AH,00001101B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    PUSH CX
    MOV CX,00100H
    
DELAY2:
    LOOP DELAY2
    POP CX
    MOV AH,00111111B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    MOV DL,MIN1
    MOV DH,0
    MOV SI,DX
    MOV AL,[BX][SI]
    MOV DX,P8255+1
    OUT DX,AL
    MOV AH,00001011B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    
    PUSH CX
    MOV CX,00100H    
DELAY3:
    LOOP DELAY3
    POP CX
    
    MOV AH,00111111B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    MOV DL,MIN2
    MOV DH,0
    MOV SI,DX
    MOV DX,P8255+1
    OUT DX,AL
    MOV AH,00000111B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    
    PUSH CX
    MOV CX,00100H  
DELAY4:
    LOOP DELAY4
    POP CX
    
    MOV AH,00001111B
    MOV AL,AH
    MOV DX,P8255+2
    OUT DX,AL
    
    JMP PLAY
    MOV AH,4CH
    INT 21H
    
INT_0A PROC NEAR
    CMP SEC1,9
    JZ INT1
    INC SEC1
    JMP EXIT
INT1:
    MOV SEC1,0
    INC SEC2
    CMP SEC2,6
    JNZ EXIT
    MOV SEC2,0
    INC MIN1
    CMP MIN1,10
    JNZ EXIT
    MOV MIN1,0
    INC MIN2
    CMP MIN2,6
    JNZ EXIT
    MOV MIN2,0
EXIT:
    MOV AL,20H
    OUT 20H,AL
    IRET
INT_0A ENDP


CODES ENDS
    END START

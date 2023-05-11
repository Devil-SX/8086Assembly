; Add
data segment
        msg  db "Please input number1:",0dh,0ah,"$"
        msg2 db "Please input number2:",0dh,0ah,"$"
        buf  db 14, ?, 14 dup("$")
        buf2 db 14, ?, 14 dup("$")
        sum  db 0dh, 15 dup("$")
        br   db 0dh,0ah,"$"
data ends

stack segment para stack
              dw 128 dup(0)
stack ends

code segment
                  assume ds:data, cs:code, ss:stack


add_char proc
        ; 入口参数Al,Bl,bp,SI,ah
        ; ah是上一次aaa后的状态寄存器
        ; 将AL和BL的数字字符串相加，并存在[bp+SI]中（字符串形式）
        ; 出口参数[bp+SI]
                  push   dx

                  sub    al,48
                  sub    bl,48
                  sahf
                  adc    al, bl
                  aaa
                  lahf
        ; 取个位
                  add    al,48
                  mov    ds:[bp+si], al
                 
                  pop    dx
                  ret
add_char endp

        start:    
        ; Initialize
                  mov    ax, data
                  mov    ds,ax

        ; Show msg1
                  mov    ah, 9
                  lea    dx, msg
                  int    21h

        ; Input1
                  mov    ah, 0ah
                  lea    dx, buf
                  int    21h
                  mov    ah, 9
                  lea    dx, br
                  int    21h

        ; Show msg2
                  mov    ah, 9
                  lea    dx, msg2
                  int    21h

        ; Input2
                  mov    ah, 0ah
                  lea    dx, buf2
                  int    21h
                  mov    ah, 9
                  lea    dx, br
                  int    21h

        ; Get Length of buf
                  lea    bx, buf+1
                  mov    cl, [bx]
                  xor    ch, ch

        ; Prepare for loop
                  lea    bx,buf+1
                  lea    bp,buf2+1
                  add    bx, cx
                  add    bp,cx

                  mov    si, cx
                  xor    ah,ah
        ; bx -> (End of)buf
        ; bp -> (End of)buf2
        ; cx -> Length of buf

        ; 开始循环
        loop_here:
                  push   bx
                  push   bp
                
        ; Get Value
                  mov    bl, [bx]
                  mov    al, ds:[bp]

        ; Set si, bp
                  lea    bp, sum

        ; Add
                  call   add_char

                  pop    bp
                  pop    bx

                  dec    bx
                  dec    bp
                  dec    si
                  loop   loop_here
        
        ; Deal Carry
                  sahf
                  jnc    not_carry
                  lea    bx, sum
                  mov    byte ptr [bx], '1'

        not_carry:
        ;Print Output
                  mov    ah, 9
                  lea    dx, sum
                  int    21h
                  lea    dx,br
                  int    21h


        ; Exit
                  mov    ah, 4ch
                  int    21h


code ends
end start
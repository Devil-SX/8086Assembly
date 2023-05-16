data segment
      msg1 db "Please input the first number (length<=10):",0dh,0ah,"$"
      msg2 db "Please input the second number (length<=10):",0dh,0ah,"$"
      buf1 db 20, ?, 20 dup("$")
      buf2 db 20, ?, 20 dup("$")
      sum  db 12 dup(0dh),0dh,0ah,"$"
      br   db 0dh,0ah,"$"
data ends


code segment
                    assume ds:data, cs:code
      start:        
      ; Initialize
                    mov    ax, data
                    mov    ds,ax

      ; Input1
                    lea    dx, msg1
                    push   dx
                    lea    dx, buf1
                    push   dx
                    call   far ptr input

      ; Input2
                    lea    dx, msg2
                    push   dx
                    lea    dx, buf2
                    push   dx
                    call   far ptr input

      ; Add String
                    lea    dx, buf1+2
                    push   dx
                    lea    dx, buf2+2
                    push   dx
                    lea    dx, sum
                    push   dx
                    call   far ptr add_string

      ; Display Sum
                    lea    dx, sum
                    mov    ah, 9
                    int    21h


      ; Exit
                    mov    ah, 4ch
                    int    21h


input proc far
      ; 两个参数: 1.提示字符串 2.缓冲区

      ; 使用的寄存器 ax, dx, bp

      ; 保存现场
                    push   ax
                    push   dx
                    push   bp

                    mov    ah, 9
                    mov    bp, sp
                    mov    dx, word ptr [bp+12]
                    int    21h

                    mov    ah, 0ah
                    mov    dx, word ptr [bp+10]
                    int    21h
                    mov    ah,9
                    lea    dx, br
                    int    21h

      ; 恢复现场
                    pop    bp
                    pop    dx
                    pop    ax

                    ret    4
input endp


add_string proc far
      ; 参数三个 操作数1, 操作数2, 目标地址
      ; 使用的寄存器 bp, si, di, ax, bx, cx, dx (7)

      ; 保护现场
                    push   bp
                    push   si
                    push   di
                    push   ax
                    push   bx
                    push   cx
                    push   dx
      
                    mov    bp, sp

                    mov    si, word ptr [bp+22]
                    mov    di, word ptr [bp+20]
                    mov    bx, word ptr [bp+18]
                    add    bx, 11

                    xor    ax, ax
                    mov    cx, 10
      add_char:     
                    mov    al,byte ptr [si]
                    mov    dl, byte ptr [di]

                    sub    al, 30h
                    sub    dl, 30h

                    sahf
                    adc    al, dl
                    aaa
                    lahf

                    add    al, 30h
                    mov    byte ptr [bx], al

                    inc    si
                    inc    di
                    dec    bx
                    loop   add_char

      ; 进位
                    sahf
                    jnc    add_not_carry
                    mov    byte ptr [bx], "1"
      add_not_carry:


      ; 恢复现场
                    pop    dx
                    pop    cx
                    pop    bx
                    pop    ax
                    pop    di
                    pop    si
                    pop    bp

                    ret    6
add_string endp

code ends
end start
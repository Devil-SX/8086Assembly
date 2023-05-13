data segment
  msg1     db "Please input the first number (length<=10):",0dh,0ah,"$"
  msg2     db "Please input the second number (length<=10):",0dh,0ah,"$"
  buf1     db 20, ?, 20 dup("$")
  buf2     db 20, ?, 20 dup("$")
  abs1     db 10 dup("0")
  abs2     db 10 dup("0")
  sum      db 12 dup(0dh),0dh,0ah,"$"
  op1      dw 0
  op2      dw 0
  same_n   db 0
  negative db 0
  invert   db 0
  br       db 0dh,0ah,"$"
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

  ; Exit
        mov    ah, 4ch
        int    21h


input proc far
  ; 两个参数: 1.提示字符串 2.缓冲区
  ; 使用的寄存器 ax, dx, bp(3)

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

code ends
end start
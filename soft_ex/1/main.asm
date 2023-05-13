data segment
       msg1               db "Please input the first number (length<=10):",0dh,0ah,"$"
       msg2               db "Please input the second number (length<=10):",0dh,0ah,"$"
       buf1               db 20, ?, 20 dup("$")
       buf2               db 20, ?, 20 dup("$")
       abs1               db ?,10 dup("0")
       abs2               db ?,10 dup("0")
       sum                db 12 dup(0dh),0dh,0ah,"$"
       first_negative     dw 0
       second_negative    dw 0
       same_n             dw 0
       if_abs_first_above dw 0
       br                 db 0dh,0ah,"$"
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

       ; Preprocess1
                       lea    dx, buf1
                       push   dx
                       lea    dx, abs1
                       push   dx
                       lea    dx, first_negative
                       push   dx
                       call   far ptr preprocess

       ; Preprocess1
                       lea    dx, buf2
                       push   dx
                       lea    dx, abs2
                       push   dx
                       lea    dx, second_negative
                       push   dx
                       call   far ptr preprocess

       ; Judge
                       lea    dx, abs1
                       push   dx
                       lea    dx, abs2
                       push   dx
                       lea    dx, if_abs_first_above
                       push   dx
                       call   far ptr judge_abs_above

       ; Preprocess all
                       mov    ax, first_negative
                       mov    cx, second_negative
                       xor    ax, cx
                       lea    di, same_n
                       mov    word ptr [di], ax
       

       ; If_same
                       lea    bx, same_n
                       mov    bx, word ptr [bx]
                       test   bx, 0FFFFh
                       jz     same_sign

                       lea    bx, if_abs_first_above
                       mov    bx, word ptr [bx]
                       test   bx, 0FFFFh
                       jnz     first_above
       ; second above
                       lea    dx, abs2+1
                       push   dx
                       lea    dx, abs1+1
                       push   dx
                       lea    dx, sum
                       push   dx
                       lea    si, second_negative
                       push   word ptr [si]
                       call   far ptr sub_string

                       jmp    output
       first_above:    
       ; first above
                       lea    dx, abs1+1
                       push   dx
                       lea    dx, abs2+1
                       push   dx
                       lea    dx, sum
                       push   dx
                       lea    si, first_negative
                       push   word ptr [si]
                       call   far ptr sub_string

                       jmp    output
       same_sign:      
                       lea    dx, abs1+1
                       push   dx
                       lea    dx, abs2+1
                       push   dx
                       lea    dx, sum
                       push   dx
                       lea    si, first_negative
                       push   word ptr [si]
                       call   far ptr add_string
       output:         

                       lea    dx, sum
                       mov    ah, 9
                       int    21h

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


preprocess proc far
       ; 三个参数: 1.缓冲区; 2.存储区; 3.标志区
       ; 使用寄存器 bp, si, di, dx, cx , bx(6)


       ; 保护现场
                       push   bp
                       push   si
                       push   di
                       push   dx
                       push   cx
                       push   bx


                       mov    bp, sp

                       mov    si, word ptr [bp+20]          ; si->缓冲区地址
                       mov    di, si
                       add    di, 2                         ; di->字符串首

       ; 获取长度
                       xor    cx, cx
                       add    si, 1
                       mov    cl, byte ptr [si]             ; cx->长度（包含符号）
                       add    si, cx                        ; si->字符串尾
                   
                   
       ; 符号判断
                       mov    dl, byte ptr [di]

                     
                       cmp    dl, '-'
                       jz     is_neg
       ; ELSE1
                       cmp    dl, '+'
                       mov    dx, 0000h
                       jnz    invert
       ;IF1_2
                       sub    cx, 1
                       jmp    invert
       is_neg:         
       ; IF1
                       sub    cx, 1
                       mov    dx, 0ffffh
       ; END_IF1_2
       ; END_IF1

       invert:         
       ; cx->长度（不包含符号）
                       mov    bx, word ptr [bp+16]
                       mov    word ptr [bx], dx

                       mov    di, word ptr [bp+18]          ; di->目标存储区
                       mov    byte ptr [di], cl             ; 存储长度
                       inc    di

       ; 颠倒字符串
       invert_loop:    
                       mov    dl, byte ptr [si]
                       mov    byte ptr [di], dl
                       inc    di
                       dec    si
                       loop   invert_loop

       ; 恢复现场
                       pop    bx
                       pop    cx
                       pop    dx
                       pop    di
                       pop    si
                       pop    bp

                       ret    4

preprocess endp


judge_abs_above proc far
       ; 两个参数: 1.第一个绝对值（字符串地址） 2.第二个绝对值（字符串地址） 3.标志区
       ; 使用寄存器 bp, si, di, ax, bx, cx, dx(7)

       ; 保护现场
                       push   bp
                       push   si
                       push   di
                       push   ax
                       push   bx
                       push   cx
                       push   dx


                       mov    bp, sp

                       mov    si, word ptr [bp+22] ; arg1
                       mov    di, word ptr [bp+20] ; arg2

                       mov    al, byte ptr [si]
                       mov    bl, byte ptr [di]

                       cmp    al, bl
                       ja     abs_above_equal
                       jb     abs_below

       ; Same Length
                       xor    ah, ah
                       xor    bl, bl
                       add    si, ax
                       add    di, bx
                       mov    cx, ax

       abs_loop:       
                       mov    al, byte ptr [si]
                       mov    bl, byte ptr [di]
                       cmp    al, bl
                       ja     abs_above_equal
                       jb     abs_below

                       dec    si
                       dec    di
                       loop   abs_loop

       abs_above_equal:
                       mov    si, word ptr [bp+18] ; arg3
                       mov    word ptr [si], 0ffffh
                       jmp    abs_return

       abs_below:      
                       mov    si, word ptr [bp+18]
                       mov    word ptr [si], 0000h

       abs_return:     
       ; 恢复现场
                       pop    dx
                       pop    cx
                       pop    bx
                       pop    ax
                       pop    di
                       pop    si
                       pop    bp

                       ret    6

judge_abs_above endp


add_string proc far
       ; 参数4个 操作数1, 操作数2, 目标地址, 符号标志(is_neg)
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

                       mov    si, word ptr [bp+24]          ; arg1
                       mov    di, word ptr [bp+22]          ; arg2
                       mov    bx, word ptr [bp+20]          ; arg3
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
                       dec    bx
       add_not_carry:  
                       mov    dx, word ptr [bp+18]          ; arg4
                       test   dx, 0ffffh
                       jz     add_return
                       mov    byte ptr [bx], "-"

       add_return:     
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

sub_string proc far
       ; 参数4个 操作数1, 操作数2, 目标地址, 符号标志(is_neg)
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

                       mov    si, word ptr [bp+24]          ; arg1
                       mov    di, word ptr [bp+22]          ; arg2
                       mov    bx, word ptr [bp+20]          ; arg3
                       add    bx, 11

                       xor    ax, ax
                       mov    cx, 10
       sub_char:       
                       mov    al,byte ptr [si]
                       mov    dl, byte ptr [di]

                       sub    al, 30h
                       sub    dl, 30h

                       sahf
                       sbb    al, dl
                       aas
                       lahf

                       add    al, 30h
                       mov    byte ptr [bx], al

                       inc    si
                       inc    di
                       dec    bx
                       loop   sub_char

                       mov    dx, word ptr [bp+18]          ; arg4
                       test   dx, 0ffffh
                       jz     sub_return
                       mov    byte ptr [bx], "-"

       sub_return:     

       ; 恢复现场
                       pop    dx
                       pop    cx
                       pop    bx
                       pop    ax
                       pop    di
                       pop    si
                       pop    bp

                       ret    6
sub_string endp

code ends
end start


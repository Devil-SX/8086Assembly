data segment
      msg       db "Please input:",0dh,0ah,"$"
      buf       db 6, ?, 20 dup("$")
      real_disk db "disk","$"
      br        db 0dh,0ah,"$"
data ends

extra segment
      disk  db "data","name","time","file","code","path","user","exit","quit","text"
extra ends


stack segment para stack
            dw 128  dup(0)
stack ends

code segment
                assume ds:data, cs:code, ss:stack, es:extra
      start:    
      ; Initialize
                mov    ax, data
                mov    ds,ax
                mov    ax, extra
                mov    es, ax

      ; Show msg
                mov    ah, 9
                lea    dx, msg
                int    21h

      ; Input
                mov    ah, 0ah
                lea    dx, buf
                int    21h
                mov    ah, 9
                lea    dx, br
                int    21h


                lea    bp, disk
      ; si -> buf
      ; bp -> disk

      ; 循环10个单词
                mov    cx, 10
                mov    dx, 0
                cld
      loop_here:                                                 ; 比10次
      ; 准备cpm
                mov    cx, 4

      ; 更新di
                push   cx                                        ; 准备子循环比较字符串
                push   dx                                        ; 获取常字符串偏移地址
                shl    dx, 1                                     ; 乘以4
                shl    dx,1
                add    dx, bp
                mov    di,dx
                pop    dx                                        ; 取回字符串数组下标
                inc    dx

      ; 更新si
                lea    si, buf+2
                repe   cmpsb
                
                je     found                                     ; 如果找到了，就跳转到found

                pop    cx
                loop   loop_here

                mov    ah, 9                                     ; 如果没找到，就显示原来的
                lea    dx, buf
                add    dx,2
                int    21h
                lea    dx, br
                int    21h

                jmp    next

      found:    
                mov    ah, 9
                lea    dx, real_disk
                int    21h
                lea    dx, br
                int    21h
      next:     

      ; Exit
                mov    ah, 4ch
                int    21h
code ends
end start
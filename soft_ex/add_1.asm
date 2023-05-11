; Add
; 键盘输入两个任意长度十进制数（20位以内）的求和，用“-”来标识负数，正数可以不加符号或加“+”号
; 思路 直接对字符串进行加减
; ！！未完成，放弃维护


; 没有非法输入判断，要求输入都是合法的
data segment
  msg  db "Please input number1:",0dh,0ah,"$"
  msg2 db "Please input number2:",0dh,0ah,"$"
  buf  db 21, ?, 22 dup("$")
  buf2 db 21, ?, 22 dup("$")
  sum  db 0dh, 22 dup("$")
  flag db 0
  ; flag&1 -> 是否符号相同
  ; flag>>1&1 -> 是否全为负
  ; flag>>2&1 -> buf2是否为负
  br   db 0dh,0ah,"$"
data ends

stack segment para stack
        dw 128 dup(0)
stack ends

code segment
                assume ds:data, cs:code, ss:stack

  start:        
  ; 初始化和数据准备---------------
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

  ; 符号判断-----------------
  ; 判断过程
                lea    si, buf+2
                call   jug_signed
                sahf
                mov    ch,ah                       ; ch/dh->buf判断结果
                mov    dh,ah

                lea    si, buf2+2
                call   jug_signed
                sahf                               ; ah->buf2判断结果

  ; 结果存储
                xor    cl, cl
  ; cl 存储最终flag结果
  ; 判断符号是否相同
                xor    ch, ah
                and    ch, 08h                     ; ZF是8086 flags[3]
                add    cl, ch
                shr    cl, 1
  ; 判断符号是否全为负
                and    dh, ah
                and    dh, 08h
                add    cl, dh
                shr    cl, 1
  ; 判断buf2是否为负
                and    ah, 08h
                add    cl, ah
                shr    cl, 1
                lea    si, flag
                mov    [si], cl
            

  ; 开始计算-----------------
  ; 1.符号是否相同？
                mov    al, flag
                test   al, 1
                jz     add_here
  ; 1.1符号不相同



                jmp    signal_adjust


  add_here:     
  ; 1.2符号相同

  signal_adjust:



  ; 输出---------------------

  start_output: 



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

sub_char proc
  ; 入口参数Al,Bl,bp,SI,ah
  ; ah是上一次das后的状态寄存器
  ; 将AL和BL的数字字符串相减，并存在[bp+SI]中（字符串形式）
  ; 出口参数[bp+SI]
                push   dx

                sub    al,48
                sub    bl,48
                sahf
                sbb    al, bl
                das
                lahf
  ; 取个位
                add    al,48
                mov    ds:[bp+si], al
                 
                pop    dx
                ret
sub_char endp

jug_signed proc
  ; 入口参数 SI
  ; SI指向需要判断的符号位，ZF=1为负，ZF=0为正
  ; 出口参数 ZF
                push   ax
                mov    al, ds:[si]
                cmp    al, '-'
                pop    ax
                ret
jug_signed endp


code ends
end start
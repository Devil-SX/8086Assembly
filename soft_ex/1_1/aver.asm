data segment
  msg              db "Please input a number",0dh,0ah,
"0 for Row Statics",0dh,0ah,
"1 for Column Statics",0dh,0ah,
"3 for Exit Program",0dh,0ah,"$"
  br               db 0dh,0ah,"$"
  msg_aver         db "'s average score is ","$"

  courses_length   dw 5
  courses_stringp  dw 5 dup(0)
  zh               db "Chinese"
  eng              db "English"
  math             db "Math"
  phy              db "Physics"
  che              db "Chemistry"
  
  students_length  dw 10
  students_stringp dw 10 dup(0)
  stu1             db "Abraham"
  stu2             db "Jean"
  stu3             db "Martin"
  stu4             db "Sidney"
  stu5             db "Terence"
  stu6             db "Mattew"
  stu7             db "Grant"
  stu8             db "Dustin"
  stu9             db "Curtis"
  stu10            db "Bert"
  
  ; Row for courses
  ; Column for students
  score1           db 33,25,90,33,84
  score2           db 11,2,27,15,84
  score3           db 39,14,89,89,52
  score4           db 23,32,82,37,31
  score5           db 80,25,39,50,98
  score6           db 30,45,30,80,17
  score7           db 74,8,97,64,32
  score8           db 11,45,41,83,30
  score9           db 64,25,29,68,90
  score10          db 5,94,37,24,48

data ends


code segment
             assume cs:code, ds:data
  start:     
  ; Initialize
             mov    ax, data
             mov    ds, ax

             lea    dx, score1
             push   dx
             mov    dx, 5
             push   dx
             mov    dx, 1
             push   dx
             call   far ptr aver
  
  ; Exit
             mov    ah, 4ch
             int    21h


aver proc far
  ; 3 paras
  ; 3 Input {Addr, Length, Offset}
  ; use ax, bx, cx,  dx, si, bp(6regs)

             push   ax
             push   bx
             push   cx
             push   dx
             push   si
             push   bp
             


             mov    bp, sp

  ; SUM
             xor    ax, ax

             mov    si, word ptr [bp+20]  ; arg1
             mov    cx, word ptr [bp+18]  ; arg2
             mov    dx, word ptr [bp+16]  ; arg3
             xor    bh, bh
  sum:       
  ; Get value
             mov    bl, byte ptr [si]
  
             add    ax, bx                ; sum
             add    si, dx                ; add offset
             loop   sum

  ; DIV
  ; ax -> sum
             mov    cx, word ptr [bp+18]  ; arg2
             xor    dx, dx
             div    cx
  ; ax-> aver

             push   ax
             call   far ptr hex2dec

             pop    bp
             pop    si
             pop    dx
             pop    cx
             pop    bx
             pop    ax

             ret    6
aver endp


hex2dec proc far
  ; 1 para Input HexNumber
  ; use ax, bx, cx, dx, bp(5regs)

             push   ax
             push   bx
             push   cx
             push   dx
             push   bp

             mov    bp, sp

             mov    ax, [bp+14]           ; arg1
  
             mov    cx, 30                ; Max echos of loop
             xor    bx, bx                ; realy echos of loop
  div_loop:  
             xor    dx, dx
             push   cx
             mov    cx, 10
             div    cx                    ; [DX,AX] Div 10
             pop    cx

  ; Print a char
             add    dl, 30h
             push   dx                    ; save dx
             inc    bx

             cmp    ax, 0
             loopnz div_loop


             mov    cx, bx
  print_loop:
             pop    dx
             mov    ah, 2
             int    21h
             loop   print_loop

             pop    bp
             pop    dx
             pop    cx
             pop    bx
             pop    ax

             ret    2

hex2dec endp

code ends
end start
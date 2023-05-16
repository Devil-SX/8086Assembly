data segment
  msg              db 0dh,0ah,
"[Info]Please input a number",0dh,0ah,
"0 for Row Statics(Students)",0dh,0ah,
"1 for Column Statics(Courses)",0dh,0ah,
"2 for Exit Program",0dh,0ah,"$"
  msg_invalid      db 0dh,0ah,"[Info]**********Invalid input!**********", 0dh, 0ah, "$"
  msg_row          db 0dh,0ah,"**********Row Aver**********", 0dh, 0ah, "$"
  msg_column       db 0dh,0ah,"**********Column Aver**********", 0dh, 0ah, "$"
  br               db 0dh,0ah,"$"
  msg_aver         db "'s average score is ","$"

  courses_length   dw 5
  courses_stringp  dw 5 dup(0)
  zh               db "Chinese","$"
  eng              db "English","$"
  math             db "Math","$"
  phy              db "Physics","$"
  che              db "Chemistry","$"
  
  students_length  dw 10
  students_stringp dw 10 dup(0)
  stu1             db "Abraham","$"
  stu2             db "Jean","$"
  stu3             db "Martin","$"
  stu4             db "Sidney","$"
  stu5             db "Terence","$"
  stu6             db "Mattew","$"
  stu7             db "Grant","$"
  stu8             db "Dustin","$"
  stu9             db "Curtis","$"
  stu10            db "Bert","$"
  
  ; Rows->students
  ; Columns->Courses
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

                call   far ptr init

  start_program:
  ; Show msg
                lea    dx, msg
                mov    ah, 9
                int    21h

  ; get input
                mov    ah, 1
                int    21h
                lea    dx, br
                mov    ah, 9
                int    21h


                cmp    al, "2"
                jz     exit
                cmp    al, "0"
                jz     row
                cmp    al, "1"
                jz     column

  ; Invalid Input
                lea    dx, msg_invalid
                mov    ah, 9
                int    21h
                jmp    start_program


  row:          
                lea    dx, msg_row
                mov    ah, 9
                int    21h

  ; Get number of rows
                lea    bx, students_length
                mov    cx, word ptr [bx]     ; cx->number of rows

  ; Get number of columns
                lea    bx, courses_length
                mov    bx, word ptr [bx]     ; bx->number of columns
                lea    si, students_stringp  ; si->addr of students string array
                lea    di, score1            ; di->addr of start of rows
  row_loop:     
  ; show row name(course)
                mov    ah, 9
                mov    dx, word ptr [si]
                int    21h
                add    si, 2

                lea    dx, msg_aver
                int    21h

  ; Print Aver
                push   di
                push   bx
                mov    dx, 1
                push   dx
                call   far ptr aver

                add    di, bx

                lea    dx, br
                mov    ah, 9
                int    21h

                loop   row_loop


                jmp    start_program


  column:       
                lea    dx, msg_column
                mov    ah, 9
                int    21h

  ; Get number of columns
                lea    bx, courses_length
                mov    cx, word ptr [bx]     ; cx->number of columns

  ; Get number of rows
                lea    bx, students_length
                mov    bx, word ptr [bx]     ; bx->number of rows
                lea    si, courses_stringp   ; si->addr of students string array
                lea    di, score1            ; di->addr of start of columns
  column_loop:  
  ; show column name(course)
                mov    ah, 9
                mov    dx, word ptr [si]
                int    21h
                add    si, 2

                lea    dx, msg_aver
                int    21h

  ; Print Aver
                push   di
                push   bx
                
                push   bx
                lea    bx, courses_length
                mov    ax, word ptr [bx]
                pop    bx

                push   ax
                call   far ptr aver

                add    di, bx

                lea    dx, br
                mov    ah, 9
                int    21h

                loop   column_loop


                jmp    start_program

  exit:         
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

init proc far
  ; Intialize courses
                lea    di, courses_stringp
                lea    dx, zh
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, eng
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, math
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, phy
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, che
                mov    word ptr [di], dx

  ; Initialize students
                lea    di, students_stringp
                lea    dx, stu1
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu2
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu3
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu4
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu5
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu6
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu7
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu8
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu9
                mov    word ptr [di], dx
                add    di, 2
                lea    dx, stu10
                mov    word ptr [di], dx

                ret
init endp


code ends
end start
data segment
data ends


code segment
             assume cs:code, ds:data
  start:     
  ; Initialize
             mov    ax, data
             mov    ds, ax

  ; hex2dec
             mov    ax, 0FFFFH ; hex value
             push   ax
             call   far ptr hex2dec
    

  ; Exit
             mov    ah, 4ch
             int    21h

hex2dec proc far
  ; 1 para Input HexNumber
  ; use ax, bx, cx, dx, bp(5regs)

             push   ax
             push   bx
             push   cx
             push   dx
             push   bp

             mov    bp, sp

             mov    ax, [bp+14]       ; arg1
  
             mov    cx, 30            ; Max echos of loop
             xor    bx, bx            ; realy echos of loop
  div_loop:  
             xor    dx, dx
             push   cx
             mov    cx, 10
             div    cx                ; [DX,AX] Div 10
             pop    cx

  ; Print a char
             add    dl, 30h
             push   dx                ; save dx
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
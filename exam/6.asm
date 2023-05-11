data segment
      msg  db "Please a word number:",0dh,0ah,"$"
      buf  db 14, ?, 14 dup("$")
      buf2 db 16 dup("$")
      br   db 0dh,0ah,"$"
data ends

code segment
            assume ds:data, cs:code

      ;description
            PROC
            
name ENDP

      start:
      ; Initialize
            mov    ax, data
            mov    ds,ax

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

      ; Get Length of String
            lea    bx, buf+1
            mov    cx, [bx]
            mov    si, cx
      ; cx/si->length of buf
      ; bx-> start of buf+1


            xor    dx, dx
      ; dx -> Store Binary Value


      d2b:  
      ; Get Value
            push   cx
            mov    al, [bx+si]
            sub    al, 48
                
      ; Multiply
            mov    cx, 10
            mul    cx

            add    dx, ax

            dec    si
            pop    cx
            loop   d2b

      b2h:  
      



      ; Exit
            mov    ah, 4ch
            int    21h
code ends
end start
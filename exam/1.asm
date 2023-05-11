data segment
      msg  db "Please input a string",0dh,0ah,"$"
      br   db 0dh, 0ah, "$"
      buf  db 20,?,20 dup("$")
      buf2 db 20 dup("$")
data ends

code segment
            assume ds:data, cs:code

      start:
            mov    ax, data
            mov    ds, ax

      ; print msg
            mov    ah, 9
            lea    dx, msg
            int    21h

      ; read string
            mov    ah, 0ah
            lea    dx, buf
            int    21h
            mov    ah,9
            lea    dx, br
            int    21h

      ; get length of string
            lea    bx, buf
            mov    cl, [bx+1]
            xor    ch, ch
            add    bx, 2
            lea    bp, buf2
      ; cx/cl -> length of string
      ; bx -> start of string
      ; bp -> start of other string

      ; mov string loop
            mov    si, 0
            mov    di,0
      print:
            mov    dl, [bx+si]
            cmp    dl, "A"
            je     isA
            mov    ds:[bp+di], dl
            jmp    next
      isA:  
            mov    ds:[bp+di], "C"
            inc    di
            mov    ds:[bp+di], "C"
      next: 
            inc    si
            inc    di
            loop   print

      ; print
            mov    ah, 9
            lea    dx, buf2
            int    21h
            lea    dx, br
            int    21h

      ; exit
            mov    ah,4ch
            int    21h
code ends
end start

data segment
      msg  db "Please input:",0dh,0ah,"$"
      buf  db 20, ?, 20 dup("$")
      br   db 0dh,0ah,"$"
data ends

code segment
            assume ds:data, cs:code
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

      ; Exit
            mov    ah, 4ch
            int    21h
code ends
end start
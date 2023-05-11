data segment
  msg  db "Please input:",0dh,0ah,"$"
  buf  db 20, ?, 20 dup("$")
  buf2 db 20 dup("$")
  br   db 0dh,0ah,"$"
data ends

code segment
              assume ds:data, cs:code
  start:      
  ; Initialize
              mov    ax, data
              mov    ds, ax
             
  ; Show msg
              mov    ah, 09h
              lea    dx, msg
              int    21h

  ; Input
              mov    ah, 0ah
              lea    dx, buf
              int    21h
              mov    ah,09h
              lea    dx,br
              int    21h

  ; Get length of String
              lea    bx, buf
              mov    cl, [bx+1]
              xor    ch,ch
              add    bx, 2
              lea    bp, buf2
  ; bx -> Start of Raw String
  ; cl/cx -> Length of Raw String
  ; bp -> Start of Des String

              xor    si,si
  loop_here:  
              mov    dl, [bx+si]
              cmp    dl, "A"
              jb     not_my_case
              cmp    dl, "Z"
              ja     not_my_case

  ; is_my_case
              add    dl, 32
              mov    ds:[bp+si],dl
              jmp    next

  not_my_case:
              mov    ds:[bp+si], dl
              jmp    next
  next:       
              inc    si
              loop   loop_here

  ; Print Output
              mov    ah,09h
              lea    dx,buf2
              int    21h

              mov    ah, 4ch
              int    21h

code ends
end start
; Delete characters
; and condition
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
              lea    bx, buf
              mov    cl, [bx+1]
              xor    ch,ch
              add    bx,2
              lea    bp, buf2
  ; bx->buf+2
  ; cx->length
  ; bp->buf2

              xor    si,si
              xor    di,di
  loop_here:  
  ; Get Value
              mov    dl, [bx+si]

              cmp    dl, 'A'
              jb     and2
              cmp    dl, 'Z'
              ja     and2
              jmp    next

  and2:       
              cmp    dl, 'a'
              jb     is_not_case
              cmp    dl, 'z'
              ja     is_not_case
              jmp    next
  is_not_case:
              mov    ds:[bp+di], dl
              inc    di
              jmp    next
  next:       
              inc    si
              loop   loop_here

  ; Show Result
              mov    ah, 9
              lea    dx, buf2
              int    21h
              lea    dx, br
              int    21h

  ; Exit
              mov    ah, 4ch
              int    21h
code ends
end start
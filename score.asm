%include "data.asm"
%include"print.asm" 
convert_score:
    xor dx, dx
    div bx              ; AX = quotient, DX = remainder
    add dl, '0'         ; convert to ASCII
    mov [si], dl        ; store digit
    dec si
    loop convert_score
    
    ; Update score display immediately
    push 0
    push score_string
    push word [cs:score_length]
    call print
    
    popa
    ret

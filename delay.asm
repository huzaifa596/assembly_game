delay:
    pusha
    mov cx, 200           ;
d10:
    push cx
    mov cx, 0x0FFF       
d20:
    loop d20
    pop cx
    loop d1
    popa
    ret

delay_short:
    pusha
    mov cx, 20           ;
d1:
    push cx
    mov cx, 0x0FFF       
d2:
    loop d2
    pop cx
    loop d1
    popa
    ret
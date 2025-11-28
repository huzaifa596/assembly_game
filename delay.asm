delay:
    pusha
    mov cx, 200           ; Reduced delay for better visibility
d1:
    push cx
    mov cx, 0x0FFF       ; Reduced inner delay
d2:
    loop d2
    pop cx
    loop d1
    popa
    ret
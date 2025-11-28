; function to clear the screen
clear:
    push ax
    push es
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    mov di, 0
        
    ; first line (white)       
    mov cx, 80
    mov ax, 0x0720
    rep stosw
    
    ; blue color printing
    mov cx, 1600
    mov ax, 0x1F20  ; Changed from 0xBF20 to 0x1F20 (blue on blue was hard to see)
    rep stosw
    
    ; green color printing
    mov cx, 320
    mov ax, 0x2A20  ; Changed from 0xA020 to 0x2A20 (green on green)
    rep stosw

    pop cx
    pop di
    pop es
    pop ax
    ret

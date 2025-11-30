
clear:
    push ax
    push es
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    mov di, 160
        
   
    ; blue color printing
    mov cx, 1600
    mov ax, 0x1F20  
    rep stosw
    
    ; green color printing
    mov cx, 320
    mov ax, 0x2A20 
    rep stosw

    pop cx
    pop di
    pop es
    pop ax
    ret

; first line clear
clear_first:
    push ax
    push es
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    mov di, 0
        
    
    mov cx, 80
    mov ax, 0x0720
    rep stosw

     pop cx
    pop di
    pop es
    pop ax
    ret


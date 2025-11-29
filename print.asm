print:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push di 
    push si

    mov si, [bp+6]    ; string address
    mov cx, [bp+4]    ; string length
    mov ax, 0xb800
    mov es, ax
    mov ah, 0x07      ; attribute
    mov di, [bp+8]    ; position
    shl di, 1         ; convert to video memory offset

printer:
    mov al, [si]
    mov [es:di], ax
    inc si
    add di, 2
    loop printer

    pop si
    pop di
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 6
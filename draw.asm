draw:
    push bp
    mov bp, sp
    push es
    push di
    push ax
    push cx
    push dx

    ; row is [bp+4], col is [bp+6]
    mov ax, 80
    mul word [bp+4]      ; ax = row * 80
    add ax, [bp+6]       ; add column
    shl ax, 1            ; each cell = 2 bytes
    mov di, ax

    mov ax, 0xb800
    mov es, ax

    ; balloon outline color: attribute 0x4F, char 0xFE
    mov ax, 0x4FFE
    mov cx, 0
    
nxt_down:
    mov word [es:di], ax ; vertical down
    add di, 160
    inc cx
    cmp cx, 2
    jne nxt_down

txt_right:
    mov word [es:di], ax ; horizontal right
    add di, 2
    inc cx
    cmp cx, 5
    jne txt_right

    sub di, 2
dxt_up:
    mov word [es:di], ax ; vertical up
    sub di, 160
    inc cx
    cmp cx, 8
    jne dxt_up

    add di, 158
    mov word [es:di], ax  ; close top
    add di, 160

    ; draw the letter in center
    mov ah, 0x8F          ; keep same attribute
    mov al, [bp+8]        ; character from [bp+8]
    mov word [es:di], ax

    ; draw the string (line) under balloon
    add di, 320
    mov ah, 0x8F         ; attribute for the line
    mov al, 0xB3          ; character for the line
    mov cx, 0
line:
    mov word [es:di], ax
    inc cx
    add di, 162
    cmp cx, 2
    jne line

    pop dx
    pop cx
    pop ax
    pop di
    pop es
    pop bp
    ret 6
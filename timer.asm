[org 0x100]

tick: dw 0
current_time: dw 60  ; Start from 60

printnum:
    push bp
    mov bp,sp
    pusha
    push es
    mov ax,0xb800
    mov es,ax
    mov cx,0
    mov ax,[bp+4]
    mov bx,10  ; divisor for decimal conversion

nextdigit:
    mov dx,0
    div bx
    add dl,0x30
    push dx
    inc cx
    cmp ax,0
    jne nextdigit   
    mov di,140

nextpos:
    pop dx
    mov dh,0x07
    mov [es:di],dx
    add di,2
    loop nextpos
    pop es
    popa
    pop bp  
    ret 2

timer:
    push ax
    inc word[cs:tick]
    cmp word[cs:tick],18  ; Wait for 18 ticks (approximately 1 second)
    jne skip
    
    ; Reset tick counter and decrement time
    mov word[cs:tick],0
    dec word[cs:current_time]
    
    ; Check if timer reached 0
    
    ; Display current time
    push word[cs:current_time]
    call printnum
    jmp skip
    

    
skip:
    mov al,0x20
    out 0x20,al
    pop ax
    iret


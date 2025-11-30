; ==================== TIMER INTERRUPT HANDLER ====================
%include "data.asm"
timer:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
   cmp byte[lives],0
   je skipp2
    inc word [cs:tick]
    cmp word [cs:tick], 18
    jne skipp2

    mov word [cs:tick], 0
    dec word [cs:current_time]

    cmp word [cs:current_time], 0
    je stop_program2

    ; -------- display time ----------
    mov ax, 0B800h
    mov es, ax
    mov di, 90            ; Timer right after "Time:" label

    mov ax, [cs:current_time]
    mov bx, 10
    xor dx, dx
    div bx           ; AX = quotient, DX = remainder

    ; tens digit
    add al, '0'
    mov ah, 07h
    mov [es:di], ax
    add di, 2

    ; ones digit
    mov al, dl
    add al, '0'
    mov ah, 07h
    mov [es:di], ax

    jmp skipp2

stop_program2:
    mov word [cs:done], 1

skipp2:
    mov al, 20h
    out 20h, al

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    cmp word [cs:done], 1
    jne no_chain2
    jmp far [cs:old]

no_chain2:
    iret

;L24-0695 -> Huzaifa Naseer
;L24-0744 -> Zain Khan 

;-------------------------------------
[org 0x0100]
jmp start

BALL_COUNT equ 3

ball_rows:  dw 23, 23, 23
ball_cols:  dw 10, 30, 50
ball_chars: db 'O','O','O'


%include "draw.asm"
%include "clear.asm"
%include "delay.asm"
%include "start.asm"
%include "print.asm"
bool1: db 0
bool2: db 0
bool3: db 0
inst: db 'Score:0'
inst1: db 'Time:60'
size: dw 7
size1: dw 6
old: dd 0
done: dw 0
tick: dw 0
current_time: dw 60  ; Start from 60
timer:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    inc word [cs:tick]
    cmp word [cs:tick], 18
    jne skipp2

    mov word [cs:tick], 0
    dec word [cs:current_time]

    cmp word [cs:current_time], 0
    jle stop_program2

    ; -------- display time ----------
    mov ax, 0B800h
    mov es, ax
    mov di, 90       ; YOU SHOULD ADJUST THIS COLUMN LATER

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

; function to print the score and time
looper:
    push bp
    mov bp, sp
    pusha

    mov cx, 24           ; rows 24..1 (skip row 0 for UI)
    mov dx, 23           ; start row at 23 (above ground)
    mov bx, [bp+4]       ; fixed column
    mov al, [bp+6]       ; balloon letter
    
    
l1:
    ; Draw balloon
    push ax              ; character
    push bx              ; column
    push dx              ; row
    call draw
    call delay
    call clear
    
    dec dx               ; move balloon up one row
    loop l1

    popa
    pop bp
    ret 4

repeater:
    pusha
    mov word [cs:lo], 10  ; Start column
    
go:
    ; Check if we should stop (timer reached 0)
    cmp word [cs:current_time], 0
    jle end_repeater
    
    ; Balloon 1
    push 'O'             ; balloon character
    push word [cs:lo]    ; column
    call looper
    
    ; Small delay between balloons
    call delay
    call delay
    
    ; Balloon 2 (slightly to the right)
    push 'O'
    push word [cs:lo]
    add word [esp], 5    ; Offset second balloon
    call looper
    
    ; Small delay between balloons  
    call delay
    call delay
    
    ; Balloon 3 (further to the right)
    push 'O'
    push word [cs:lo]
    add word [esp], 10   ; Offset third balloon
    call looper
    
    ; Update UI after each set of balloons
    push 0               ; position for score
    push inst            ; score string
    push word [size]     ; score string length
    call print
    
    push 40              ; position for time  
    push inst1           ; time string
    push word [size1]    ; time string length
    call print
    
    call delay
    add word [cs:lo], 20 ; Move to next column set
    cmp word [cs:lo], 70 ; Check if within screen bounds
    jl go
    
    mov word [cs:lo], 10 ; Reset to left side
    
    jmp go

end_repeater:
    popa
    ret

lo: dw 10  ; Balloon column variable

start:
    call starter
    
key:   
    mov ah, 0
    int 16h
    cmp ah, 0x01        ; Escape key
    je end
    cmp ah, 0x39        ; Spacebar
    jne key

    call clear  
    xor ax, ax
    mov es, ax
    
    ; Save old timer ISR
    mov ax, [es:8*4]
    mov word [cs:old], ax
    mov ax, [es:8*4+2]
    mov word [cs:old+2], ax
    
    ; Set up timer interrupt
    cli 
    mov word [es:8*4], timer   
    mov word [es:8*4+2], cs
    sti
    
    ; Print initial score and time
    push 0               ; position for score
    push inst            ; score string
    push word [size]     ; score string length
    call print
    
    push 40              ; position for time  
    push inst1           ; time string
    push word [size1]    ; time string length
    call print
    
    ; Start balloon animation
    call repeater
    
    ; Set done flag and restore old ISR when finished
    mov word [cs:done], 1
    mov ax, [cs:old]
    mov [es:8*4], ax
    mov ax, [cs:old+2]
    mov [es:8*4+2], ax

end:
    mov ax, 0x4c00
    int 0x21

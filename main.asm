;L24-0695 -> Huzaifa Naseer
;L24-0744 -> Zain Khan 

;-------------------------------------

[org 0x0100]
jmp start

%include "draw.asm"
%include "clear.asm"
%include "print.asm"
%include "delay.asm"
%include "start.asm"
inst: db 'Score:0'
inst1: db 'Time:0'
size: dw 7
size1: dw 6


; function to print the score and time
looper:
    push bp
    mov bp, sp
    pusha

    mov cx, 25           ; rows 24..0 (25 times)
    mov dx, 24           ; start row at 24 (bottom)
    mov bx, 60           ; fixed column
    mov al, 'A'          ; balloon letter
    
l1:
    push ax              ; character -> [bp+8]
    push bx              ; column -> [bp+6]
    push dx              ; row -> [bp+4]
    call draw
    call delay
    call clear
    
    ; Print score and time again after clearing
    push 0               ; position for score
    push inst            ; score string
    push word [size]     ; score string length
    call print
    
    push 40              ; position for time  
    push inst1           ; time string
    push word [size1]    ; time string length
    call print
    
    dec dx               ; move balloon up one row
    loop l1

    popa
    pop bp
    ret





start:
    call starter
key:   
     mov ah,0
    int 16h
    cmp ah,0x01
    je end
    cmp ah,0x39
    jne key

    call clear  
    
    ; Print initial score and time
    push 0               ; position for score
    push inst            ; score string
    push word [size]     ; score string length
    call print
    
    push 40              ; position for time  
    push inst1           ; time string
    push word [size1]    ; time string length
    call print
    call looper

end:
    mov ax, 0x4c00
    int 0x21
;L24-0695 -> Huzaifa Naseer
;L24-0744 -> Zain Khan 

[org 0x100]
jmp starter

; Unique variable names
menu_title1: db '  ####    #####   #####      ####    #####   #####  ',0
menu_title2: db ' ##  ##  ##   ##  ##  ##    ##  ##  ##   ##  ##  ## ',0
menu_title3: db ' #####   ##   ##  #####     #####   ##   ##  #####  ',0
menu_title4: db ' ##      ##   ##  ##        ##      ##   ##  ##     ',0
menu_title5: db ' ##       #####   ##        ##       #####   ##     ',0
menu_subtitle: db ' FIGHT WITH ALPHABETS',0

; Menu instructions
menu_opt1: db '1. Press P TO START '
menu1_len: dw 19
menu_opt2: db '2.PRESS THE ALPAHBET IN THE BALLOON TO POP IT'
menu2_len: dw 45
menu_opt3: db '3.YOU HAVE EXACTLY 1 MINUTE'
menu3_len: dw 27
menu_opt4: db '4.MAKE SURE YOU ENJOY PLAYING'
menu4_len: dw 29

; Title line positions array
title_data:
    dw menu_title1, 6, 15
    dw menu_title2, 7, 15
    dw menu_title3, 8, 15
    dw menu_title4, 9, 15
    dw menu_title5, 10, 15
    dw 0

clear_screen:
    pusha
    push es
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x4F20
    mov cx, 2000
    rep stosw
    pop es
    popa
    ret

print_string:
    push bp
    mov bp, sp
    pusha
    
    mov ax, 0xb800
    mov es, ax
    
    ; Calculate position: (row * 80 + col) * 2
    mov ax, [bp+10]     ; row
    mov bx, 80
    mul bx
    add ax, [bp+8]      ; col
    shl ax, 1
    mov di, ax
    
    mov si, [bp+6]      ; string
    mov cx, [bp+4]      ; length
    mov ah, 0x40        ; attribute
    
.print_loop:
    lodsb
    stosw
    loop .print_loop
    
    popa
    pop bp
    ret 8

print_menu_title:
    pusha
    mov ax, 0xb800
    mov es, ax
    mov bx, title_data
    
.title_loop:
    mov si, [bx]        ; string pointer
    test si, si
    jz .print_subtitle
    
    ; Calculate position
    mov ax, [bx+2]      ; row
    mov dx, 80
    mul dx
    add ax, [bx+4]      ; col
    shl ax, 1
    mov di, ax
    
    mov ah, 0x4F        ; attribute
    
.char_loop:
    lodsb
    test al, al
    jz .next_line
    cmp al, '#'
    jne .space
    mov word [es:di], 0x0720  ; black for letters
    jmp .next_char
.space:
    mov word [es:di], 0x4F20  ; red for spaces
.next_char:
    add di, 2
    jmp .char_loop

.next_line:
    add bx, 6
    jmp .title_loop

.print_subtitle:
    mov ax, 13 * 80 + 28
    shl ax, 1
    mov di, ax
    mov si, menu_subtitle
    mov ah, 0x40
    
.sub_loop:
    lodsb
    test al, al
    jz .done
    stosw
    jmp .sub_loop

.done:
    popa
    ret

print_menu_options:
    pusha
    ; Option 1
    mov ax, 12
    push ax
    mov ax, 19
    push ax
    mov ax, menu_opt1
    push ax
    mov ax, [menu1_len]
    push ax
    call print_string
    
    ; Option 2
    mov ax, 12
    push ax
    mov ax, 20
    push ax
    mov ax, menu_opt2
    push ax
    mov ax, [menu2_len]
    push ax
    call print_string
    
    ; Option 3
    mov ax, 12
    push ax
    mov ax, 21
    push ax
    mov ax, menu_opt3
    push ax
    mov ax, [menu3_len]
    push ax
    call print_string
    
    ; Option 4
    mov ax, 12
    push ax
    mov ax, 22
    push ax
    mov ax, menu_opt4
    push ax
    mov ax, [menu4_len]
    push ax
    call print_string
    popa
    ret

starter:
    call clear_screen
    call print_menu_title
    call print_menu_options
       
    ret
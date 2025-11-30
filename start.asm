; ===========================================
; Balloon Popping Game - Start Screen
; L24-0695 -> Huzaifa Naseer  
; L24-0744 -> Zain Khan 
; ===========================================

[org 0x100]
jmp starter

; ============ MENU TEXT STRINGS ============
menu_title1: db '  ####    #####   #####      ####    #####   #####  ',0
menu_title2: db ' ##  ##  ##   ##  ##  ##    ##  ##  ##   ##  ##  ## ',0
menu_title3: db ' #####   ##   ##  #####     #####   ##   ##  #####  ',0
menu_title4: db ' ##      ##   ##  ##        ##      ##   ##  ##     ',0
menu_title5: db ' ##       #####   ##        ##       #####   ##     ',0

menu_subtitle: db ' FIGHT WITH ALPHABETS',0
space_message: db 'PRESS SPACE TO PLAY'
space_msg_len: dw 19

; Menu option texts
menu_opt1: db '1. Press P TO START '
menu1_len: dw 19

menu_opt2: db '2.PRESS THE ALPAHBET IN THE BALLOON TO POP IT'
menu2_len: dw 45

menu_opt3: db '3.YOU HAVE EXACTLY 1 MINUTE'
menu3_len: dw 27

menu_opt4: db '4.MAKE SURE YOU ENJOY PLAYING'
menu4_len: dw 29

; Title display data: string, row, col
title_data:
    dw menu_title1, 6, 15
    dw menu_title2, 7, 15  
    dw menu_title3, 8, 15
    dw menu_title4, 9, 15
    dw menu_title5, 10, 15
    dw 0                    ; end marker

; ============ SCREEN CLEAR FUNCTION ============
clear_screen:
    pusha
    push es
    
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x4F20          ; red background, space char
    mov cx, 2000            ; entire screen
    
    clear_screen_loop:
    stosw                   ; fill screen
    loop clear_screen_loop
    
    pop es
    popa
    ret

; ============ STRING PRINT FUNCTION ============
print_string:
    push bp
    mov bp, sp
    pusha
    
    mov ax, 0xb800
    mov es, ax
    
    ; Calculate screen position: (row * 80 + col) * 2
    mov ax, [bp+10]         ; row number
    mov bx, 80
    mul bx
    add ax, [bp+8]          ; column number  
    shl ax, 1               ; multiply by 2 for attribute
    mov di, ax
    
    ; Set up string parameters
    mov si, [bp+6]          ; string pointer
    mov cx, [bp+4]          ; string length
    mov ah, 0xC0            ; red background, black text
    
    print_string_loop:
    lodsb                   ; load next character
    stosw                   ; store char + attribute
    loop print_string_loop
    
    popa
    pop bp
    ret 8

; ============ MENU TITLE DISPLAY ============
print_menu_title:
    pusha
    mov ax, 0xb800
    mov es, ax
    mov bx, title_data      ; point to title data array
    
    title_display_loop:
    mov si, [bx]            ; get string pointer
    test si, si             ; check for end marker (0)
    jz display_subtitle
    
    ; Calculate screen position for this line
    mov ax, [bx+2]          ; row position
    mov dx, 80
    mul dx
    add ax, [bx+4]          ; column position
    shl ax, 1
    mov di, ax
    
    mov ah, 0x4F            ; red background, white text
    
    character_loop:
    lodsb                   ; load next character
    test al, al             ; check for null terminator
    jz next_title_line
    
    cmp al, '#'             ; check if it's part of letter
    jne space_character
    
    ; Draw letter part (black on red)
    mov word [es:di], 0x0720  ; black background for letters
    jmp next_character
    
    space_character:
    ; Draw background (red)
    mov word [es:di], 0x4F20  ; red background for spaces
    
    next_character:
    add di, 2
    jmp character_loop

    next_title_line:
    add bx, 6               ; move to next title line data
    jmp title_display_loop

    display_subtitle:
    ; Position subtitle below main title
    mov ax, 13 * 80 + 28    ; row 13, column 28
    shl ax, 1
    mov di, ax
    
    mov si, menu_subtitle
    mov ah, 0x40            ; red background, black text
    
    subtitle_character_loop:
    lodsb
    test al, al             ; check for null terminator
    jz title_display_done
    stosw                   ; store character with attribute
    jmp subtitle_character_loop

    title_display_done:
    popa
    ret

; ============ MENU OPTIONS DISPLAY ============
print_menu_options:
    pusha
    
    ; Display option 1 - Start instruction
    mov ax, 12              ; row
    push ax
    mov ax, 19              ; column  
    push ax
    mov ax, menu_opt1       ; string
    push ax
    mov ax, [menu1_len]     ; length
    push ax
    call print_string
    
    ; Display option 2 - Gameplay instruction  
    mov ax, 12              ; row
    push ax
    mov ax, 20              ; column
    push ax
    mov ax, menu_opt2       ; string
    push ax
    mov ax, [menu2_len]     ; length
    push ax
    call print_string
    
    ; Display option 3 - Time limit
    mov ax, 12              ; row
    push ax
    mov ax, 21              ; column
    push ax
    mov ax, menu_opt3       ; string
    push ax
    mov ax, [menu3_len]     ; length
    push ax
    call print_string
    
    ; Display option 4 - Enjoy message
    mov ax, 12              ; row
    push ax
    mov ax, 22              ; column
    push ax
    mov ax, menu_opt4       ; string
    push ax
    mov ax, [menu4_len]     ; length
    push ax
    call print_string
    
    popa
    ret

; ============ SPACE MESSAGE DISPLAY ============
print_space_message:
    pusha
    
    ; Position at bottom center: row 23, column 31
    mov ax, 23              ; bottom row
    push ax
    mov ax, 31              ; centered column
    push ax
    mov ax, space_message   ; "PRESS SPACE TO PLAY"
    push ax
    mov ax, [space_msg_len] ; message length
    push ax
    call print_string
    
    popa
    ret

; ============ MAIN STARTER FUNCTION ============
starter:
    call clear_screen           ; clear to red background
    call print_menu_title       ; display game title
    call print_menu_options     ; show game instructions
    call print_space_message    ; display "PRESS SPACE TO PLAY"
       
    ret
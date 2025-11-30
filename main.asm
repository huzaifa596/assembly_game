; ===========================================
; Balloon Popping Game - Main Program
; L24-0695 -> Huzaifa Naseer
; L24-0744 -> Zain Khan 
; ===========================================

[org 0x0100]
jmp start

; ============ INCLUDED FILES =============
%include "gameover.asm"
%include "draw.asm"
%include "clear.asm" 
%include "delay.asm"
%include "start.asm"
%include "keyboard.asm"
%include "timer.asm"
%include "print.asm"

; ============ RANDOM NUMBER GENERATOR ============
generate_random:
    push bx
    push dx
    
    mov ax, [cs:random]
    mov bx, 13645
    mul bx
    add ax, 15873
    mov [cs:random], ax
    mov al, ah
    
    pop dx
    pop bx
    ret

; Generate random letter A-Z
generate_random_letter:
    push bx
    push dx
    
    call generate_random
    and al, 31              ; 0-31 range
    cmp al, 26
    jb letter_ok
    sub al, 6               ; if 26-31, make it 20-25
letter_ok:
    add al, 'A'             ; convert to uppercase letter
    
    pop dx
    pop bx
    ret

; Generate random column position
generate_random_column:
    push bx
    push cx
    push si
    
try_new_column:
    call generate_random
    and ax, 55              ; 0-55 range  
    add ax, 20              ; 20-75 range
    
    ; Check for collision with existing balloons
    mov cx, [count]
    mov si, 0

check_collision_loop:
    cmp word [cs:ball_cols + si], 0
    je next_balloon_check
    
    mov bx, [cs:ball_cols + si]
    sub bx, ax
    jns positive_diff
    neg bx
positive_diff:
    cmp bx, 8               ; need 8 columns apart
    jl try_new_column       ; too close, try again
    
next_balloon_check:
    add si, 2
    loop check_collision_loop
    
    pop si
    pop cx
    pop bx
    ret

; Update all balloon letters and positions
update_balloon_letters:
    pusha
    mov cx, word[count]
    mov si, 0
    
update_letters_loop:
    call generate_random_letter
    mov [cs:ball_letters + si], al
    
    ; Get random column position
    push si
    shl si, 1
    call generate_random_column
    mov [cs:ball_cols + si], ax
    pop si
    
    inc si
    loop update_letters_loop
    
    popa
    ret

; ============ SCORE MANAGEMENT ============
increase_score:
    pusha
    
    ; Only increase score if game is active
    cmp word[lives], 0
    je convert_score
    cmp word[current_time], 0  
    je convert_score
    
    ; Add 10 points to score
    add word [cs:score], 10
    
    ; Update score display string
    mov ax, [cs:score]
    mov bx, 10
    mov cx, 3
    mov si, score_string + 8
    
convert_score:
    xor dx, dx
    div bx
    add dl, '0'
    mov [si], dl
    dec si
    loop convert_score
    
    ; Choose display position based on game state
    cmp word[lives], 0
    jne p_n
    cmp word[current_time], 0
    jne p_n
    
    push 1080              ; Game over position
    jmp kk
    
p_n:
    push 0                 ; Normal game position
    
kk: 
    push score_string
    push word [cs:score_length]
    call print
    
    popa
    ret

; Check if pressed key matches any balloon
check_balloon_pop:
    pusha
    mov al, [cs:current_key]
    cmp al, 0
    je pop_done
    
    ; Check balloon 1
    cmp al, [cs:ball_letters]
    jne check_balloon2_pop
    cmp byte [cs:balloon1_active], 1
    jne check_balloon2_pop
    
    ; Pop balloon 1
    mov byte [cs:balloon1_active], 0
    call increase_score
    
    ; Reset balloon 1
    mov word [cs:ball_rows], 23
    call generate_random_column
    mov [cs:ball_cols], ax
    call generate_random_letter
    mov [cs:ball_letters], al
    mov byte [cs:balloon1_active], 1
    jmp pop_done
    
check_balloon2_pop:
    ; Check balloon 2  
    cmp al, [cs:ball_letters + 1]
    jne check_balloon3_pop
    cmp byte [cs:balloon2_active], 1
    jne check_balloon3_pop
    
    ; Pop balloon 2
    mov byte [cs:balloon2_active], 0
    call increase_score
    
    ; Reset balloon 2
    mov word [cs:ball_rows + 2], 23
    call generate_random_column
    mov [cs:ball_cols + 2], ax
    call generate_random_letter
    mov [cs:ball_letters + 1], al
    mov byte [cs:balloon2_active], 1
    jmp pop_done
    
check_balloon3_pop:
    ; Check balloon 3
    cmp al, [cs:ball_letters + 2]
    jne pop_done
    cmp byte [cs:balloon3_active], 1
    jne pop_done
    
    ; Pop balloon 3
    mov byte [cs:balloon3_active], 0
    call increase_score
    
    ; Reset balloon 3
    mov word [cs:ball_rows + 4], 23
    call generate_random_column
    mov [cs:ball_cols + 4], ax
    call generate_random_letter
    mov [cs:ball_letters + 2], al
    mov byte [cs:balloon3_active], 1
    
pop_done:
    popa
    ret

; ============ KEYBOARD INTERRUPT ============
keyboard_isr:
    push ax
    push bx
    push es
    
    ; Skip keyboard if game over
    cmp byte[lives], 0
    je skip_keyboard
    cmp word[current_time], 0
    je skip_keyboard
    
    ; Read keyboard input
    in al, 60h
    call scan
    mov [cs:current_key], al
    call check_balloon_pop
    jmp d
    
skip_keyboard:
    mov byte[yes], 1

d:   
    ; Send end of interrupt
    mov al, 20h
    out 20h, al
    
    pop es
    pop bx
    pop ax
  
    ; Chain to old handler if needed
    cmp byte[yes], 1
    je oky 
    jmp come
    
oky:
    jmp far[cs:old_keyboard]
    
come:
    iret

; ============ MAIN GAME LOGIC ============
repeater:
    pusha
    
    ; Initialize balloons
    mov byte [cs:balloon1_active], 1
    mov byte [cs:balloon2_active], 0  
    mov byte [cs:balloon3_active], 0
    mov word [cs:spawn_timer], 0
    
    ; Set random positions
    call update_balloon_letters
    
game_loop:
    ; Check game end condition
    cmp word [cs:current_time], 0
    je end_repeater
    
    ; Clear screen for new frame
    call clear
    
    ; Spawn balloons with delays
    inc word [cs:spawn_timer]
    cmp word [cs:spawn_timer], 20
    jl check_balloons
    mov byte [cs:balloon2_active], 1
    
    cmp word [cs:spawn_timer], 40  
    jl check_balloons
    mov byte [cs:balloon3_active], 1
    
check_balloons:
    ; Balloon 1 logic
    cmp byte [cs:balloon1_active], 1
    jne check_balloon2
    
    dec word [cs:ball_rows]        ; move up
    cmp word [cs:ball_rows], 0     ; reached top?
    jne blocked
    
    ; Balloon escaped - lose life
    dec byte[lives]
    mov ax, 0xb800
    mov es, ax
    mov di, 144
    mov al, [lives]
    add al, '0'
    mov ah, 0x07
    mov [es:di], ax
    cmp byte[lives], 0
    je end_repeater
    
blocked:
    cmp word [cs:ball_rows], 0
    jg draw_balloon1
    
    ; Reset balloon
    mov word [cs:ball_rows], 23
    call generate_random_column
    mov [cs:ball_cols], ax
    call generate_random_letter
    mov [cs:ball_letters], al
    
draw_balloon1:
    mov al, [cs:ball_letters]
    mov ah, 0
    push ax
    push word [cs:ball_cols]
    push word [cs:ball_rows]
    call draw

check_balloon2:
    ; Balloon 2 logic
    cmp byte [cs:balloon2_active], 1
    jne check_balloon3
    
    dec word [cs:ball_rows + 2]
    cmp word [cs:ball_rows + 2], 0
    jne blocked2
    
    dec byte[lives]
    mov ax, 0xb800
    mov es, ax
    mov di, 144
    mov al, [lives]
    add al, '0'
    mov ah, 0x07
    mov [es:di], ax
    cmp byte[lives], 0
    je end_repeater
    
blocked2:
    cmp word [cs:ball_rows + 2], 0
    jg draw_balloon2
    
    mov word [cs:ball_rows + 2], 23
    call generate_random_column
    mov [cs:ball_cols + 2], ax
    call generate_random_letter
    mov [cs:ball_letters + 1], al
    
draw_balloon2:
    mov al, [cs:ball_letters + 1]
    mov ah, 0
    push ax
    push word [cs:ball_cols + 2]
    push word [cs:ball_rows + 2]
    call draw

check_balloon3:
    ; Balloon 3 logic
    cmp byte [cs:balloon3_active], 1
    jne update_ui
    
    dec word [cs:ball_rows + 4]
    cmp word [cs:ball_rows + 4], 0
    jne blocked3
    
    dec byte[lives]
    cmp byte[lives], 0
    je end_repeater
    
blocked3:
    cmp word [cs:ball_rows + 4], 0
    jg draw_balloon3
    
    mov word [cs:ball_rows + 4], 23
    call generate_random_column
    mov [cs:ball_cols + 4], ax
    call generate_random_letter
    mov [cs:ball_letters + 2], al
    
draw_balloon3:
    mov al, [cs:ball_letters + 2]
    mov ah, 0
    push ax
    push word [cs:ball_cols + 4]
    push word [cs:ball_rows + 4]
    call draw

update_ui:
    ; Display score and time
    push 0
    push score_string
    push word [score_length]
    call print
    
    push 40
    push inst1
    push word [size1]
    call print
    
    ; Frame delay
    call delay
    
    jmp game_loop

end_repeater:
    ; Update lives display
    mov ax, 0xb800
    mov es, ax
    mov di, 144
    mov al, 0x20
    mov ah, 0x4F
    mov [es:di], ax
    popa
    ret

; ============ PROGRAM START ============
start:
    call starter
    
key:   
    ; Wait for spacebar to start
    mov ah, 0
    int 16h
    cmp ah, 0x01        ; Escape key
    je end
    cmp ah, 0x39        ; Spacebar
    jne key

    ; Initialize game
    call clear  
    xor ax, ax
    mov es, ax
    
    ; Save old interrupt vectors
    mov ax, [es:8*4]
    mov word [cs:old], ax
    mov ax, [es:8*4+2]
    mov word [cs:old+2], ax
    
    mov ax, [es:9*4]
    mov word [cs:old_keyboard], ax
    mov ax, [es:9*4+2]
    mov word [cs:old_keyboard+2], ax
    
    ; Install new interrupt handlers
    cli 
    mov word [es:8*4], timer   
    mov word [es:8*4+2], cs
    
    mov word [es:9*4], keyboard_isr
    mov word [es:9*4+2], cs
    sti
    
    ; Initialize game state
    mov word [cs:score], 0
    mov byte [score_string + 6], '0'
    mov byte [score_string + 7], '0'
    mov byte [score_string + 8], '0'
    call update_balloon_letters
    
    ; Clear and setup screen
    call clear_first
    
    ; Display UI elements
    push 0
    push score_string
    push word [score_length]
    call print
    
    push 40
    push inst1
    push word [size1]
    call print

    push 66
    push message
    push 6
    call print

    ; Show initial lives
    mov ax, 0xb800
    mov es, ax
    mov di, 144
    mov al, [lives]
    add al, '0'
    mov ah, 0x07
    mov [es:di], ax
    
    ; Start game loop
    call repeater
    call delay

    ; Game over sequence
    call game_end
    call delay

    ; Show final score
    push 996
    push score_string
    push word [score_length]
    call print

    call delay
   
    ; Restore original interrupts
    mov word [cs:done], 1
    mov ax, [cs:old]
    mov [es:8*4], ax
    mov ax, [cs:old+2]
    mov [es:8*4+2], ax
    
    mov ax, [cs:old_keyboard]
    mov [es:9*4], ax
    mov ax, [cs:old_keyboard+2]
    mov [es:9*4+2], ax

end:
    ; Exit to DOS
    mov ax, 0x4c00
    int 0x21
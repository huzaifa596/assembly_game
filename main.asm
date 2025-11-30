;L24-0695 -> Huzaifa Naseer
;L24-0744 -> Zain Khan 

;-------------------------------------
[org 0x0100]
jmp start

; ==================== FUNCTION INCLUDES ====================
%include "draw.asm"
%include "clear.asm"
%include "delay.asm"
%include "start.asm"
%include "print.asm"
%include "keyboard.asm"
%include "timer.asm"
; ==================== RANDOM NUMBER GENERATION ====================
; Better random number generator (returns 0-255 in AL)
generate_random:
    push bx
    push dx
    
    ; Improved LCG with better parameters
    mov ax, [cs:random_seed]
    mov bx, 13645
    mul bx
    add ax, 15873
    mov [cs:random_seed], ax
    
    ; Use the high byte for more randomness
    mov al, ah
    
    pop dx
    pop bx
    ret

; Generate random letter A-Z
generate_random_letter:
    push bx
    push dx
    
    call generate_random
    and al, 31          ; 0-31 range
    cmp al, 26
    jb letter_ok
    sub al, 6           ; if 26-31, make it 20-25
letter_ok:
    add al, 'A'         ; convert to 'A'-'Z'
    
    pop dx
    pop bx
    ret

; Generate random column (20-75) with collision avoidance
generate_random_column:
    push bx
    push cx
    push si
    
try_new_column:
    call generate_random
    and ax, 55          ; 0-55 range
    add ax, 20          ; 20-75 range
    
    ; Check collision with existing balloons (8 columns apart)
    mov cx, BALL_COUNT
    mov si, 0

check_collision_loop:
    cmp word [cs:ball_cols + si], 0
    je next_balloon_check
    
    mov bx, [cs:ball_cols + si]
    sub bx, ax
    jns positive_diff
    neg bx
positive_diff:
    cmp bx, 8           ; need at least 8 columns apart
    jl try_new_column   ; too close, try again
    
next_balloon_check:
    add si, 2
    loop check_collision_loop
    
    
    pop si
    pop cx
    pop bx
    ret

; Function to update all balloon letters and positions with random ones
update_balloon_letters:
    pusha
    mov cx, BALL_COUNT
    mov si, 0
    
update_letters_loop:
    call generate_random_letter
    mov [cs:ball_letters + si], al  ; store new random letter
    
    ; Also update random column position
    push si
    shl si, 1                      ; convert to word index
    call generate_random_column
    mov [cs:ball_cols + si], ax    ; store random column
    pop si
    
    inc si
    loop update_letters_loop
    popa
    ret

; ==================== SCORE MANAGEMENT ====================
; Increase score by 10 and update display
increase_score:
    pusha
    
    ; Increase score by 10
    add word [cs:score], 10
    
    ; Update score string
    mov ax, [cs:score]
    mov bx, 10
    mov cx, 3           ; We want 3 digits
    mov si, score_string + 8  ; point to last digit position
    
convert_score:
    xor dx, dx
    div bx              ; AX = quotient, DX = remainder
    add dl, '0'         ; convert to ASCII
    mov [si], dl        ; store digit
    dec si
    loop convert_score
    
    ; Update score display immediately
    push 0
    push score_string
    push word [cs:score_length]
    call print
    
    popa
    ret

; Check if pressed key matches any balloon letter
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
    ; Immediately reset balloon 1
    mov word [cs:ball_rows], 23    ; reset to bottom
    call generate_random_column    ; new random position
    mov [cs:ball_cols], ax
    call generate_random_letter    ; new random letter
    mov [cs:ball_letters], al
    mov byte [cs:balloon1_active], 1  ; reactivate
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
    ; Immediately reset balloon 2
    mov word [cs:ball_rows + 2], 23 ; reset to bottom
    call generate_random_column    ; new random position
    mov [cs:ball_cols + 2], ax
    call generate_random_letter    ; new random letter
    mov [cs:ball_letters + 1], al
    mov byte [cs:balloon2_active], 1  ; reactivate
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
    ; Immediately reset balloon 3
    mov word [cs:ball_rows + 4], 23 ; reset to bottom
    call generate_random_column    ; new random position
    mov [cs:ball_cols + 4], ax
    call generate_random_letter    ; new random letter
    mov [cs:ball_letters + 2], al
    mov byte [cs:balloon3_active], 1  ; reactivate
    
pop_done:
    popa
    ret

; ==================== KEYBOARD INTERRUPT HANDLER ====================
; Keyboard interrupt handler (INT 9)
keyboard_isr:
    push ax
    push bx
    push es
    
    ; Read keyboard scan code
    in al, 60h
    
   
    
    ; Convert scan code to ASCII
    call scan_to_ascii
    mov [cs:current_key], al
    
    ; Check if it matches any balloon letter
    call check_balloon_pop
    

    
    ; Send EOI to PIC
    mov al, 20h
    out 20h, al
    
    pop es
    pop bx
    pop ax
    iret



; ==================== GAME LOGIC ====================
repeater:
    pusha
    
    ; Initialize balloon states and random positions
    mov byte [cs:balloon1_active], 1
    mov byte [cs:balloon2_active], 0  
    mov byte [cs:balloon3_active], 0
    mov word [cs:spawn_timer], 0
    
    ; Initialize random positions for all balloons
    call update_balloon_letters
    
game_loop:
    ; Check if game should end
    cmp word [cs:current_time], 0
    jle end_repeater
    
    ; CLEAR ENTIRE SCREEN each frame
    call clear
    
    ; Update spawn timer and activate balloons with delay
    inc word [cs:spawn_timer]
    cmp word [cs:spawn_timer], 20  ; ~1 second delay
    jl check_balloons
    mov byte [cs:balloon2_active], 1
    
    cmp word [cs:spawn_timer], 40  ; ~2 second delay  
    jl check_balloons
    mov byte [cs:balloon3_active], 1
    
check_balloons:
    ; Update and draw balloon 1 (always active)
    cmp byte [cs:balloon1_active], 1
    jne check_balloon2
    
    dec word [cs:ball_rows]        ; move balloon 1 up
    cmp word [cs:ball_rows], 0     ; check if reached top (row 1)
    jg draw_balloon1
    ; Reset balloon 1 if it reaches top
    mov word [cs:ball_rows], 23    ; reset to bottom
    call generate_random_column    ; new random position
    mov [cs:ball_cols], ax
    call generate_random_letter    ; new random letter
    mov [cs:ball_letters], al
    
draw_balloon1:
    mov al, [cs:ball_letters]      ; get random letter for balloon 1
    mov ah, 0
    push ax                        ; push letter
    push word [cs:ball_cols]       ; column
    push word [cs:ball_rows]       ; row
    call draw

check_balloon2:
    ; Update and draw balloon 2 (activated after delay)
    cmp byte [cs:balloon2_active], 1
    jne check_balloon3
    
    dec word [cs:ball_rows + 2]    ; move balloon 2 up
    cmp word [cs:ball_rows + 2], 0 ; check if reached top (row 1)
    jg draw_balloon2
    ; Reset balloon 2 if it reaches top
    mov word [cs:ball_rows + 2], 23 ; reset to bottom
    call generate_random_column    ; new random position
    mov [cs:ball_cols + 2], ax
    call generate_random_letter    ; new random letter
    mov [cs:ball_letters + 1], al
    
draw_balloon2:
    mov al, [cs:ball_letters + 1]  ; get random letter for balloon 2
    mov ah, 0
    push ax                        ; push letter
    push word [cs:ball_cols + 2]   ; column
    push word [cs:ball_rows + 2]   ; row
    call draw

check_balloon3:
    ; Update and draw balloon 3 (activated after longer delay)
    cmp byte [cs:balloon3_active], 1
    jne update_ui
    
    dec word [cs:ball_rows + 4]    ; move balloon 3 up
    cmp word [cs:ball_rows + 4], 0 ; check if reached top (row 1)
    jg draw_balloon3
    ; Reset balloon 3 if it reaches top
    mov word [cs:ball_rows + 4], 23 ; reset to bottom
    call generate_random_column    ; new random position
    mov [cs:ball_cols + 4], ax
    call generate_random_letter    ; new random letter
    mov [cs:ball_letters + 2], al
    
draw_balloon3:
    mov al, [cs:ball_letters + 2]  ; get random letter for balloon 3
    mov ah, 0
    push ax                        ; push letter
    push word [cs:ball_cols + 4]   ; column
    push word [cs:ball_rows + 4]   ; row
    call draw

update_ui:
    ; Update UI (score and time)
    push 0                 ; position for score
    push score_string      ; "Score:000" string  
    push word [score_length] ; score string length
    call print
    
    push 40                ; position for time label
    push inst1             ; "Time:" string
    push word [size1]      ; time string length  
    call print
    
    ; Delay between frames
    call delay
    
    jmp game_loop

end_repeater:
    popa
    ret

; ==================== MAIN PROGRAM ====================
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
    
    ; Save old interrupts
    mov ax, [es:8*4]
    mov word [cs:old], ax
    mov ax, [es:8*4+2]
    mov word [cs:old+2], ax
    
    mov ax, [es:9*4]
    mov word [cs:old_keyboard], ax
    mov ax, [es:9*4+2]
    mov word [cs:old_keyboard+2], ax
    
    ; Set up interrupts
    cli 
    mov word [es:8*4], timer   
    mov word [es:8*4+2], cs
    
    mov word [es:9*4], keyboard_isr
    mov word [es:9*4+2], cs
    sti
    
    ; Initialize game state
    mov word [cs:score], 0
    ; Initialize score string to "Score:000"
    mov byte [score_string + 6], '0'
    mov byte [score_string + 7], '0'
    mov byte [score_string + 8], '0'
    call update_balloon_letters
    
    ; Print initial UI
    push 0
    push score_string
    push word [score_length]
    call print
    
    push 40
    push inst1
    push word [size1]
    call print
    
    ; Start balloon animation
    call repeater
     
     


    ; Restore interrupts when done
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
    mov ax, 0x4c00
    int 0x21
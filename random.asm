; Add after your existing data
%Include"main.asm"
ball_letters:   db 'A','B','C'     ; Current letters in balloons
random_seed:    dw 1234            ; Seed for random number generation

; Random letter generator (returns random A-Z in AL)
generate_random_letter:
    push bx
    push dx
    
    ; Simple LCG random number generator
    mov ax, [cs:random_seed]
    mov bx, 25173
    mul bx
    add ax, 13849
    mov [cs:random_seed], ax
    
    ; Convert to A-Z (0-25) + 'A'
    xor dx, dx
    mov bx, 26           ; range 0-25
    div bx               ; DX = random(0-25)
    mov al, dl
    add al, 'A'          ; convert to 'A'-'Z'
    
    pop dx
    pop bx
    ret

; Function to update all balloon letters with new random ones
update_balloon_letters:
    pusha
    mov cx, BALL_COUNT
    mov si, 0
    
update_letters_loop:
    call generate_random_letter
    mov [cs:ball_letters + si], al  ; store new random letter
    inc si
    loop update_letters_loop
    popa
    ret
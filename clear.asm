; function to clear the screen
clear:
    push ax
    push es
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    mov di, 160
        
    ; first line (white)       
    ; mov cx, 80
    ; mov ax, 0x0720
    ; rep stosw
    
    ; blue color printing
    mov cx, 1600
    mov ax, 0x1F20  ; Changed from 0xBF20 to 0x1F20 (blue on blue was hard to see)
    rep stosw
    
    ; green color printing
    mov cx, 320
    mov ax, 0x2A20  ; Changed from 0xA020 to 0x2A20 (green on green)
    rep stosw

    pop cx
    pop di
    pop es
    pop ax
    ret
; function to clear a single balloon (preserves background)
; function to clear a single balloon (exact match to draw.asm)
clear_balloon:
    push bp
    mov bp, sp
    push es
    push di
    push ax
    push cx
    push dx
    push bx

    mov ax, 0xb800
    mov es, ax
    
    ; Calculate starting position (top-left of balloon)
    mov ax, 80
    mul word [bp+4]       ; row * 80
    add ax, [bp+6]        ; + column
    shl ax, 1             ; * 2 for video memory
    mov di, ax

    ; Determine background color based on row position
    mov bx, 0x1F20        ; default to blue (sky)
    cmp word [bp+4], 20   ; check if in ground area
    jle clear_balloon_graphics
    mov bx, 0x2A20        ; green (ground)

clear_balloon_graphics:
    ; Clear the balloon outline (3 rows high, 5 columns wide)
    
    ; Row 1: clear positions [di], [di+2], [di+4], [di+6], [di+8]
    mov cx, 5
    mov dx, di            ; save starting position
clear_row1:
    mov [es:di], bx       ; clear with correct background
    add di, 2
    loop clear_row1
    
    ; Row 2: starting at di+160
    mov di, dx
    add di, 160
    mov cx, 5
clear_row2:
    mov [es:di], bx
    add di, 2
    loop clear_row2
    
    ; Row 3: starting at di+160 (from row1)
    mov di, dx
    add di, 320
    mov cx, 5
clear_row3:
    mov [es:di], bx
    add di, 2
    loop clear_row3

    ; Clear the strings underneath (2 diagonal positions)
    ; First string position: original row + 4, original col
    mov di, dx            ; restore original position
    add di, 640           ; 4 rows down (4 * 160)
    mov [es:di], bx       ; clear first string character
    
    ; Second string position: original row + 5, original col + 1
    add di, 162           ; down 1 row (+160) and right 1 column (+2)
    mov [es:di], bx       ; clear second string character

    pop bx
    pop dx
    pop cx
    pop ax
    pop di
    pop es
    pop bp
    ret 6
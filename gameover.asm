[org 0x0100]
jmp game_end

l1 db '  ####     ##    #        #   #####      ####     ##   ##  #####  ####  ',0
l2 db ' ##       ## ##  ##      ##   #         ##  ##    ##   ##  ##     ##  ## ',0
l3 db ' ##  ###  #####  # #    # #   ####     ##   ##    ##   ##  ####   ####   ',0
l4 db ' ##   ##  ##  ## #  #  #  #   #         ##  ##     ## ##   ##     ## ##  ',0
l5 db '  #####   ##  ## #   ##   #   #####      ####       ###    #####  ##  ## ',0


clearscreen:
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov ax, 0x0720
q:
    mov [es:di], ax
    add di, 2
    cmp di, 4000
    jne q
    pop di
    pop ax
    ret

line_mover:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di 
    push si
    
    mov cx, 5           
    mov bx, 0          
    
print_lines:
    
    mov ax, 6           
    add ax, bx          
    mov dx, 160         
    mul dx              
    add ax, 12              
    
    mov si, bx         
    shl si, 1           
    add si, 4           
    mov dx, [bp+si]     
    
   
    push dx            
    push ax             
    call gameover
    
    inc bx           
    loop print_lines
    
    pop si 
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 10

gameover:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di 
    push si
    
    mov ax, 0xb800
    mov es, ax
    
    mov di, [bp+4]      
    mov si, [bp+6]      
    
next_char:
    mov al, [si]        
    cmp al, 0           
    je done_printing
    cmp al,'#'
    je print_new
    mov ah, 0x07       
    mov [es:di], ax     
    add di, 2           
    inc si            
    jmp next_char

done_printing:
    pop si 
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 4

print_new:

mov ah,0x09
mov al,219
mov [es:di],ax
add di,2
inc si
jmp next_char

game_end:
    call clearscreen
    
    
    mov ax, l5
    push ax
    mov ax, l4
    push ax
    mov ax, l3
    push ax
    mov ax, l2
    push ax
    mov ax, l1
    push ax
    
    call line_mover

ret    
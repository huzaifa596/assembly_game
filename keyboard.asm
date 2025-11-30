
; Convert scan code to ASCII (simple version for A-Z)
scan_to_ascii:
    cmp al, 0x1E        ; A key
    jne check_b
    mov al, 'A'
    ret
check_b:
    cmp al, 0x30        ; B key
    jne check_c
    mov al, 'B'
    ret
check_c:
    cmp al, 0x2E        ; C key
    jne check_d
    mov al, 'C'
    ret
check_d:
    cmp al, 0x20        ; D key
    jne check_e
    mov al, 'D'
    ret
check_e:
    cmp al, 0x12        ; E key
    jne check_f
    mov al, 'E'
    ret
check_f:
    cmp al, 0x21        ; F key
    jne check_g
    mov al, 'F'
    ret
check_g:
    cmp al, 0x22        ; G key
    jne check_h
    mov al, 'G'
    ret
check_h:
    cmp al, 0x23        ; H key
    jne check_i
    mov al, 'H'
    ret
check_i:
    cmp al, 0x17        ; I key
    jne check_j
    mov al, 'I'
    ret
check_j:
    cmp al, 0x24        ; J key
    jne check_k
    mov al, 'J'
    ret
check_k:
    cmp al, 0x25        ; K key
    jne check_l
    mov al, 'K'
    ret
check_l:
    cmp al, 0x26        ; L key
    jne check_m
    mov al, 'L'
    ret
check_m:
    cmp al, 0x32        ; M key
    jne check_n
    mov al, 'M'
    ret
check_n:
    cmp al, 0x31        ; N key
    jne check_o
    mov al, 'N'
    ret
check_o:
    cmp al, 0x18        ; O key
    jne check_p
    mov al, 'O'
    ret
check_p:
    cmp al, 0x19        ; P key
    jne check_q
    mov al, 'P'
    ret
check_q:
    cmp al, 0x10        ; Q key
    jne check_r
    mov al, 'Q'
    ret
check_r:
    cmp al, 0x13        ; R key
    jne check_s
    mov al, 'R'
    ret
check_s:
    cmp al, 0x1F        ; S key
    jne check_t
    mov al, 'S'
    ret
check_t:
    cmp al, 0x14        ; T key
    jne check_u
    mov al, 'T'
    ret
check_u:
    cmp al, 0x16        ; U key
    jne check_v
    mov al, 'U'
    ret
check_v:
    cmp al, 0x2F        ; V key
    jne check_w
    mov al, 'V'
    ret
check_w:
    cmp al, 0x11        ; W key
    jne check_x
    mov al, 'W'
    ret
check_x:
    cmp al, 0x2D        ; X key
    jne check_y
    mov al, 'X'
    ret
check_y:
    cmp al, 0x15        ; Y key
    jne check_z
    mov al, 'Y'
    ret
check_z:
    cmp al, 0x2C        ; Z key
    jne no_match
    mov al, 'Z'
    ret

no_match:
    mov al, 0           ; No valid letter
    ret


count: dw 3

; ==================== DATA SECTION ====================
ball_rows:      dw 24, 24, 24      ; Starting rows for 3 balloons
ball_cols:      dw 0, 0, 0         ; Will be filled with random columns
ball_letters:   db 'A','B','C'     ; Current random letters in balloons
random:    dw 1234          ;  random number generation

; Keyboard and game state variables
old_keyboard:   dd 0
current_key:    db 0
score:          dw 0
score_string:   db 'Score:000$' 
score_s:   db 'Score:$'    ; Fixed: Added space for 3 digits + terminator
score_length:   dw 9

; Game control variables
balloon1_active: db 1
balloon2_active: db 0  
balloon3_active: db 0
spawn_timer: dw 0

; UI strings
inst: db 'Score:'
inst1: db 'Time:'
size: dw 7
size1: dw 5
old: dd 0
done: dw 0
tick: dw 0
current_time: dw 60  ; Start from 60


lives:db 3
message db "Lives:"


yes : db 0 ; for keyboard isr
BITS 16
ORG 0x1000      ; kernel loads at 0x1000

start:

    cli                   ; disable interrupts

    ; initialize segments and stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000        ; safe kernel stack

    sti                   ; enable interrupts

    ; clear screen and print welcome message
    call cls
    mov si, msg
    call print
    call newline

    ; initialize input pointer
    mov di, input_buffer

    jmp shell_loop        ; enter shell loop


; SHELL LOOP
shell_loop:
    mov ah, 0x00
    int 0x16            ; wait for key

    cmp al, 0x0D       ; Enter
    je handle_enter

    cmp al, 0x08       ; Backspace
    je handle_backspace

    ; echo character
    mov ah, 0x0E
    int 0x10

    ; store in buffer
    mov [di], al
    inc di

    jmp shell_loop


; ENTER KEY HANDLER
handle_enter:
    mov byte [di], 0        ; null terminate string

    ; compare buffer with "cls"
    mov si, input_buffer
    mov di, cmd_cls
    call strcmp
    cmp al, 1
    je do_cls

    ; compare buffer with "echo"
    mov si, input_buffer
    mov di, cmd_echo
    call is_echo
    cmp al, 1
    je do_echo

    call newline
    mov di, input_buffer
    jmp shell_loop


; CLS COMMAND
do_cls:
    call cls
    mov di, input_buffer
    jmp shell_loop


; ECHO COMMAND
is_echo:
    mov si, input_buffer
    mov di, cmd_echo
    mov cx, 4
.compare_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    inc si
    inc di
    loop .compare_loop
    mov al,1
    ret
.not_equal:
    mov al,0
    ret

do_echo:
    call newline
    mov si, input_buffer
    add si, 5   ; skip "echo "
.print_echo:
    lodsb
    cmp al, 0
    je .done_echo
    mov ah, 0x0E
    int 0x10
    jmp .print_echo
.done_echo:
    call newline
    mov di, input_buffer
    jmp shell_loop


; BACKSPACE HANDLER
handle_backspace:
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10

    dec di
    jmp shell_loop


; CLEAR SCREEN ROUTINE
cls:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10

    mov ah, 0x02
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10
    ret


; PRINT ROUTINE
print:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret


; STRING COMPARE
strcmp:
    push si
    push di
.compare:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc si
    inc di
    jmp .compare
.equal:
    pop di
    pop si
    mov al,1
    ret
.not_equal:
    pop di
    pop si
    mov al,0
    ret


; NEWLINE ROUTINE
newline:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

; DATA
msg db "Welcome to TinyOS Kernel! -^OwO^-",0x0D,0x0A,0
input_buffer times 32 db 0
cmd_cls db "cls",0
cmd_echo db "echo",0


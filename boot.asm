BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Read kernel from disk
    mov ah, 0x02        ; BIOS read sectors
    mov al, 10          ; number of sectors
    mov ch, 0           ; cylinder
    mov cl, 2           ; sector (boot = 1, kernel = 2)
    mov dh, 0           ; head
    mov dl, 0x80        ; first hard disk
    mov bx, 0x1000      ; load address
    int 0x13

    jc disk_error

    jmp 0x0000:0x1000   ; jump to kernel

disk_error:
    mov si, err
.print:
    lodsb
    cmp al, 0
    je $
    mov ah, 0x0E
    int 0x10
    jmp .print

err db "DISK READ ERROR", 0

times 510-($-$$) db 0
dw 0xAA55

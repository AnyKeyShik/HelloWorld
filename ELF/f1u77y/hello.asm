; nasm -f bin -o hello hello.asm

BITS 32
    org 0x00010000

    db 0x7F, "ELF"             ; e_ident
    dd 1                                       ; p_type
    dd 0                                       ; p_offset
    dd $$                                      ; p_vaddr 
    dw 2                       ; e_type        ; p_paddr
    dw 3                       ; e_machine
    dd _start                  ; e_version     ; p_filesz
    dd _start                  ; e_entry       ; p_memsz
    dd 4                       ; e_phoff       ; p_flags
_cont:
    mov dl, len                ; e_shoff       ; p_align
    int 0x80                    
    mov al, 1                  ; e_flags
    xor bl,bl
    int 0x80                   ; e_ehsize
    dw 0x20                    ; e_phentsize
    dw 1                       ; e_phnum
_start:
    mov al, 04                 ; e_shentsize
    mov bl, 01                 ; e_shnum
    mov ecx, msg               ; e_shstrndx
    jmp _cont                   

msg: db "Hello world!"
len equ $ - msg

; nasm -g -f elf64 -o hello.o hello.s
; ld -static -z norelro -z noseparate-code -s -x -o hello hello.o
 
global _start
 
x:
db "Hello, world!", 0Ah, 0
 
_start:
    mov al, 1
    mov dil, 1
    mov rsi, x
    mov dl, 15
    syscall
    mov al, 60
    mov dil, 0
    syscall

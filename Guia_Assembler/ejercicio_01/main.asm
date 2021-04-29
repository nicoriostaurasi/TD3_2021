section .data
   primer_mensaje db 'Ejercicio 1',10 ;
   lenpm equ $-primer_mensaje          
   pid_ascii db '0123456789'
   lenpid equ $-pid_ascii
   mensaje db 'llegue aca',10
   lenmsj equ $-mensaje
   aviso_pid db 'Hola mi PID es:'
   lenaviso equ $-aviso_pid
   sdoAviso db 10,'Me voy a dormir unos segundos..',10
   len2doAviso equ $-sdoAviso
   chauchau db 'Aca estoy despierto otra vez.... saliendo... adios!!',10
   lenchauchau equ $-chauchau
timeval:
    tv_sec  dd 0
    tv_usec dd 0
    
global _start
section .text
_start:
    xor rax,rax
    xor rbx,rbx
    xor rcx,rcx
    xor rdx,rdx

    mov rcx, primer_mensaje
    mov rdx, lenpm
    call print

    xor rdx,rdx
    xor rcx,rcx
    
    mov rax,20
    int 0x80


    mov rbx,10

ciclo_div:
    mov rdx,0
    div rbx
    push rdx
    inc rcx
    cmp rax,0
    jne ciclo_div


    push rcx
    mov rcx, aviso_pid
    mov rdx, lenaviso
    call print
    pop rcx

jmp ciclo_print

fin_ciclo_print:

    mov rcx,sdoAviso
    mov rdx,len2doAviso
    call print

    mov dword [tv_sec], 2
    mov dword [tv_usec], 0
    mov eax, 162
    mov ebx, timeval
    mov ecx, 0
    int 0x80

    mov rcx,chauchau
    mov rdx,lenchauchau
    call print

fin:
    mov	rax,1		; system call number (sys_exit)
    int	0x80		; call kernel

print:
    push rax
    push rbx
    mov rax, 4
    mov rbx, 1
    int 0x80
    pop rbx
    pop rax
    ret

print_dummy:
    push rcx
    push rdx
    mov rcx, mensaje
    mov rdx, lenmsj
    call print
    pop rdx
    pop rcx
    ret

print_0:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+0
    call print
    pop rdx
    pop rcx
    ret

print_1:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+1
    call print
    pop rdx
    pop rcx
    ret
print_2:

    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+2
    call print
    pop rdx
    pop rcx
    ret

print_3:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+3
    call print
    pop rdx
    pop rcx
    ret

print_4:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+4
    call print
    pop rdx
    pop rcx
    ret

print_5:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+5
    call print
    pop rdx
    pop rcx
    ret

print_6:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+6
    call print
    pop rdx
    pop rcx
    ret

print_7:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+7
    call print
    pop rdx
    pop rcx
    ret

print_8:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+8
    call print
    pop rdx
    pop rcx
    ret

print_9:
    push rcx
    push rdx
    mov rdx,1
    mov rcx,pid_ascii+9
    call print
    pop rdx
    pop rcx
    ret

ciclo_print:
    dec rcx
    pop rdx
    
pr0:
    cmp rdx,0
    jne pr1
    call print_0
pr1:
    cmp rdx,1
    jne pr2
    call print_1
pr2:
    cmp rdx,2
    jne pr3
    call print_2
pr3:
    cmp rdx,3
    jne pr4
    call print_3
pr4:
    cmp rdx,4
    jne pr5
    call print_4
pr5:
    cmp rdx,5
    jne pr6
    call print_5
pr6:
    cmp rdx,6
    jne pr7
    call print_6
pr7:
    cmp rdx,7
    jne pr8
    call print_7
pr8:
    cmp rdx,8
    jne pr9
    call print_8
pr9:
    cmp rdx,9
    jne continua
    call print_9

continua:
    cmp rcx,0
    jne ciclo_print

    jmp fin_ciclo_print   
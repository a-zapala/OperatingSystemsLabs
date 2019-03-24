global euron
extern get_value, put_value

section .data
section .bss
section .text
euron:
    push rbp        ;saved on stack callee-saved register
    push r12        ;number of euron
    push r13        ;pointer to current char in string
    mov rbp, rsp

    mov r12, rdi    ;number of euron
    mov r13, rsi    ;pointer to string

    dec r13

read_loop:
    inc r13
    movzx rcx , byte [r13]      ;rcx current sign in ASII

    test rcx, rcx               ;read '\0' end of string
    jz exit

                                ;read 0..9 number
    cmp rcx, 0x30               ;0 in ASCII
    jl plus
    cmp rcx, 0x39               ;9 in ASCII
    jg _E
    sub rcx, 0x30               ;change char to number
    push rcx
    jmp read_loop

plus:                           ;posibilities +,-,*
    cmp rcx, 0x2b               ;'+' in ASCII
    jg minus
    pop rax
    pop rdx
    jl asterix
    add rax, rdx
    push rax
    jmp read_loop
minus:
    mov rax, [rsp]
    neg rax
    mov [rsp], rax
    jmp read_loop
asterix:
    imul rax, rdx
    push rax
    jmp read_loop

_E:                             ;posibilities B,C,D,E,G,P,S,n
    cmp rcx, 0x45               ;'E' in ASCII
    jl _C
    jg _P
    mov rcx, [rsp]
    mov rax, [rsp + 8]
    mov [rsp], rax
    mov [rsp + 8], rcx
    jmp read_loop

_C:                             ;posibilities B,C,D
    cmp rcx, 0x43               ;'C' in ASCII
    jl _B
    jg _D
    add rsp, 8                  ;pop withou saving
    jmp read_loop
_D:
    mov rax, [rsp]
    push rax
    jmp read_loop
_B:
    pop rcx
    mov rax, [rsp]
    test rax, rax
    jz read_loop
    add r13, rcx
    jmp read_loop
_P:                             ;posibilities G,P,S,n
    cmp rcx, 0x50
    jl _G
    jg _S
    pop rsi
    mov rdi, r12
    call put_value
    jmp read_loop
_G:
    cmp rcx, 0x47
    jne _E
    mov rdi, r12
    call get_value
    push rax
    jmp read_loop

_S:
    cmp rcx, 0x53               ;'S' in ASCII
    jne _n
    jmp read_loop
_n:
    push r12
    jmp read_loop
exit:
    pop rax
    mov rsp, rbp
    pop r13
    pop r12
    pop rbp
    ret
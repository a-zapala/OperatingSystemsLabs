global euron
extern get_value, put_value

section .data

access TIMES N dq 0xffffffff

section .bss
to_exchange resq N

section .text
euron:
    push rbp        ;saved on stack callee-saved register
    push r12        ;number of euron
    push r13        ;pointer to current char in string
    push r14        ;using to allinge stack before calling
    mov rbp, rsp

    mov r12, rdi    ;number of euron
    mov r13, rsi    ;pointer to string

    lea rcx, [rel access]
    lea rcx, [rcx + 8*r12]
    mov [rcx], r12              ; change acces to my own field

    dec r13
    ;to find instruction, i use binary search through ASCII numbers
read_loop:
    inc r13
    movzx rcx , byte [r13]      ;rcx current sign in ASII

    test rcx, rcx               ;read '\0' end of string
    jz exit

    cmp rcx, '0'         ;read 0..9 number
    jl _plus
    cmp rcx, '9'
    jg _E
    sub rcx, '0'         ;change char to number
    push rcx
    jmp read_loop
_plus:                          ;posibilities +,-,*
    cmp rcx, '+'
    jg _minus
    pop rax
    pop rdx
    jl _asterix
    add rax, rdx
    push rax
    jmp read_loop
_minus:
    mov rax, [rsp]
    neg rax
    mov [rsp], rax
    jmp read_loop
_asterix:
    imul rax, rdx
    push rax
    jmp read_loop
_E:                             ;posibilities B,C,D,E,G,P,S,n
    cmp rcx, 'E'
    jl _C
    jg _P
    mov rcx, [rsp]
    mov rax, [rsp + 8]
    mov [rsp], rax
    mov [rsp + 8], rcx
    jmp read_loop
_C:                             ;posibilities B,C,D
    cmp rcx, 'C'
    jl _B
    jg _D
    add rsp, 8                  ;pop without saving
    jmp read_loop
_D:
    push qword [rsp]
    jmp read_loop
_B:
    pop rcx
    cmp qword [rsp], 0
    jz read_loop
    add r13, rcx
    jmp read_loop
_P:                             ;posibilities G,P,S,n
    cmp rcx, 'P'
    jl _G
    jg _S
    pop rsi
    mov rdi, r12
    mov r14, rsp
    and rsp, -16        ;allign stack before calling put_value
    call put_value
    mov rsp, r14
    jmp read_loop
_G:
    cmp rcx, 'G'
    jne _E
    mov rdi, r12
    mov r14, rsp
    and rsp, -16
    call get_value
    mov rsp, r14
    push rax
    jmp read_loop
_n:
    push r12
    jmp read_loop
_S:
    cmp rcx, 'S'
    jne _n

    lea rcx, [rel access]
    lea rcx, [rcx + 8*r12]
    lea rdx, [rel to_exchange]
    lea rdx, [rdx + 8*r12]
busy_wait:
    cmp [rcx], r12
    jne busy_wait

    pop rsi                 ; number euron to echange
    pop qword [rdx]         ; value to exchange
    mov [rcx], rsi

    lea rcx, [rel access]
    lea rcx, [rcx + 8*rsi]
    lea rdx, [rel to_exchange]
    lea rdx, [rdx + 8*rsi]
busy_wait_2:
    cmp [rcx], r12
    jne busy_wait_2

    push qword [rdx]
    mov [rcx], rsi
    jmp read_loop
exit:
    pop rax
    mov rsp, rbp
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
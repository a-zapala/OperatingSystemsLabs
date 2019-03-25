global euron
extern get_value, put_value

section .data
zero_ASCII equ 0x30
nine_ASCII equ 0x39
plus_ASCII equ 0x2b
E_ASCII    equ 0x45
C_ASCII    equ 0x43
P_ASCII    equ 0x50
G_ASCII    equ 0x47
S_ASCII    equ 0x53

acces TIMES N dq 0xffffffff      ; TODO change for generating growing sequence

section .bss
to_exchange resq N
spin_locks resb N

section .text
euron:
    push rbp        ;saved on stack callee-saved register
    push r12        ;number of euron
    push r13        ;pointer to current char in string
    mov rbp, rsp

    mov r12, rdi    ;number of euron
    mov r13, rsi    ;pointer to string

    lea rcx, [rel acces]
    lea rcx, [rcx + 8*r12]
    mov [rcx], r12              ; change acces to my own field

    dec r13

    ;to find instruction, i use binary search through ASCII numbers
read_loop:
    inc r13
    movzx rcx , byte [r13]      ;rcx current sign in ASII

    test rcx, rcx               ;read '\0' end of string
    jz exit

    cmp rcx, zero_ASCII         ;read 0..9 number
    jl _plus
    cmp rcx, nine_ASCII
    jg _E
    sub rcx, zero_ASCII         ;change char to number
    push rcx
    jmp read_loop
_plus:                          ;posibilities +,-,*
    cmp rcx, plus_ASCII
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
    cmp rcx, E_ASCII
    jl _C
    jg _P
    mov rcx, [rsp]
    mov rax, [rsp + 8]
    mov [rsp], rax
    mov [rsp + 8], rcx
    jmp read_loop
_C:                             ;posibilities B,C,D
    cmp rcx, C_ASCII
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
    cmp rcx, P_ASCII
    jl _G
    jg _S
    pop rsi
    mov rdi, r12
    call put_value
    jmp read_loop
_G:
    cmp rcx, G_ASCII
    jne _E
    mov rdi, r12
    call get_value
    push rax
    jmp read_loop
_n:
    push r12
    jmp read_loop

busy_wait:
    xchg [rdi],al
    test al, al
    jnz busy_wait
    cmp [rcx], r12
    je wait_end
    xchg [rdi],al
    jne busy_wait
wait_end:
    ret

_S:
    cmp rcx, S_ASCII
    jne _n

    lea rcx, [rel acces]                 ;TODO check if this is the best way
    lea rcx, [rcx + 8*r12]
    lea rdx, [rel to_exchange]
    lea rdx, [rdx + 8*r12]
    lea rdi, [rel spin_locks]
    lea rdi, [rdi + r12]

    mov al, 1
    call busy_wait

    pop rsi                 ; number euron to echange
    pop qword [rdx]         ; value to exchange
    mov [rcx], rsi
    mov [rdi], al

    lea rcx, [rel acces]
    lea rcx, [rcx + 8*rsi]
    lea rdx, [rel to_exchange]
    lea rdx, [rdx + 8*rsi]
    lea rdi, [rel spin_locks]
    lea rdi, [rdi + rsi]

    mov al, 1
    call busy_wait

    push qword [rdx]
    mov [rcx], rsi
    mov [rdi],al
    jmp read_loop
exit:
    pop rax
    mov rsp, rbp
    pop r13
    pop r12
    pop rbp
    ret
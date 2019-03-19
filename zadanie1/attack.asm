section	.bss
    buf resb 4096
section .data
    states db 6,8,0,2,0
section  .text
    global _start

_start:
    cmp dword [rsp], 2        ; poprawnosc ilosci argumentow
    jne code_1_exit           

    mov rax, 2                ; otwarcie pliku
    mov rdi, qword [rsp + 16] 
    xor rsi, rsi              
    syscall

    cmp rax, 0                ; sprawdzenie czy powiodlo sie otwarcie pliku
    jl code_1_exit

    xor r10b, r10b            ; nizsze 4 bity czy była liczba wieksza niz 68020, wyzsze 4 czy był ciag 68020
    xor r12, r12              ; stan 'automatu' wychwytujacego sekwencje
    xor r13d, r13d            ; suma mod 2^32
    
    mov rdi, rax              ; zaladowanie fd

read_file:
    mov rsi, buf              ; przekazanie bufora
    mov rdx, 4096             ; rozmiar bufora
    xor r8, r8                ; ilosc wczytanych bajtow

read_loop:
    mov rax, 0
    syscall

    cmp rax, -1               ; sprawdzenie czy powiodlo sie odczytanie pliku
    je code_1_exit

    add r8, rax               ; modyfikacja rejestrow aby ponownie odczytac
    add rsi, rax
    sub rdx, rax

    cmp r8, 4096              ; jesli wczytano cały bufor
    je analyze_buf

    cmp rax, 0
    jne read_loop             ; nie odczytano wszystkich

    cmp r8, 0
    je exit

    test r8, 3                ; sprawdz modulo 4
    jnz code_1_exit

analyze_buf:
    shr r8, 2                 ; zamiana ilosc bajto na ilosc liczb
    xor r9, r9                ; przeanalizowana ilosc liczb

loop_analyze:
    mov rbx, [ buf + r9*4 ]

analyze_number:
    mov eax, ebx
    bswap eax

    cmp eax, 68020            
    je code_1_exit            ;pierwszy warunek nie spełniony
    
    jl check_68020_seq        ; sprawdzenie drugiego warunku
    test eax, 0x80000000      ; znak
    jnz check_68020_seq
    or r10b, 0x0f

check_68020_seq:
    cmp r10b, 0x0f
    jg next_number
    
    cmp al, [states + r12]
    jne check_6
    inc r12
    
    cmp r12, 5              ; wystapienie sekwencji 68020
    jne next_number
    or r10b, 0xf0
    jmp next_number

check_6:
    xor r12, r12
    cmp eax, 6
    jne next_number
    inc r12

next_number:
    add r13d, eax           
    inc r9
    cmp r9, r8
    je read_file
    test r9, 1               
    jz loop_analyze
    shr rbx, 32
    jmp analyze_number

exit:
    cmp r10b, 0xff
    jne code_1_exit
    cmp r13d, 68020
    jne code_1_exit

code_0_exit:
    mov rax, 60
    mov rdi, 0
    syscall

code_1_exit:
    mov rax, 60
    mov rdi, 1
    syscall
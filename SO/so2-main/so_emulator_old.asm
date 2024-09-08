section .bss
procs resq CORES
_PC    resb 1

global so_emul

; A – wartość rejestru A, kod 0;
; D – wartość rejestru D, kod 1;
; X – wartość rejestru X, kod 2;
; Y – wartość rejestru Y, kod 3;
; [X] – wartość komórki pamięci danych o adresie w rejestrze X, kod 4;
; [Y] – wartość komórki pamięci danych o adresie w rejestrze Y, kod 5;
; [X + D] – wartość komórki pamięci danych o adresie będącym sumą wartości rejestrów X i D, kod 6;
; [Y + D] – wartość komórki pamięci danych o adresie będącym sumą wartości rejestrów Y i D, kod 7.

; rdi - uint16_t const *code
; rsi - uint8_t *data
; rdx - size_t steps
; rcx - size_t core

%define _A               BYTE [rsp]
%define _D               BYTE [rsp+1]
%define _X               BYTE [rsp+2]
%define _Y               BYTE [rsp+3]

%define _C               BYTE [rsp+6]
%define _Z               BYTE [rsp+7]

%define steps            QWORD [rsp+8]
%define core             QWORD [rsp+16]

%macro GET_ARG 2                          ; makro do zapisania argumentu w rejestrze
                                          ; [%1]        - rejestr do ktorego kopiujemy,
                                          ; [%2]        - id argumentu
    cmp %2, 0
    je  %%opt0
    cmp %2, 1
    je  %%opt1
    cmp %2, 2
    je  %%opt2
    cmp %2, 3
    je  %%opt3
    mov rdx, rsi
    cmp %2, 4
    je  %%opt4
    cmp %2, 5
    je  %%opt5
    mov cl, _D
    add rdx, rcx
    cmp %2, 6
    je  %%opt6

    mov cl, _Y
    add rdx, rcx
    jmp %%memory
%%opt0:
    mov %1, _A
    jmp %%finish
%%opt1:
    mov %1, _D
    jmp %%finish
%%opt2:
    mov %1, _X
    jmp %%finish
%%opt3:
    mov %1, _Y
    jmp %%memory
%%opt4:
    mov cl, _X
    add rdx, rcx
    jmp %%memory
%%opt5:
    mov cl, _Y
    add rdx, rcx
    jmp %%memory
%%opt6:
    mov cl, _X
    add rdx, rcx
%%memory:
    mov %1, BYTE [rdx]
%%finish:
%endmacro

%macro SET_ARG 2                          ; makro do zapisania argumentu w rejestrze
                                          ; [%1]        - rejestr z ktorego kopiujemy,
                                          ; [%2]        - id argumentu
    cmp %2, 0
    je  %%opt0
    cmp %2, 1
    je  %%opt1
    cmp %2, 2
    je  %%opt2
    cmp %2, 3
    je  %%opt3
    mov rdx, rsi
    cmp %2, 4
    je  %%opt4
    cmp %2, 5
    je  %%opt5
    mov cl, _D
    add rdx, rcx
    cmp %2, 6
    je  %%opt6

    mov cl, _Y
    add rdx, rcx
    jmp %%memory
%%opt0:
    mov _A, %1
    jmp %%finish
%%opt1:
    mov _D, %1
    jmp %%finish
%%opt2:
    mov _X, %1
    jmp %%finish
%%opt3:
    mov _Y, %1
    jmp %%memory
%%opt4:
    mov cl, _X
    add rdx, rcx
    jmp %%memory
%%opt5:
    mov cl, _Y
    add rdx, rcx
    jmp %%memory
%%opt6:
    mov cl, _X
    add rdx, rcx
%%memory:
    mov BYTE [rdx], %1
%%finish:
%endmacro

%define imm8             r9b
%define arg1             r10b
%define arg2             r11b

section .text

so_emul:
    push rbx                        ; create stack frame
    mov  rsp, rbp
    xor  r8b, r8b                     ; r8 := wskaznik na miejsce w kodzie
    push r8                         ; push wyzerowane 8 bitow to the stack
    push rdx
    push rcx
    xor rdx, rdx
    xor rcx, rcx
loop:
    cmp steps, 0                      ; if steps == 0 so 
    jz return_struct                ; return struct
    inc [rel _PC]
    dec steps                         ; steps--
    mov ax, WORD [rdi + r8*2]       ; ax := code[nr_stepu]
    inc r8b
; kolejne mozliwe instrukcje to:

; sprawdzanie stalych
    cmp ax, 0x8000
    je  _clc
    cmp ax, 0x8100
    je  _stc
    cmp ax, 0xFFFF
    je  _brk

    mov r9w, ax
    and r9b, 111b   ; extract imm8

    mov r10w, ax
    shr r10b, 8     ; shift o 8 bitow
    mov r11b, r10b
    and r10b, 111b  ; extract arg1

    shr r11b, 3
    and r11b, 111b  ; extract arg2

    cmp ax, 0x4000
    jl  without_imm

    cmp ax, 0x5800
    jl _movi

    cmp ax, 0x6000
    jl _xori

    cmp ax, 0x6800
    jl _addi

    cmp ax, 0x7000
    jl _cmpi

; sprawdzanie jumpow:
    cmp ax, 0xC000                  ; jesli ax >= 0xC000
    jge _jumpy                      ; jest to jeden z jumpow

; wpp operacja to:

_rcr: ;RCR arg1 = 0x7001 + 0x100 * arg1
    GET_ARG al, arg1
    mov cl, _C
    shr cl, 7
    mov dl, al
    and dl, 1
    mov _C, dl
    shl al, 1
    or al, cl
    SET_ARG al, arg1
    jmp loop
; stale:
_clc: ;CLC = 0x8000
    mov _C, 0
    jmp loop
_stc: ;STC = 0x8100
    mov _C, 1
    jmp loop
_brk: ;BRK = 0xFFFF
    jmp return_struct
without_imm:
    GET_ARG al, arg1
    GET_ARG ah, arg2
    cmp imm8, 1
    je  _mov
    cmp imm8, 4
    je  _add
    cmp imm8, 5
    je  _sub
    cmp imm8, 6
    je  _adc
    cmp imm8, 7
    je  _sbb

_or: ;OR arg1, arg2
    or al, ah

set_arg:
    SET_ARG al, arg1
set_z_flag:
    mov _Z, 0
    jz loop
    mov _Z, 1
    jmp loop


_add: ;ADD arg1, arg2
    add al, ah
    jmp set_arg

_sub: ;SUB arg1, arg2
    sub al, ah
    jmp set_arg

_adc: ;ADC arg1, arg2
    add al, ah
    add al, _C
handle_ZC:
    mov _C, 0
    jz .z
    mov _C, 1
    .z:
    jmp set_arg

_sbb: ;SBB arg1, arg2
    sub al, ah
    sub al, _C
    jmp handle_ZC

_mov: ;MOV arg1, arg2
    SET_ARG r11b, arg1
    jmp loop
_movi: ;MOVI arg1, imm8
    SET_ARG imm8, arg1
    jmp loop
_xori: ;XORI arg1, imm8
    GET_ARG al, arg1
    xor al, imm8
    jmp set_arg
_addi: ;ADDI arg1, imm8
    GET_ARG al, arg1
    add al, imm8
    jmp set_arg
_cmpi: ;CMPI arg1, imm8
    GET_ARG al, arg1
    sub al, imm8
    mov _Z, 0
    jnz without_z
    mov _Z, 1
without_z:
    jc _stc
    jmp _clc
; jumpy, w r9 jest imm8
_jumpy:
    cmp ax, 0xC500
    jge _jz
    cmp ax, 0xC400
    jge _jnz
    cmp ax, 0xC300
    jge _jc
    cmp ax, 0xC200
    jge _jnc

    _jmp: ;JMP imm8 = 0xC000 + imm8
        add r8b, imm8
        jmp loop
    _jnc: ;JNC imm8 =  0xC200 + imm8
        cmp _C, 0
        je _jmp
        jmp loop
    _jc: ;JC imm8 =  0xC300 + imm8
        cmp _C, 1
        je _jmp
        jmp loop

    _jnz: ;JNZ imm8 = 0xC400 + imm8
        cmp _Z, 0
        je _jmp
        jmp loop

    _jz: ;JZ imm8 = 0xC500 + imm8
        cmp _Z, 1
        je _jmp
        jmp loop


return_struct:
    mov rcx, 8
    .loop_assign_vars:
        dec rcx
        mov dl, BYTE [rsp+rcx]
        mov [rax+rcx], dl
        jnz  .loop_assign_vars
    mov [rax+4], [rel _PC]
    add rsp, 24
    leave
    ret
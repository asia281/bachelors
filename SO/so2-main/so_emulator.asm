global so_emul

section .bss
_PCFLAG    resb 1
cores  resq CORES

section .text

%define arg1    BYTE [r10]
%define arg2    al
%define command cx
%define steps   r8
%define code    r9
%define data    rdx
%define core    rsi

%define _PC     BYTE [core + 4]
%define _C      BYTE [core + 6]
%define _Z      BYTE [core + 7]

%macro SET_CARRY 0                          ; makro do ustawiania flagi _C
%%opt0:
    clc
    cmp     _C, 0
    je      %%finish
    stc
%%finish:
%endmacro

get_loc:
    mov     rax, core                       ; rax := rejestr
    cmp     dil, 3                          ; jesli arg <= 3
    jle      .register                      ; znaczy ze jest rejestrem
    add     rax, 2                          ; wpp jest miejscem w pamieci
    test    rdi, 1                          ; jesli 
    jz      .x_or_y
    inc     rax
.x_or_y:
    movzx   rax, BYTE [rax]
    cmp     dil, 6
    jl      .data
    add     al, BYTE [core + 1]
.data: 
    add     rax, data
    ret
.register:
    add     ax, di
    ret

function:
    cmp     di, 0x8100                      ;STC = 0x8100
    je      _stc
    cmp     di, 0x8000                      ;CLC = 0x8000
    je      _clc
    mov     al, dil                         ; al == najnizsze 8 bitoww
    shr     di, 8
    movzx   command, dil                    ; cl == najnizsze 8 bitow
    cmp     command, 0x80                   ; jesli komenda >= 0x8000
    jge     _jumpy                          ; oznacza to, ze jest jumpem
    push    rax
    and     rdi, 0x7
    call    get_loc
    mov     r10, rax                        ; r10 := "wskaznik" na arg1
    pop     rax
    shr     command, 3
    
    cmp     command, 8
    je      _mov
    cmp     command, 11
    je      _xori
    cmp     command, 12
    je      _add
    cmp     command, 13
    je      _cmpi
    cmp     command, 14
    je      _rcr

    movzx   rdi, command
    mov     cl, al
    call    get_loc
    mov     r11, rax                        ; r11 := "wskaznik" na arg2
    mov     al, BYTE [rax]

    cmp     command, 0                      ; 
    je      _mov
    cmp     command, 2
    je      _or
    cmp     command, 4
    je      _add
    cmp     command, 5
    je      _sub
    cmp     command, 8
    je      _xchg
    cmp     command, 6
    je      _adc
_sbb:
    SET_CARRY
    sbb     arg1, arg2
    jmp     zc_flags
_or:
    or      arg1, arg2
    jmp     z_flag
_add:
    add     arg1, arg2
    jmp     z_flag
_sub:
    sub     arg1, arg2
    jmp     z_flag
_adc:
    SET_CARRY
    adc     arg1, arg2
    jmp     zc_flags
_mov:
    mov     arg1, arg2
    ret
_xchg:
    xchg    arg1, arg2
    mov     BYTE [r11], arg2
    jmp     finish
_xori:
    xor     arg1, arg2
    jmp     z_flag
_cmpi:
    cmp     arg1, arg2
    jmp     zc_flags
_clc:
    mov     _C, 0
    ret
_stc:
    mov     _C, 1
    ret
_rcr:
    SET_CARRY
    rcr     arg1, 1
    mov     _C, 0
    jnc     finish
    mov     _C, 1
    ret

_jumpy:
    cmp     command, 0xC5                ;JZ imm8 = 0xC500 + imm8
    je      _jz
    cmp     command, 0xC4                ;JNZ imm8 = 0xC400 + imm8
    je      _jnz
    cmp     command, 0xC3                ;JC imm8 =  0xC300 + imm8
    je      _jc
    cmp     command, 0xC2                ;JNC imm8 =  0xC200 + imm8
    je      _jnc

    _jmp: ;JMP imm8 = 0xC000 + imm8
        add _PC, al
        ret
    _jnc:
        cmp _C, 0
        je _jmp
        ret
    _jc:
        cmp _C, 1
        je _jmp
        ret
    _jnz:
        cmp _Z, 0
        je _jmp
        ret
    _jz:
        cmp _Z, 1
        je _jmp
        ret
zc_flags:
    setc _C
z_flag:
    setz  _Z
finish:
    ret

; rdi - uint16_t const *code
; rsi - uint8_t *data
; rdx - size_t steps
; rcx - size_t core

so_emul:
    mov     steps, rdx
    mov     code, rdi
    mov     data, rsi
    shl     rcx, 3
    lea     core, [rel cores]
    add     core, rcx
    mov     al, [rel _PCFLAG]
    mov     _PC, al
loop:
    cmp     steps, 0                        ; jesli steps == 0
    je      return                          ; skoncz 
    dec     steps
    movzx   rax, _PC
    mov     di, WORD [code + rax * 2]
    inc     _PC
    cmp     di, 0xFFFF
    je      return  
    call    function
    jmp     loop
return:
    mov     al, _PC
    mov     [rel _PCFLAG], al
    mov     rax, [core]                  ; przypisz wynikowa strukture
    ret
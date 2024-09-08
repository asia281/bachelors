section .bss
procs resq CORES

section .text

%define P_CTR(reg)      byte [reg + 4]
%define BRK_FLAG(reg)   byte [reg + 5]
%define CFLAG(reg)      byte [reg + 6]
%define ZFLAG(reg)      byte [reg + 7]

global so_emul

; in:
;   rdi - number from range [0,7]
;   rsi - pointer to core
;   rdx - pointer to data array
; out:
;   rax - address of value designated by number in rdi for rsi core
get_loc:
        mov     rax, rsi
        cmp     rdi, 3
        jg      .choose_xy
        add     rax, rdi
        ret
.choose_xy:
        add     rax, 2
        test    rdi, 1
        jz      .offset
        inc     rax
.offset:
        movzx   rax, byte [rax]
        cmp     rdi, 6
        jl      .load_data
        add     al, byte [rsi + 1]
.load_data: 
        add     rax, rdx
        ret

load_cflag:
        clc
        cmp     CFLAG(rsi), 0
        je      .return
        stc
.return:
        ret

; in:
;   rdi - currently executed code
;   rsi - pointer to core
;   rdx - pointer to data array
; modified:
;   rcx - parsed command 
;   r8  - address of value designated by parsed arg1
;   r9  - address of value designated by parsed arg2
;   rax - either value imm8 or value at r9
;   rdi - modified to pass arguments to get_loc
parse_and_execute:
        cmp     di, 0xffff
        jne     .ins_clc
        mov     BRK_FLAG(rsi), 1
        jmp     .return
.ins_clc:
        cmp     di, 0x8000
        jne     .ins_stc
        mov     CFLAG(rsi), 0
        jmp     .return
.ins_stc:
        cmp     di, 0x8100
        jne     .load_args
        mov     CFLAG(rsi), 1
        jmp     .return
.load_args:
        mov     al, dil                 ; al == lower 8 bytes of code
        shr     di, 8
        movzx   cx, dil                 ; cl == higher 8 bytes of code
        cmp     cx, 0x80                ; if 
        jge     .ins_jmp                ; cl == command, al == imm8
        push    rax
        and     rdi, 0x7
        call    get_loc
        mov     r8, rax
        pop     rax
        shr     cx, 3
        cmp     cl, 0x8
        jge     .ins_movi               ; r8 == addr of val [arg1], al == imm8, cl == command
        movzx   rdi, cx
        mov     cl, al
        call    get_loc
        mov     r9, rax
        mov     al, byte [rax]          ; r8 == addr of val [arg1], r9 == addr of val [arg1], cl == command
.ins_mov:
        test    cl, cl
        jnz     .ins_or
        mov     byte [r8], al
        jmp     .return
.ins_or:
        dec     cl
        loop    .ins_add
        or      byte [r8], al
        jmp     .return_with_z_flag
.ins_add:
        dec     cl
        loop    .ins_sub
        add     byte [r8], al
        jmp     .return_with_z_flag
.ins_sub:
        loop    .ins_adc
        sub     byte [r8], al
        jmp     .return_with_z_flag
.ins_adc:
        loop    .ins_sbb
        call    load_cflag
        adc     byte [r8], al
        jmp     .return_with_zc_flags
.ins_sbb:
        loop    .ins_xchg
        call    load_cflag
        sbb     byte [r8], al
        jmp     .return_with_zc_flags
.ins_xchg:
        dec     cl
        jnz     .return
        lock \
        xchg    byte [r8], al
        mov     byte [r9], al
        jmp     .return
.ins_movi:
        sub     cl, 0x8
        jnz     .ins_xori
        mov     byte [r8], al
        jmp     .return
.ins_xori:
        sub     cl, 3
        jnz     .ins_addi
        xor     byte [r8], al
        jmp     .return_with_z_flag
.ins_addi:
        loop    .ins_cmpi
        add     byte [r8], al
        jmp     .return_with_z_flag
.ins_cmpi:
        loop    .ins_rcr
        cmp     byte [r8], al
        jmp     .return_with_zc_flags
.ins_rcr:
        loop    .return
        cmp     al, 1
        jne     .return
        call    load_cflag
        rcr     byte [r8], 1
        mov     CFLAG(rsi), 0
        jnc     .return
        mov     CFLAG(rsi), 1
        jmp     .return
.ins_jmp:
        sub     cl, 0xc0
        jnz     .ins_jnc
        xor     cl, cl
        jmp     .return_jmp
.ins_jnc:
        dec     cl
        loop    .ins_jc
        cmp     CFLAG(rsi), 0
        jmp     .return_jmp
.ins_jc:
        loop    .ins_jnz
        cmp     CFLAG(rsi), 1
        jmp     .return_jmp
.ins_jnz:
        loop    .ins_jz
        cmp     ZFLAG(rsi), 0
        jmp     .return_jmp
.ins_jz:
        loop    .return
        cmp     ZFLAG(rsi), 1
.return_jmp:
        jne     .return
        add     P_CTR(rsi), al
        jmp     .return
.return_with_zc_flags:
        mov     CFLAG(rsi), 0
        jnc     .return_with_z_flag
        mov     CFLAG(rsi), 1
.return_with_z_flag:
        mov     ZFLAG(rsi), 0
        jnz     .return
        mov     ZFLAG(rsi), 1
.return:
        inc     P_CTR(rsi)
        ret

; in:
;   rdi - pointer to code array
;   rsi - pointer to data array
;   rdx - maximum number of steps for the program to take
;   rcx - core id
; modified:
;   rax - index of currently executed code
;   rdi - currently executed code
;   rsi - pointer to core
;   rdx - pointer to data array
;   r10 - maximum number of steps left for the program to take
;   r11 - pointer to code array
;   rcx, r8, r9 - modified by parse_and_execute
; out:
;   rax - packed strucute representing cpu state
so_emul:
        mov     r10, rdx
        mov     r11, rdi
        mov     rdx, rsi
        lea     rsi, [rel procs]
        shl     rcx, 3
        add     rsi, rcx
.loop:
        test    r10, r10
        jz      .exit
        dec     r10
        movzx   rax, P_CTR(rsi)
        mov     di, [r11 + rax * 2]
        call    parse_and_execute
        cmp     BRK_FLAG(rsi), 0
        jne     .exit
        jmp     .loop
.exit:
        mov     rax, [rsi]
        ret
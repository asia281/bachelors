global polynomial_degree

%define n               r9
%define const           r11         ; stala do liczenia big numow rowna n/64 + 1
%define stack_size      r10         ; stala = r9*r11 odpowiadajaca ilosci komorek tablicy, ktore przetwarzamy w danym loopie 
%define result          rsi         ; rejestr do trzymania wyniku
%define it_inside       rcx         ; iterator do wewnętrznej petli -- liczenia roznic dwoch sasiednich bignumow
%define it_outside      r8          ; iterator do zewnetrznej petli -- liczenia wynikow
%define overflow        rdx         ; rejestr trzymajacy przepelnienie
%define new_overflow    rdi         ; rejestr trzymajacy nowe przepelnienie (uzywany do zerowania rejestru rdx)

polynomial_degree:
        push    rbx                                 ; wrzuc stos rejestr rbx 

        mov     n, rsi                              ; r9 := n
        lea     rax, [n + 64]                       ; rax := n + 64
        mov     r11, 64                             ; r11 := dzielnik (60)
        xor     rdx, rdx                            ; rdx := 0 (musi byc := 0 przed div)
        div     r11                                 ; rax := (64+n)/64 = n/64 + 1
        mov     const, rax                          ; const := n/64 + 1
        mul     n                                   ; rax := const * n
        mov     stack_size, rax                     ; stack_size := const * n

        mov     result, -1
        mov     it_outside, n
loop_copy:
        dec     it_outside                          ; i--
        cmp     it_outside, 0
        jl      add_size_to_stack                   ; jesli i < 0 skonczylismy 
        lea     it_inside, [const-1]
add_zeros_to_stack:                                 ; diffs[i] := 0
        dec     it_inside                           ; j--; jesli it_wew < 0
        js      add_num_to_stack                    ; dodawanie zer skonczone
        push    0                                   ; wstaw zero
        jmp     add_zeros_to_stack                  ; wstawiaj dalej
add_num_to_stack:
        movsx   rax, DWORD [rdi + it_outside * 4]   ; rax := y[i]
        push    rax                                 ; wstaw y[i] na stos
        jmp     loop_copy                           ; wstawiaj pozostale liczby na stos
add_size_to_stack:
        lea     rax, [stack_size*8]
        push    rax                                 ; dodaj na stos ile pamieci musisz zwolnic na koncu
; koniec pętli loop_copy; wszystkie kopie dodane na stos
all_zeros:
        mov     it_inside, stack_size               ; it_wew := aktualna liczba rzeczy na stosie
one_zero:
        dec     it_inside                           ; i--
        cmp     it_inside, -1                       ; jesli i == -1,
        je      return_result                       ; wszystkie roznice sa juz rowne zero
        mov     rax, QWORD [rsp + it_inside * 8 + 8]; rax := aktualne diffs
        cmp     rax, 0
        je      one_zero                            ; jesli aktualnie diffs == 0, sprawdz czy inne to rowniez zera
; koniec all_zeros -- sprawdzania, czy wszystkie liczby == 0
reduce:
        dec     n
        sub     stack_size, const                   ; nie rozpatruj dalej ostatniej liczby
        inc     result
        xor     it_outside, it_outside
        xor     rbx, rbx                            ; rbx := aktualna pozycja na stosie
num:
        cmp     n, it_outside                       ; jesli n <= it
        jle     all_zeros                           ; zwracamy maksymalny wynik (N-1)
        inc     it_outside
        xor     overflow, overflow
        xor     it_inside, it_inside
part:
        mov     new_overflow, overflow              ; przenies overflow
        xor     overflow, overflow                  ; i wyzeruj stare
        cmp     it_inside, const                    ; jesli j >= num_size
        jge     num                                 ; licz roznice dalej
        inc     rbx                                 ; aktualna pozycja w tablicy diff++
        inc     it_inside
        add     [rsp + rbx * 8], new_overflow       ; dodaj overflow
        mov     overflow, new_overflow              ; dodaj overflow do nastepnej petli
sub_with_overflow:
        mov     rax, rbx                            ; rax := pos
        add     rax, const                          ; rax := pos + stala
        mov     rax, QWORD [rsp+rax*8]              ; rax := diffs[i + 1][j]
        sub     [rsp+rbx*8], rax                    ; diffs[i][j] -= diffs[i + 1][j](rax)
        jno     part                                ; przetwarzaj dalej
        mov     overflow, 1                         ; ustaw overflow := 1, jest to poprawny overflow dla diffs[i][j + 1] < 0
        cmp     rax, 0                              ; jesli diffs[i][j + 1] < 0
        jl      part                                ; poprawny overflow jest ustawiony, licz roznice diffs[i] dalej
; koniec reduce -- petli do liczenia roznic
add_overflow:
        mov     overflow, -1                        ; wpp diffs[i][j + 1] > 0, wiec ustaw overflow := -1
        jmp     part                                ; licz diffs[i] dalej
return_result:
        mov     rax, result                         ; przypisz wynik do zwracanego rejestru
        pop     rbx                                 ; rbx := wrzucona na szczyt liczba pamieci na stosie
        add     rsp, rbx                            ; zwolnij miejsce na stosie
        pop     rbx                                 ; wez z powrotem stare rbx
        ret                                         ; zwroc wynik
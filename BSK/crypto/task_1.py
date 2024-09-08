from pwn import *


def _1(p):
    # fetch wypisywany tekst (ktore podzadanie wybierasz)
    p.recv(timeout=1)
    p.recv(timeout=1)
    # wybieramy 1)
    b_1 = b'1\n'
    p.send(b_1)
    # wczytujemy m=
    p.recvn(2)
    # czytamy 309 bajtow (liczba zapisana w systemie 10)
    m_raw = p.recvn(309)
    # wczytujemy smieci oraz base>
    p.recv(timeout=1)
    p.recv(timeout=1)
    # base = m -1
    base = str(int(m_raw) - 1)
    p.send(base + '\n')
    # wczytujemy guess
    buf = p.recv(timeout=1)
    # dopoki nie ma 1000 guessow,
    while buf[0] == 103:
        # wyslij guess = 1
        p.send(b_1)
        # otrzymaj nastepny guess>
        buf = p.recv(timeout=1)
    # wypisz flage
    print(buf)
    return

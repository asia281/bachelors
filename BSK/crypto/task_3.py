from pwn import *
import codecs

def xor(a, b):
    return bytes([ac ^ bc for ac, bc in zip(a, b)])


def pad(msg):
    byte = 16 - len(msg) % 16
    return msg + bytes([byte] * byte)


def _3(p):
    # fetch wypisywany tekst (ktore podzadanie wybierasz)
    p.recv(timeout=1)
    p.recv(timeout=1)
    # wybieramy 3)
    p.sendline(b'3')
    p.recv(timeout=1)
    p.sendline(b'')
    buf = p.recv(timeout=1)
    p.sendline(b'')
    encoded_flag = p.recvS(timeout=1)  # wczytaj STRING a nie bytes
    encoded_flag = encoded_flag[:-1]
    iv = encoded_flag[:32]  # w hex, zmien do bytes
    bytes_iv = bytes.fromhex(iv)
    encoded_iv = bytes.fromhex(encoded_flag[-32:])
    encoded_last = bytes.fromhex(encoded_flag[-64:-32])

    # s = ""
    # pad_16 = pad(s.encode())  # or pad(b'}') or pad(b'c}')
    # print(pad_16)
    # # encoded_iv = xor(pad_16, aes.encrypt(xor(iv, encoded_last)))
    # # transform to:
    # # new_encoded_iv = xor(iv, aes.encrypt(xor(iv, encoded_last)))
    # new_encoded_iv = xor(bytes_iv,
    #                      xor(pad_16, encoded_iv))  # aby znalezc new encoded trzeba zrobic xor z iv oraz hipotetyczym padem
    # p.recv(timeout=1)
    # p.sendline(b'')
    # p.recv(timeout=1)
    # p.sendline((iv + new_encoded_iv.hex()).encode())  # i zakodowanie = iv +
    # buf = p.recv(timeout=1)
    #
    # print(buf, "break")

    for j in range(33, 127):
        for i in range(33, 127):
            s = chr(j) + chr(i) + "}"
            pad_16 = pad(s.encode())   # or pad(b'}') or pad(b'c}')
            print(s, pad_16)
            # encoded_iv = xor(pad_16, aes.encrypt(xor(iv, encoded_last)))
            # transform to:
            # new_encoded_iv = xor(encoded_last, aes.encrypt(xor(iv, encoded_last)))
            new_encoded_iv = xor(bytes_iv,
                                 xor(pad_16,
                                     encoded_iv))  # aby znalezc new encoded trzeba zrobic xor z iv oraz hipotetyczym padem
            buf = p.recv(timeout=1)
            p.sendline(codecs.encode(s.encode(), "hex"))
            p.recv(timeout=1)
            p.sendline((iv + new_encoded_iv.hex()).encode())  # i zakodowanie = iv +
            buf = p.recv(timeout=1)
            print(buf)
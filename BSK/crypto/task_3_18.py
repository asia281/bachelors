from pwn import *
import codecs

def split_by(data, cnt):
    return [data[i : i+cnt] for i in range(0, len(data), cnt)]

def pad(msg):
    byte = 16 - len(msg) % 16
    return msg + bytes([byte] * byte)



def get_byte_flag(p, flag, msg):
    for j in range(256):
        try_flag = flag + j.to_bytes(1, 'big')
        p.sendline(codecs.encode(try_flag, "hex"))
        p.sendline(msg)

    for j in range(256):
        p.recvuntil(b'> ')
        result = p.recvline()
        p.recvuntil(b'> ')
        # If result is hacker detected, then we guessed the flag correctly.
        if result == b'hacker detected!\n':
            p.clean(1)
            return j.to_bytes(1, 'big')
        elif result[:2] == b'yo':
            pass
        else:
            print(result)



def get_byte_nr(p, iv, mid):
    for j in range(256):
        new_fst = (j ^ mid[-1]).to_bytes(1, 'big')
        new_iv = (j ^ iv[-1]).to_bytes(1, 'big')

        p.sendline(bytes('66', 'ascii'))    # 66 = f
        p.sendline(codecs.encode((iv[:-1] + new_iv + mid[:-1] + new_fst + iv), "hex"))

    for j in range(256):
        p.recvuntil(b'> ')
        result = p.recvline()
        p.recvuntil(b'> ')
        # If result is hacker detected, then we guessed the flag correctly.
        if result == b'hacker detected!\n':
            p.clean(1)
            return j

def get_byte_two(p, iv, mid):
    for j in range(256):
        new_fst = (j ^ mid[-2]).to_bytes(1, 'big')
        new_iv = (j ^ iv[-2]).to_bytes(1, 'big')

        p.sendline(bytes('66', 'ascii'))    # 66 = f
        p.sendline(codecs.encode((iv[:-2] + new_iv + iv[-1:] + mid[:-2] + new_fst + mid[-1:] + iv), "hex"))

    for j in range(256):
        p.recvuntil(b'> ')
        result = p.recvline()
        p.recvuntil(b'> ')
        # If result is hacker detected, then we guessed the flag correctly.
        if result == b'hacker detected!\n':
            p.clean(1)
            return j

def _3(p):
    # fetch wypisywany tekst (ktore podzadanie wybierasz)
    p.recvuntil(b'> ')
    # wybieramy 1)
    p.sendline(b'3')
    p.recvuntil(b'> ')
    p.sendline(b'')
    p.recvuntil(b'> ')
    p.sendline(b'')
    encoded_flag = p.recvS(timeout=1)  # wczytaj STRING a nie bytes
    encoded_flag = encoded_flag[:-1]


    decoded_flag = bytes.fromhex(encoded_flag[32:-32])
    iv = encoded_flag[:32]  # w hex, zmien do bytes
    bytes_iv = bytes.fromhex(iv)

    fst = encoded_flag[32:64]
    bytes_fst = bytes.fromhex(fst)

    snd = encoded_flag[64:96]
    bytes_snd = bytes.fromhex(snd)

    flag_blocks = split_by(decoded_flag, 16)

    last_to_help = get_byte_nr(p, bytes_iv, bytes_fst) ^ 15
    curr = b''

    for enc_flag_block in flag_blocks:
        for i in range(len(enc_flag_block) - 1):
            print(f'i: {i}')

            j = last_to_help ^ (15 - i)
            new_fst = (j ^ enc_flag_block[-1]).to_bytes(1, 'big')
            new_iv = (j ^ bytes_iv[-1]).to_bytes(1, 'big')
            curr_msg = codecs.encode(bytes_iv[:-1] + new_iv + enc_flag_block[:-1] + new_fst + bytes_snd, "hex")
            found = get_byte_flag(p, curr, curr_msg)
            print(found)
            curr += found
            print(curr)
            if found == '}':
                return

        curr += last_to_help.to_bytes(1, 'big')
        print(curr)

        bytes_iv += enc_flag_block

        last_to_help = get_byte_two(p, bytes_iv, bytes_snd) ^ (15 + 16)





from pwn import *


def xor(a, b):
    return bytes([ac ^ bc for ac, bc in zip(a, b)])


class LcgPrng:
    a = 672257317069504227
    c = 7382843889490547368
    m = 9223372036854775783

    def __init__(self, seed):
        self.state = seed

    def next(self):
        """Gets a next 64bit random number."""
        self.state = (self.state * self.a + self.c) % self.m
        return self.state

    def next_bytes(self):
        """Gets 7 random bytes.
        Even though internal state is 64bit (8 bytes), we don't actually
        get 64 bits of entropy per next(). Due to how LCGs work, some
        values are unobtainable, for example next() will never
        return 2**64 - 1. Returning just 7 bytes works around this problem
        (it's still biased, but there's just a tiny bit of bias left).
        """
        rnd_56bit = self.next() & 0xFFFFFFFFFFFFFF
        return rnd_56bit.to_bytes(7, 'little')


def _2(p):
    p.recv(timeout=1)
    p.recv(timeout=1)
    # wybieramy 2)
    b_2 = b'2\n'
    p.send(b_2)
    # wczytujemy
    encrypted = bytes.fromhex(p.recvnS(82))
    print(len(encrypted))

    last_byte = xor(b'}', encrypted[-1:])
    beg = xor(b'flag{', encrypted[:5])
    num_beg = int.from_bytes(beg, byteorder='little')

    for i in range(0x0000000000000000, 0xFFFFFF0000000000, 0x0000010000000000):
        to_check = num_beg + i
        def check(num):
            len = 7
            cipher = LcgPrng(num)
            c = (num & 0xFFFFFFFFFFFFFF).to_bytes(7, 'little')
            while len < 41:
                num = cipher.next_bytes()
                len += 7
                c += num

            if c[-2:-1] != last_byte:
                return False, None
            try:
                re = xor(c, encrypted)
                return True, re.decode()
            except ValueError:
                return False, None

        found, flag = check(to_check)

        if found:
            print("flag found!", flag)
            break
import random

# from Crypto.Cipher import AES
# from Crypto.Random import get_random_bytes
# from utils import ae_decrypt, xor, lcg_encrypt, LcgPrng


if __name__ == '__main__':

    l2 ="5841d2ff493851ff07d1af688e38116a1630d36f5010e9b20fabbf1867892a2af676b88569cfbae7f6"

    print(len("580266efaf32a44e3384f371863db70fad71b6875a24bcf1e44fafe53d95e24f070795a650f20d0a13e15476e70236cfbaf9c6476fd4b7a09a91efb0f2da69dc4cff3b00f4b9814c5b8e444045a588fd"))

    # key = get_random_bytes(16)
    # aes = AES.new(key, AES.MODE_ECB)
    #
    #
    #
    # beg = "flag{".encode()
    # h = xor((0xFFFFFFFFFFFFFF).to_bytes(7, 'little'), (0x01234567DDEE).to_bytes(6, 'little'))
    # print(h)
    #
    # cipher = LcgPrng(random.randrange(0, 2**64))
    # keystream = b''
    # flag = b'\x9e\x98\x84\x9e\x98\x84\x9e\x98\x84'
    # while len(keystream) < 10:
    #     keystream += cipher.next_bytes()
    #
    # xor = xor(keystream, flag)
    #
    # print(keystream.hex(), len(keystream.hex()), len(xor.hex()), )

    #print((xor(beg, l2).hex() + '\n').encode())
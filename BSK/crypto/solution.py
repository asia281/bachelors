from pwn import *
from task_3_18 import _3
from task_2 import _2
from task_1 import _1

serverAddress = 'cryptotask2022.tailcall.net'

def main():
    # p = remote(serverAddress, 30006)
    # _1(p)
    # p = remote(serverAddress, 30006)
    # _2(p)
    p = remote(serverAddress, 30006)
    _3(p)

if __name__ == '__main__':
    main()
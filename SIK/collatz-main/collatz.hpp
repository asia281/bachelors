#ifndef COLLATZ_HPP
#define COLLATZ_HPP

#include <assert.h>

#include "sharedresults.hpp"

inline uint64_t calcCollatz(InfInt n) {
    // It's ok even if the value overflow
    uint64_t count = 0;
    assert(n > 0);

    while (n != 1) {
        ++count;
        if (n % 2 == 1) {
            n *= 3;
            n += 1;
        }
        else {
            n /= 2;
        }            
    }

    return count;
}

inline uint64_t calcCollatz(InfInt n, bool share, std::shared_ptr<SharedResults> sharedResults) {
    if (!share) return calcCollatz(n);

    assert(n > 0);
    if (n == 1) return 0;

    InfInt new_n = (n % 2 == 1) ? (InfInt(3) * n + 1) : n/2;

    uint64_t res;

    if (sharedResults->get(new_n)) {
        res = sharedResults->get(new_n) + 1;
    }
    else {
        res = calcCollatz(new_n) + 1;
    }

    sharedResults->assign(n, res);
    return res;

}

#endif
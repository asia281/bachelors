#ifndef SHAREDRESULTS_HPP
#define SHAREDRESULTS_HPP

#include <map>
#include <memory>

class SharedResults {
    std::map<InfInt, uint64_t> map;
public:
    void assign(InfInt idx, uint32_t val) {
        map[idx] = val;
    }
    uint64_t get(InfInt idx) {
        if (map.find(idx) != map.end()) return map[idx];
        return 0;
    }
};

#endif
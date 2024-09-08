#include <utility>
#include <deque>
#include <future>
#include <thread>
#include <iostream>
#include <unistd.h>

#include "lib/pool/cxxpool.h"
#include "lib/tiny-process-library/process.hpp"
#include "teams.hpp"
#include "contest.hpp"
#include "collatz.hpp"
#include "lib/err.h"

static void splitWork(const uint32_t contestInputSize, const uint32_t threadNum,
                      std::vector<std::pair<uint32_t, uint32_t>> &interval) {

    std::vector<uint32_t> work((int) threadNum);
    uint32_t avgWork = contestInputSize / threadNum;
    if (contestInputSize % threadNum == 0) {
        std::fill(work.begin(), work.end(), avgWork);
    } else {
        avgWork++;
        std::fill(work.begin(), work.end(), avgWork);
        uint32_t tempWork = avgWork * threadNum;
        auto index = 0;
        while (tempWork > contestInputSize) {
            work.at(index)--;
            tempWork--;
            index++;
        }
    }

    uint32_t ind = 0;
    for (auto i = 0; i < threadNum; i++) {
        std::pair<uint32_t, uint32_t> newPair = {ind, ind + work.at(i)};
        interval.push_back(newPair);
        ind += work.at(i);
    }
}

void single(ContestInput const & contestInput, ContestResult &r, uint32_t i, bool share, std::shared_ptr<SharedResults> sharedResults) {
    r[i]  = calcCollatz(contestInput[i], share, sharedResults);
}


void oneThread(ContestInput const & contestInput, ContestResult& r, uint32_t idx, uint64_t step, bool share, std::shared_ptr<SharedResults> sharedResults) {
    for (uint64_t i = idx; i < contestInput.size(); i += step) {
        r[i] = calcCollatz(contestInput[i], share, sharedResults);
    }
}

ContestResult TeamNewThreads::runContestImpl(ContestInput const & contestInput) {
    const size_t threads_size = getSize();
    const uint64_t size = contestInput.size();
    ContestResult results(size);
    std::queue<std::thread> threads;
    bool share = this->share;
    std::shared_ptr<SharedResults> sharedResults = this->getSharedResults();
    for (size_t i = 0; i < size; i++) {
        if (threads.size() >= threads_size) {
            threads.front().join();
            threads.pop();
        }
        std::thread t= createThread([&contestInput, &results, i, share, sharedResults]
                                  { single(contestInput, results, i, share, sharedResults); });
        threads.push(std::move(t));
    }

    while (!threads.empty()) {
        threads.front().join();
        threads.pop();
    }
    return results;
}

ContestResult TeamConstThreads::runContestImpl(ContestInput const & contestInput) {
    ContestResult results(contestInput.size());
    bool share = this->share;
    std::shared_ptr<SharedResults> sharedResults = this->getSharedResults();
    std::vector<std::thread> threads;
    uint32_t threads_size = this->getSize();;
    for (uint32_t i = 0; i < threads_size; i++) {
        std::thread t = createThread([contestInput, &results, i, threads_size, share, sharedResults] { oneThread(contestInput, results, i, threads_size, share, sharedResults); });
        threads.push_back(std::move(t));
    }
    for (uint32_t i = 0; i < threads_size; i++) {
        threads[i].join();
    }
    return results;
}

ContestResult TeamPool::runContest(ContestInput const &contestInput) {
    const uint64_t size = contestInput.size();
    ContestResult result(size);
    uint32_t threadNum = getSize();
    std::vector<std::future<std::vector<uint64_t>>> futureVector(threadNum);
    std::vector<std::vector<uint64_t>> resultVector(threadNum);
    std::vector<std::pair<uint32_t, uint32_t>> interval;

    splitWork(size, threadNum, interval);

    for (uint32_t i = 0; i < threadNum; i++) {
        futureVector.at(i) = pool.push([i, interval, contestInput] {
            std::vector<uint64_t> res;
            for (uint32_t index = interval.at(i).first;
                 index < interval.at(i).second; index++) {
                res.push_back(calcCollatz(contestInput.at((int) index)));
            }
            return res;
        });
    }
    uint32_t idx = 0;
    for (uint32_t i = 0; i < threadNum; i++) {
        resultVector.at(i) = futureVector.at(i).get();
        for (auto &j: resultVector.at(i)) {
            result[idx++] = j;
        }
    }

    return result;
}

/*ContestResult TeamPool::runContest(ContestInput const & contestInput) {
    ContestResult r;
    int size = contestInput.size();
    r.resize(size);
    std::future<uint64_t> futures[size];
    for (int i = 0; i < size; i++) {
        futures[i] = pool.push(calcCollatz, contestInput[i]);
    }
    for (int i = 0; i < size; i++) {
        r[i] = futures[i].get();
    }
    return r;
}*/

ContestResult TeamNewProcesses::runContest(ContestInput const & contestInput) {
    uint64_t size = contestInput.size();
    ContestResult results(size);
    return results;
}

ContestResult TeamConstProcesses::runContest(ContestInput const &contestInput) {
    uint64_t size = contestInput.size();
    ContestResult results(size);

    return results;
}

ContestResult TeamAsync::runContest(ContestInput const & contestInput) {
    uint64_t size = contestInput.size();
    ContestResult results(size);
    std::vector<std::future<uint64_t>> futures(size);
    bool share = this->share;
    std::shared_ptr<SharedResults> sharedResults = this->getSharedResults();
    uint64_t idx = 0;
    for (auto input: contestInput) {
        futures[idx++] = std::async([input, share, sharedResults]{return calcCollatz(input, share, sharedResults); });
    }
    for (uint64_t i = 0; i < size; i++) {
        results[i] = futures[i].get();
    }
    return results;
}

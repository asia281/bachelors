#include <iostream>
#include <fstream>
#include <locale>
#include <string>
#include <list>
#include <codecvt>
#include <thread>
#include <future>

int grep(std::string filename, std::wstring word) {
    std::locale loc("pl_PL.UTF-8");
    std::wfstream file(filename);
    file.imbue(loc);
    std::wstring line;
    unsigned int count = 0;
    while (getline(file, line)) {
        for (auto pos = line.find(word,0);
             pos != std::string::npos;
             pos = line.find(word, pos+1))
            count++;
    }
    return count;
}

void fun(std::wstring& word, std::promise<unsigned int>& len_promise, std::list<std::string>& filenames) {
    int count = 0;
    for (auto filename : filenames) {
        count += grep(filename, word);
    }

    len_promise.set_value(count);
}

int main() {
    std::ios::sync_with_stdio(false);
    std::locale loc("pl_PL.UTF-8");
    std::wcout.imbue(loc);
    std::wcin.imbue(loc);

    std::wstring word;
    std::getline(std::wcin, word);

    std::wstring s_file_count;
    std::getline(std::wcin, s_file_count);
    int file_count = std::stoi(s_file_count);


    unsigned int len1{0}, len2{0};
    std::promise<unsigned int> len_promise1, len_promise2;
    std::future<unsigned int> len_future1 = len_promise1.get_future();
    std::future<unsigned int> len_future2 = len_promise2.get_future();
    std::list<std::string> filenames1{};
    std::list<std::string> filenames2{};


    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> converter;

    for (int i = 0; i < file_count; i ++) {
        std::wstring w_filename;
        std::getline(std::wcin, w_filename);
        std::string s_filename = converter.to_bytes(w_filename);
        if (i % 2 == 0) {
            filenames1.push_back(s_filename);
        } else {
            filenames2.push_back(s_filename);
        }
    }

    std::thread t1{[&word,&len_promise1, &filenames1 ]{ fun(word, len_promise1, filenames1); }};
    std::thread t2{[&word, &len_promise2, &filenames2]{ fun(word, len_promise2, filenames2); }};

    len1 = len_future1.get();
    len2 = len_future2.get();
    std::cout << (len1 + len2);
    t1.join();
    t2.join();

}


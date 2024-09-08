#include <functional>
#include "tri_list.h"

struct A {};

struct B {};

struct C {};

struct F {
    A operator()(A x) { return x; }
};

C g(C x) { return x; }
int main() {
    tri_list<int, int, double> l1;
    l1.push_back<double>(0);
    l1.modify_only<double>(identity<double>);
    l1.reset<double>();
    l1.range_over<double>();
    l1.begin();
    l1.end();

    std::cout <<

    tri_list<int, int, int> l2;
    l2.begin();
    l2.end();
}

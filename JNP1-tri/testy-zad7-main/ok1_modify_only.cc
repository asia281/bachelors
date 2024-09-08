#include <functional> 
#include "../tri_list.h"

struct A {};

struct B {};

struct C {};

struct F {
    A operator()(A x) { return x; }
};

C g(C x) { return x; }

int main() {
    tri_list<A, B, C> l;
	l.modify_only<A, F>();
	l.modify_only<B>([](B x) { return x; });
	l.modify_only<C>(g);
}

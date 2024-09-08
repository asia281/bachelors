#include "../tri_list.h"

int main() {
	tri_list<int, char, double> l;
	constexpr int op = int(1e5);

	for (int i = 0; i < op; ++i) {
		l.push_back<int>(0);
		l.modify_only<int>([](int x) { return x + 1; });
	}

	for (int i = 0; i < op; ++i) {
		l.begin();
		l.end();
		l.range_over<int>();
		l.range_over<char>();
		l.range_over<double>();
	}
}

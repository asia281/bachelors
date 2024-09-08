#include "../tri_list.h"

int main() {
	tri_list<int, int, double> l1;
	l1.push_back<double>(0);
	l1.modify_only<double>(identity<double>);
	l1.reset<double>();
	l1.range_over<double>();
	l1.begin();
	l1.end();

	tri_list<int, int, int> l2;
	l2.begin();
	l2.end();
}

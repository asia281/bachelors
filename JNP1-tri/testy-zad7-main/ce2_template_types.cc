#include "../tri_list.h"

int main() {
	tri_list<int, int, double> l;
	l.modify_only<int>(identity<int>);
}

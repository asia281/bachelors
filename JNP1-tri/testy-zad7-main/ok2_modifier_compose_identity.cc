#include "../tri_list.h"

int main() {
	static_assert(modifier<decltype(identity<int>), int>);
	static_assert(modifier<decltype(compose<int>(identity<int>, identity<int>)), int>);
}

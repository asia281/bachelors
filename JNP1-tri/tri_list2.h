#ifndef TRI_LIST2_H
#define TRI_LIST2_H

#include <numeric>
#include <variant>
#include <vector>
#include <functional>
#include <iostream>

#include "tri_list_concepts.h"

template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

template <typename T, typename T1, typename T2, typename T3>
concept OneOf =
(std::same_as<T, T1> && !std::same_as<T, T2> && !std::same_as<T, T3>)
|| (!std::same_as<T, T1> && std::same_as<T, T2> && !std::same_as<T, T3>)
|| (!std::same_as<T, T1> && !std::same_as<T, T2> && std::same_as<T, T3>);

template <typename T>
T identity(T x) { return x; }
static_assert(modifier<decltype(identity<int>), int>);

template <typename T, modifier<T> F, modifier<T> G>
auto compose(F&& f, G&& g) {
    return [f, g](T t){ return f(g(t)); };
}

template <typename T1, typename T2, typename T3>
class tri_list : public std::ranges::view_interface<tri_list<T1, T2, T3>> {
    using elt_t = std::variant<T1, T2, T3>;
    std::vector<elt_t> buffer;

    std::function<T1(T1)> modifiers_t1;
    std::function<T2(T2)> modifiers_t2;
    std::function<T3(T3)> modifiers_t3;

    template <typename T>
    std::function<T(T)>& get_modifiers() {
        if constexpr (std::is_same<T, T1>::value) { return modifiers_t1; }
        else if constexpr (std::is_same<T, T2>::value) { return modifiers_t2; }
        else if constexpr (std::is_same<T, T3>::value) { return modifiers_t3; }
        else { abort(); }
    }

    template <typename T>
    T apply_modifiers(T t) {
        auto modifier = get_modifiers<T>();
        try {
            t = std::invoke(modifier,   t);
        } catch(const std::bad_function_call& e) {
            std::cout << e.what() << '\n';
        }
        return t;
    }

    elt_t visit(elt_t v) {

    }

    class iterator {
        using base_iterator = typename decltype(buffer)::iterator;
        std::function<T1(T1)> modifiers_t1;
        std::function<T2(T2)> modifiers_t2;
        std::function<T3(T3)> modifiers_t3;

    public:
        using iterator_category = typename base_iterator::iterator_category;
        using difference_type = typename base_iterator::difference_type;
        using value_type = elt_t;
        using pointer = elt_t*;
        using reference = elt_t&;
        pointer base;

        iterator() = default;
        explicit iterator(pointer other,
                          std::function<T1(T1)> modifiers_t1,
                          std::function<T2(T2)> modifiers_t2,
                          std::function<T3(T3)> modifiers_t3)
                :  base(other), modifiers_t1(modifiers_t1), modifiers_t2(modifiers_t2),
                   modifiers_t3(modifiers_t3){}

        reference operator*() const {
            return  std::visit([&] <typename T> (T x) -> T {
                if constexpr(std::same_as<T, T1>) {
                    //  return std::invoke(modifiers_t1, x);
                }
                if constexpr(std::same_as<T, T2>) {
                    //   return std::invoke(modifiers_t2, x);
                }
                if constexpr(std::same_as<T, T3>) {
                  //  return std::invoke(modifiers_t3, x);
                }
            }, *base);
            // return tri_lst->apply_modifiers(*base);
            // using t = decltype(*base);
            /*return std::visit( ([this](auto&& arg) {
                 using T = std::decay_t<decltype(arg)>;
                  return std::get<decltype(arg)>(tri_lst->apply_modifiers(arg));
              },
                    overloaded {
                            [&](T1 t) -> elt_t {return tri_lst->apply_modifiers(t); },
                            [&](T2 t) -> elt_t {return tri_lst->apply_modifiers(t); },
                            [&](T3 t) -> elt_t {return tri_lst->apply_modifiers(t); }
                    },
                    *base
            );*/
        }

        iterator& operator++() { base++; return *this; }
        iterator& operator--() { base--; return *this; }
        iterator operator++(int) { iterator result {*this}; ++this; return result; }
        iterator operator--(int) { iterator result {*this}; --this; return result; }
        friend bool operator==(const iterator& a, const iterator& b) { return a.base == b.base; }
    };

public:
    tri_list() : tri_list({}) {}
    tri_list(std::initializer_list<elt_t> elements) : buffer(elements) {};

    template <OneOf<T1, T2, T3> T>
    // template <typename T>
    void push_back(const T& t) { buffer.push_back(t); }
    template<typename T>
    static constexpr bool is_same_as(int t) noexcept {
        if (t == 1) return std::is_same_v<T, T1>;
        if (t == 2) return std::is_same_v<T, T2>;
        return std::is_same_v<T, T3>;
    }
    template <OneOf<T1, T2, T3> T, modifier<T> F>
    // template <typename T, modifier<T> F>
    void modify_only([[maybe_unused]] F m = F {}) {
        if constexpr (is_same_as<T>(1)) {
            modifiers_t1 = compose<T>( modifiers_t1, m);
        }
        else if constexpr (is_same_as<T>(2)) {
            modifiers_t2 = compose<T>( modifiers_t2, m);
        }
        else {
            modifiers_t3 = compose<T>( modifiers_t3, m);
        }
    }

    template <OneOf<T1, T2, T3> T>
    // template <typename T>
    void reset() {
        get_modifiers<T>() = identity<T>;
    }

    template <OneOf<T1, T2, T3> T>
    // template <typename T>
    auto range_over() {
        return buffer
               | std::ranges::views::filter(std::holds_alternative<T, T1, T2, T3>)
               | std::ranges::views::transform([&](auto x){ return std::get<T>(apply_modifiers(x));});
    }

    iterator begin() { return iterator(&buffer[0], modifiers_t1, modifiers_t2, modifiers_t3);};
    iterator end() { return iterator(&buffer[buffer.size()], modifiers_t1, modifiers_t2, modifiers_t3); }
};


#endif // TRI_LIST2_H
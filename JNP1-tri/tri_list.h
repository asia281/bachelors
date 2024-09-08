#ifndef TRI_LIST_H
#define TRI_LIST_H

#include <functional>
#include <initializer_list>
#include <ranges>
#include <tuple>
#include <type_traits>
#include <utility>
#include <vector>
#include <variant>
#include <concepts>

#include "tri_list_concepts.h"

template <typename T, typename T1, typename T2, typename T3>
concept onlyOne =
    (std::same_as<T, T1> && !std::same_as<T, T2> && !std::same_as<T, T3>) ||
    (!std::same_as<T, T1> && std::same_as<T, T2> && !std::same_as<T, T3>) ||
    (!std::same_as<T, T1> && !std::same_as<T, T2> && std::same_as<T, T3>);

template<typename T, modifier<T> F, modifier<T> G>
inline auto compose(G&& g, F&& f) {
    return [g=std::forward<G>(g), f=std::forward<F>(f)](T t) mutable {
        return g(f(t));
    };
}

template<typename T>
inline T identity(const T &t) {
    return t;
}

template<typename T1, typename T2, typename T3>
class tri_list {
private:
    using types = std::variant<T1, T2, T3>;

    template<typename T>
    using modifier_t = std::function<T(const T &)>;

    std::tuple<modifier_t<T1>, modifier_t<T2>, modifier_t<T3>> mods = {
            identity<T1>, identity<T2>, identity<T3>
    };


    template<typename T>
    const modifier_t<T> &tri_modifier() const {
        return std::get<modifier_t<T>>(mods);
    }
    
    template<typename T>
    T modify(T v) const {
        return std::get<modifier_t <T>>(mods)(v);
    }

    std::vector<types> v;

    class Iterator {
        const tri_list *tri;

    public:
        using value_type = types;
        using difference_type = ptrdiff_t;
        using pointer = const value_type*;
        using reference = const value_type&;


        Iterator(pointer it, const tri_list *tri)
                : ptr{it}, tri{tri} {}

        Iterator() : ptr{}, tri{nullptr} {}

        types operator*() const {
            return std::visit([this] <typename T> (const T &t) -> types {
                    return tri->tri_modifier<T>()(t);
            }, *ptr);
        }

        Iterator& operator++() {
            ptr++;
            return *this;
        }
        Iterator& operator--() {
            ptr--;
            return *this;
        }
        Iterator operator++(int) {
            Iterator result {*this};
            operator++();
            return result;
        }
        Iterator operator--(int) {
            Iterator result {*this};
            operator--();
            return result;
        }
        friend bool operator==(const Iterator& a, const Iterator& b) {
            return a.ptr == b.ptr;
        }

    private:
        pointer ptr;
    };

public:
    tri_list() : v{} {}

    tri_list(std::initializer_list<types> list) : v{list} {}

    template<onlyOne<T1, T2, T3> T>
    void push_back(const T &t) {
        v.emplace_back(t);
    }

    template<onlyOne<T1, T2, T3> T>
    void reset() {
        std::get<modifier_t <T>>(mods) = identity<T>;
    }

    template<onlyOne<T1, T2, T3> T, modifier<T> F>
    void modify_only(F m = F{}) {
        auto &mod = std::get<modifier_t <T>>(mods);
        mod = compose<T>(std::move(m), std::move(mod));
    }

    template<onlyOne<T1, T2, T3> T>
    auto range_over() const {
        return v
               | std::views::filter(std::holds_alternative<T, T1, T2, T3>)
               | std::views::transform([this](const types &v) -> T {
            return modify<T>(std::get<T>(v));
        });
    }

    Iterator begin() const {
        return Iterator{&v[0], this};
    }

    Iterator end() const {
        return Iterator{&v[v.size()], this};
    }
};

#endif  // TRI_LIST_H
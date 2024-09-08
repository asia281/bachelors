cmake_minimum_required(VERSION 3.18)
project(jnp)

set(CMAKE_CXX_STANDARD 20)

include_directories(.)

add_executable(jnp
        tri_list_concepts.h
       # testy-zad7/ok2_modifier_compose_identity.cc
       # testy-zad7/ok3_constant_time.cc
       # testy-zad7/ok4_template_types.cc
        testy-zad7/ok5_compose_types.cc
       # testy-zad7/ok6_reset.cc
       # testy-zad7/ok7_const_correctness.cc
       # testy-zad7/ok8_compose_order.cc
        )

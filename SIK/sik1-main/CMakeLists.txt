cmake_minimum_required(VERSION 3.1)

project(MIMUW_SIK_1)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-g -Wall -Wextra")

add_executable(ticket_ser ticket_server.c response.h request.h validate_flags.h parse_file.h common.h err.h)

install(TARGETS DESTINATION .)

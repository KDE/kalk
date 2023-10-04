# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

add_library(knumber STATIC
    knumber.cpp
    knumber.h
    knumber_error.cpp
    knumber_error.h
    knumber_float.cpp
    knumber_float.h
    knumber_fraction.cpp
    knumber_fraction.h
    knumber_integer.cpp
    knumber_integer.h
    knumber_operators.cpp
    knumber_operators.h
)

target_include_directories(knumber PUBLIC ${CMAKE_BINARY_DIR} ${GMP_INCLUDE_DIR})

target_link_libraries(knumber PUBLIC Qt::Core PRIVATE ${GMP_LIBRARIES} ${MPFR_LIBRARIES})

add_subdirectory( tests ) 

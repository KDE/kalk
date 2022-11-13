# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

add_library(knumber STATIC
    knumber.cpp
    knumber_error.cpp
    knumber_float.cpp
    knumber_fraction.cpp
    knumber_integer.cpp
    knumber_operators.cpp
)

target_include_directories(knumber PUBLIC ${CMAKE_BINARY_DIR} ${GMP_INCLUDE_DIR})

target_link_libraries(knumber PUBLIC Qt5::Core PRIVATE ${GMP_LIBRARIES} ${MPFR_LIBRARIES})

add_subdirectory( tests ) 

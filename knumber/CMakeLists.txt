add_library(knumber STATIC
    knumber.cpp
    knumber_error.cpp
    knumber_float.cpp
    knumber_fraction.cpp
    knumber_integer.cpp
    knumber_operators.cpp
    knumber_binary_wrapper.cpp
)

target_include_directories(knumber PUBLIC ${CMAKE_BINARY_DIR} ${GMP_INCLUDE_DIR})

target_link_libraries(knumber PUBLIC Qt5::Core PRIVATE ${GMP_LIBRARIES} ${MPFR_LIBRARIES})

add_subdirectory( tests ) 

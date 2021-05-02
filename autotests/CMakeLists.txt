
include_directories(
${CMAKE_CURRENT_BINARY_DIR}/../src
${CMAKE_CURRENT_SOURCE_DIR}/../knumber
)

ecm_add_test(inputmanagertest.cpp
    TEST_NAME "inputmanagertest"
    LINK_LIBRARIES Qt5::Test knumber kalklib
)

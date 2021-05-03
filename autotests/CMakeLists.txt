
include_directories(
${CMAKE_CURRENT_BINARY_DIR}/../src
${CMAKE_CURRENT_SOURCE_DIR}/../knumber
)

ecm_add_test(inputmanagertest.cpp
    TEST_NAME "inputmanagertest"
    LINK_LIBRARIES Qt5::Test knumber kalklib
)

ecm_add_test(inputmanagertest.cpp
    TEST_NAME "inputmanagertest_de"
    LINK_LIBRARIES Qt5::Test knumber kalklib
)

target_compile_definitions(inputmanagertest PUBLIC LANG="C")
target_compile_definitions(inputmanagertest_de PUBLIC LANG="de_DE.utf8")


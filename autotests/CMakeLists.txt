# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

include(ECMAddTests)

include_directories(
${CMAKE_CURRENT_BINARY_DIR}/../src
)

ecm_add_test(inputmanagertest.cpp
    TEST_NAME "inputmanagertest"
    LINK_LIBRARIES Qt::Test kalklib PkgConfig::QALCULATE
)

ecm_add_test(inputmanagertest.cpp
    TEST_NAME "inputmanagertest_de"
    LINK_LIBRARIES Qt::Test kalklib PkgConfig::QALCULATE
)

target_compile_definitions(inputmanagertest PUBLIC LANG="C")
target_compile_definitions(inputmanagertest_de PUBLIC LANG="de_DE.utf8")

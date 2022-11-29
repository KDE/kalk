# SPDX-FileCopyrightText: 2020 Cahfofpai
# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

bison_target(MyParser ${CMAKE_CURRENT_SOURCE_DIR}/mathengine/parser.yy ${CMAKE_CURRENT_BINARY_DIR}/parser.cc)
flex_target(MyScanner ${CMAKE_CURRENT_SOURCE_DIR}/mathengine/scanner.ll ${CMAKE_CURRENT_BINARY_DIR}/scanner.cc)

add_library(kalklib STATIC
    historymanager.cpp
    inputmanager.cpp
    mathengine.cpp
    mathengine/driver.cc
    ${CMAKE_CURRENT_BINARY_DIR}/parser.cc
    ${CMAKE_CURRENT_BINARY_DIR}/scanner.cc
)

target_link_libraries(kalklib
    Qt::Core
    knumber)

set(kalk_SRCS
    main.cpp
    about.cpp
    unitmodel.cpp)

if (QT_MAJOR_VERSION EQUAL "6")
    list(APPEND kalk_SRCS calculator.qrc)
else()
    qtquick_compiler_add_resources(RESOURCES calculator.qrc)
endif()
add_executable(kalk ${kalk_SRCS} ${RESOURCES})

add_flex_bison_dependency(MyScanner MyParser)

target_link_libraries(kalk
    Qt::Core
    Qt::Widgets
    Qt::Qml
    Qt::QuickControls2
    KF5::UnitConversion
    KF5::ConfigCore
    KF5::I18n
    KF5::CoreAddons
    kalklib
    knumber)
target_include_directories(kalk PRIVATE ${CMAKE_BINARY_DIR})

target_include_directories(kalklib PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/mathengine)

install(TARGETS kalk ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

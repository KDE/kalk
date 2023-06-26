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
    unitmodel.cpp)

if (QT_MAJOR_VERSION EQUAL "6")
    list(APPEND kalk_SRCS calculator.qrc)
else()
    qtquick_compiler_add_resources(RESOURCES calculator.qrc)
endif()
add_executable(kalk ${kalk_SRCS} ${RESOURCES})

add_flex_bison_dependency(MyScanner MyParser)

target_link_libraries(kalk PRIVATE
    Qt::Core
    Qt::Qml
    Qt::QuickControls2
    KF${QT_MAJOR_VERSION}::UnitConversion
    KF${QT_MAJOR_VERSION}::ConfigCore
    KF${QT_MAJOR_VERSION}::I18n
    KF${QT_MAJOR_VERSION}::CoreAddons
    kalklib
    knumber)

if(ANDROID)
    target_link_libraries(kalk PRIVATE
        KF${QT_MAJOR_VERSION}::Kirigami2
        Qt::Svg
        OpenSSL::SSL
    )

    kirigami_package_breeze_icons(ICONS
        org.kde.kalk
        accessories-calculator
        edit-clear
        edit-clear-history
        format-number-percent
        gtk-convert
        help-about
        shallow-history
    )
else()
    target_link_libraries(kalk PRIVATE Qt::Widgets)
endif()


target_include_directories(kalk PRIVATE ${CMAKE_BINARY_DIR})

target_include_directories(kalklib PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/mathengine)

install(TARGETS kalk ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

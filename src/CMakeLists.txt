# SPDX-FileCopyrightText: 2020 Cahfofpai
# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

bison_target(MyParser ${CMAKE_CURRENT_SOURCE_DIR}/mathengine/parser.yy ${CMAKE_CURRENT_BINARY_DIR}/parser.cc)
flex_target(MyScanner ${CMAKE_CURRENT_SOURCE_DIR}/mathengine/scanner.ll ${CMAKE_CURRENT_BINARY_DIR}/scanner.cc)

add_library(kalklib STATIC
    historymanager.cpp
    historymanager.h
    inputmanager.cpp
    inputmanager.h
    mathengine.cpp
    mathengine.h
    mathengine/driver.cc
    ${CMAKE_CURRENT_BINARY_DIR}/parser.cc
    ${CMAKE_CURRENT_BINARY_DIR}/scanner.cc
)

target_link_libraries(kalklib
    Qt::Core
    knumber)

add_executable(kalk
    main.cpp
    unitmodel.cpp
    unitmodel.h
    calculator.qrc
)

add_flex_bison_dependency(MyScanner MyParser)

target_link_libraries(kalk PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::QuickControls2
    KF6::UnitConversion
    KF6::I18n
    KF6::CoreAddons
    kalklib
    knumber)

if(ANDROID)
    target_link_libraries(kalk PRIVATE
        KF6::Kirigami2
        Qt6::Svg
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
    target_link_libraries(kalk PRIVATE Qt6::Widgets)
endif()


target_include_directories(kalk PRIVATE ${CMAKE_BINARY_DIR})

target_include_directories(kalklib PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/mathengine)

install(TARGETS kalk ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

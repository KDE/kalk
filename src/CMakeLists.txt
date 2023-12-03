# SPDX-FileCopyrightText: 2020 Cahfofpai
# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

add_library(kalklib STATIC
    historymanager.cpp
    historymanager.h
    inputmanager.cpp
    inputmanager.h
    qalculateengine.cpp
    qalculateengine.h
)

target_link_libraries(kalklib
    Qt::Core
    KF6::I18n
    KF6::ConfigGui
    PkgConfig::QALCULATE
)

kconfig_add_kcfg_files(kalklib GENERATE_MOC kalkconfig.kcfgc)

add_executable(kalk
    main.cpp
    unitmodel.cpp
    unitmodel.h
    calculator.qrc
)

target_link_libraries(kalk PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::QuickControls2
    KF6::UnitConversion
    KF6::I18n
    KF6::CoreAddons
    kalklib
)

if(ANDROID)
    target_link_libraries(kalk PRIVATE
        KF6::Kirigami
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

install(TARGETS kalk ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

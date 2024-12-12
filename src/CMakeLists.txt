# SPDX-FileCopyrightText: 2020 Cahfofpai
# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

add_library(kalklib STATIC
    historymanager.cpp
    historymanager.h
    inputmanager.cpp
    inputmanager.h
    unitmodel.cpp
    unitmodel.h
    qalculateengine.cpp
    qalculateengine.h
)

ecm_add_qml_module(kalklib
    URI "org.kde.kalk"
    GENERATE_PLUGIN_SOURCE
)

ecm_target_qml_sources(kalklib SOURCES
    qml/Main.qml
    qml/AboutPage.qml
    qml/NumberPad.qml
    qml/HistoryView.qml
    qml/NumberButton.qml
    qml/CalculationPage.qml
    qml/FunctionPad.qml
    qml/BinaryCalculator.qml
    qml/BinaryPad.qml
    qml/UnitConverter.qml
    qml/PortraitPad.qml
    qml/LandScapePad.qml
    qml/SidebarButton.qml
    qml/SettingsPage.qml
)

target_link_libraries(kalklib PUBLIC
    Qt::Core
    Qt::Qml
    KF6::I18n
    KF6::I18nQml
    KF6::ConfigGui
    KF6::UnitConversion
    PkgConfig::QALCULATE
)

kconfig_add_kcfg_files(kalklib GENERATE_MOC kalkconfig.kcfgc)

add_executable(kalk
    main.cpp
)

target_link_libraries(kalk PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::QuickControls2
    KF6::I18n
    KF6::CoreAddons
    kalklib
    kalklibplugin
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

#  This file is part of Kalk
#
#  Copyright (C) 2020 Cahfofpai
#                     Han Young <hanyoung@protonmail.com>
#
#
#  $BEGIN_LICENSE:GPL3+$
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  $END_LICENSE$
project(Kalk)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

cmake_minimum_required(VERSION 2.8.12)
set(KF5_MIN_VERSION "5.18.0")
set(QT_MIN_VERSION "5.5.0")
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "This application requires an out of source build. Please
        create a separate build directory.")
endif()

include(FeatureSummary)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set (CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
set (CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" ${CMAKE_SOURCE_DIR}/cmake/modules)
find_package(GMP)
set_package_properties(GMP PROPERTIES
    DESCRIPTION "The GNU Multiple Precision Arithmetic Library"
    URL "https://gmplib.org/"
    TYPE REQUIRED
    PURPOSE "Required for building KCalc."
)

find_package(MPFR)
set_package_properties(MPFR PROPERTIES
    DESCRIPTION "The GNU Multiple Precision Floating-Point Reliable Library"
    URL "https://www.mpfr.org/"
    TYPE REQUIRED
    PURPOSE "Required for building KCalc."
)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(ECMPoQmTools)
include(KDECompilerSettings NO_POLICY_SCOPE)
find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui QuickControls2 Widgets)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
        Config
        Kirigami2
        I18n
        CoreAddons
        UnitConversion)
add_subdirectory(src)

configure_file(config-kcalc.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-kcalc.h )
add_subdirectory(knumber)

install(PROGRAMS org.kde.kalk.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.kalk.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES kalk.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps/)
feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

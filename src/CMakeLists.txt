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
    Qt5::Core
    knumber)

set(kalk_SRCS
    main.cpp
    about.cpp
    unitmodel.cpp)
qtquick_compiler_add_resources(RESOURCES calculator.qrc)
add_executable(kalk ${kalk_SRCS} ${RESOURCES})

add_flex_bison_dependency(MyScanner MyParser)

target_link_libraries(kalk
    Qt5::Core
    Qt5::Widgets
    Qt5::Qml
    Qt5::QuickControls2
    KF5::UnitConversion
    KF5::ConfigCore
    KF5::I18n
    KF5::CoreAddons
    kalklib
    knumber)
target_include_directories(kalk PRIVATE ${CMAKE_BINARY_DIR})

target_include_directories(kalklib PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/mathengine)

install(TARGETS kalk ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

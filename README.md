<!--
- SPDX-FileCopyrightText: None 
- SPDX-License-Identifier: CC0-1.0
-->

# <img src="kalk.png" width="48"/> Kalk
Kalk is a convergent calculator application built with the [Kirigami framework](https://kde.org/products/kirigami/). Although it is mainly targeted for mobile platforms, it can also be used on the desktop.

Originally starting as a fork of [Liri calculator](https://github.com/lirios/calculator), Kalk has gone through heavy development, and no longer shares the same codebase with Liri calculator.

<a href='https://flathub.org/apps/details/org.kde.kalk'><img width='190px' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-i-en.png'/></a>

[![Snap Store Link](https://snapcraft.io/en/dark/install.svg)](https://snapcraft.io/kalk)


## Features
* Basic calculation
* History
* Unit conversion
* Currency conversion
* Binary calculation

## Links
* App page: https://apps.kde.org/kalk
* Project page: https://invent.kde.org/utilities/kalk
* Issues: https://bugs.kde.org/enter_bug.cgi?product=Kalk
* Development channel: https://matrix.to/#/#plasmamobile:matrix.org

## Dependencies
* Qt6
* CMake
* KI18n
* KUnitConversion
* Kirigami
* Kirigami Add-ons
* KConfig
* libqalculate

See the top level CMakeLists.txt file for more dependencies.

## Building and Installing

```sh
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/path/to/prefix -G Ninja .. # add -DCMAKE_BUILD_TYPE=Release to compile for release
ninja install # use sudo if necessary
```

Replace `/path/to/prefix` with your installation prefix.
Default is `/usr/local`.

## Licensing
GPLv3, see [this page](https://www.gnu.org/licenses/gpl-3.0.en.html).

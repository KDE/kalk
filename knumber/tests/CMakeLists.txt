# SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

include(ECMAddTests)

ecm_add_test(knumbertest.cpp
    LINK_LIBRARIES knumber
    TEST_NAME knumbertest
)

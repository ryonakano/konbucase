/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Util {
    /**
     * Whether the app is running on Pantheon desktop environment.
     *
     * @return  ``true`` if the app is running on Pantheon desktop environment, ``false`` otherwise
     */
    public static bool is_on_pantheon () {
        return Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
    }
}

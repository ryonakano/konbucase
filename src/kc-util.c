/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-util.h"

/**
 * util_is_pantheon:
 *
 * Whether the app is running on Pantheon desktop environment.
 *
 * Returns: `TRUE` if the app is running on Pantheon desktop environment, `FALSE` otherwise
 */
gboolean
kc_util_is_pantheon (void)
{
    const gchar *current_destkop;

    current_destkop = g_getenv ("XDG_CURRENT_DESKTOP");
    if (!current_destkop) {
        return FALSE;
    }

    return g_strcmp0 (current_destkop, "Pantheon") == 0;
}

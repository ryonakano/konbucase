/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-convert.h"

#include "kc-common.h"

AdwColorScheme
kc_convert_to_adw_scheme (const gchar *str_scheme)
{
    if (g_strcmp0 (str_scheme, KC_COLOR_SCHEME_DEFAULT) == 0) {
        return ADW_COLOR_SCHEME_DEFAULT;
    }

    if (g_strcmp0 (str_scheme, KC_COLOR_SCHEME_FORCE_LIGHT) == 0) {
        return ADW_COLOR_SCHEME_FORCE_LIGHT;
    }

    if (g_strcmp0 (str_scheme, KC_COLOR_SCHEME_FORCE_DARK) == 0) {
        return ADW_COLOR_SCHEME_FORCE_DARK;
    }

    g_warning ("Unsupported color scheme string: %s", str_scheme);
    return ADW_COLOR_SCHEME_DEFAULT;
}

const gchar *
kc_convert_to_str_scheme (AdwColorScheme adw_scheme)
{
    switch (adw_scheme) {
    case ADW_COLOR_SCHEME_DEFAULT:
        return KC_COLOR_SCHEME_DEFAULT;
    case ADW_COLOR_SCHEME_FORCE_LIGHT:
        return KC_COLOR_SCHEME_FORCE_LIGHT;
    case ADW_COLOR_SCHEME_FORCE_DARK:
        return KC_COLOR_SCHEME_FORCE_DARK;
    default:
        g_warning ("Unsupported color scheme: %d", adw_scheme);
        return KC_COLOR_SCHEME_DEFAULT;
    }
}

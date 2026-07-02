/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-convert.h"

#include "kc-common.h"

/**
 * KcConvert:
 *
 * Converts data types.
 */

/**
 * kc_convert_to_adw_scheme:
 * @str_scheme: (transfer none): string representation of a color scheme
 *
 * Converts string representation of a color scheme to `AdwColorScheme`.
 *
 * Returns: a `AdwColorScheme`
 */
AdwColorScheme
kc_convert_to_adw_scheme (const char *str_scheme)
{
    g_return_val_if_fail (str_scheme != NULL, ADW_COLOR_SCHEME_DEFAULT);

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

/**
 * kc_convert_to_str_scheme:
 * @adw_scheme: a `AdwColorScheme`
 *
 * Converts `AdwColorScheme` to string representation of a color scheme.
 *
 * Returns: (transfer none): string representation of a color scheme
 */
const char *
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
        g_warning ("Unsupported color scheme: %u", adw_scheme);
        return KC_COLOR_SCHEME_DEFAULT;
    }
}
